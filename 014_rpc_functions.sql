-- ============================================================
-- 014_rpc_functions.sql
-- Sistem Manajemen Kinerja & Presensi Pemerintah Kalurahan
-- Baseline: IMPLEMENTATION SPECIFICATION FINAL V3.2.2.4
--
-- Prerequisite: 001 - 013 (sudah finalized dan SQL-ready)
-- ============================================================

-- ============================================================
-- 1. TABLE: public.performance_assessments (JIKA BELUM DIBUAT)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.performance_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_id UUID NOT NULL UNIQUE REFERENCES public.performance_journals(id) ON DELETE RESTRICT,
    assessed_realization INTEGER NOT NULL,
    capaian_value NUMERIC(8,4) NOT NULL,
    assessment_note TEXT NULL,
    assessed_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    assessed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_set_performance_assessments_updated_at ON public.performance_assessments;
CREATE TRIGGER trg_set_performance_assessments_updated_at
    BEFORE UPDATE ON public.performance_assessments
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.performance_assessments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "assessments_select" ON public.performance_assessments;
CREATE POLICY "assessments_select" ON public.performance_assessments FOR SELECT TO authenticated
USING (
    public.fn_is_carik() OR public.fn_is_lurah() OR
    journal_id IN (
        SELECT id FROM public.performance_journals 
        WHERE employee_id = public.fn_get_employee_id()
    )
);

REVOKE ALL ON public.performance_assessments FROM PUBLIC;
REVOKE ALL ON public.performance_assessments FROM authenticated;
GRANT SELECT ON public.performance_assessments TO authenticated;

-- ============================================================
-- 2. ATTACH AUDIT TRIGGERS (DARI MIGRATION 011 KE 20 ENTITAS)
-- ============================================================
DO $$
DECLARE
    t TEXT;
    target_tables TEXT[] := ARRAY[
        'profiles', 'positions', 'employees', 'employee_position_assignments',
        'village_settings', 'tukin_parameters', 'matrix_versions', 'performance_groups',
        'performance_items', 'performance_targets', 'attendances', 'permissions',
        'official_duties', 'performance_journals', 'performance_assessments',
        'journal_evidence', 'disciplinary_actions', 'tukin_periods',
        'tukin_calculations', 'tukin_calculation_components'
    ];
BEGIN
    FOREACH t IN ARRAY target_tables LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_audit_%I ON public.%I;', t, t);
        EXECUTE format('CREATE TRIGGER trg_audit_%I AFTER INSERT OR UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.fn_audit_trigger();', t, t);
    END LOOP;
END $$;

-- ============================================================
-- 3. TRUSTED PROVISIONING RPC
-- ============================================================
CREATE OR REPLACE FUNCTION public.provision_employee_identity(
    p_user_id UUID,
    p_role public.app_profile_role,
    p_full_name VARCHAR,
    p_nip_nipt VARCHAR DEFAULT NULL,
    p_position_id UUID DEFAULT NULL,
    p_effective_from DATE DEFAULT CURRENT_DATE
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_employee_id UUID;
    v_existing_role public.app_profile_role;
    v_position_name VARCHAR;
BEGIN
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'User ID cannot be null.' USING ERRCODE = '22004';
    END IF;

    -- 1. Konsistensi Profile Existing: Role immutable, tidak boleh ada silent repair
    SELECT role INTO v_existing_role
    FROM public.profiles
    WHERE id = p_user_id;

    IF v_existing_role IS NOT NULL THEN
        IF v_existing_role <> p_role THEN
            RAISE EXCEPTION 'Profile % already exists with role %; cannot change role to % (role is immutable).', 
                p_user_id, v_existing_role, p_role USING ERRCODE = '42501';
        END IF;
    END IF;

    -- 2. Validasi Position & Role Integrity
    IF p_position_id IS NOT NULL THEN
        SELECT name INTO v_position_name
        FROM public.positions
        WHERE id = p_position_id;

        IF v_position_name IS NULL THEN
            RAISE EXCEPTION 'Position with ID % does not exist.', p_position_id USING ERRCODE = '22000';
        END IF;

        -- Tolak Bamuskal secara mutlak
        IF v_position_name ILIKE '%Bamuskal%' THEN
            RAISE EXCEPTION 'Bamuskal is completely out of scope and cannot be provisioned.' USING ERRCODE = '42501';
        END IF;

        -- Jika Carik: role MUST be 'admin'
        IF v_position_name = 'Carik' THEN
            IF p_role <> 'admin'::public.app_profile_role THEN
                RAISE EXCEPTION 'Role for position Carik must be admin (provided: %).', p_role USING ERRCODE = '42501';
            END IF;
        ELSE
            -- Semua posisi selain Carik (termasuk Lurah): role MUST be 'user'
            IF p_role <> 'user'::public.app_profile_role THEN
                RAISE EXCEPTION 'Role for position % must be user. Admin role is exclusively for Carik.', v_position_name USING ERRCODE = '42501';
            END IF;
        END IF;
    ELSE
        -- Jika p_position_id IS NULL:
        -- Jangan izinkan role 'admin' tanpa penugasan posisi Carik
        IF p_role = 'admin'::public.app_profile_role THEN
            RAISE EXCEPTION 'Admin role is exclusively reserved for Carik and requires Carik position assignment.' USING ERRCODE = '42501';
        END IF;
    END IF;

    -- 3. Insert / Update Profile (hanya update full_name, role tetap konsisten)
    INSERT INTO public.profiles (id, role, full_name)
    VALUES (p_user_id, p_role, p_full_name)
    ON CONFLICT (id) DO UPDATE 
    SET full_name = EXCLUDED.full_name,
        updated_at = now();

    -- 4. Insert / Update Employee (1:1 profile_id)
    INSERT INTO public.employees (profile_id, nip_nipt)
    VALUES (p_user_id, p_nip_nipt)
    ON CONFLICT (profile_id) DO UPDATE
    SET nip_nipt = coalesce(EXCLUDED.nip_nipt, public.employees.nip_nipt),
        updated_at = now()
    RETURNING id INTO v_employee_id;

    -- 5. Initial Position Assignment jika diberikan
    IF p_position_id IS NOT NULL THEN
        INSERT INTO public.employee_position_assignments (
            employee_id, position_id, status, effective_from
        ) VALUES (
            v_employee_id, p_position_id, 'active', p_effective_from
        );
    END IF;

    RETURN v_employee_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.provision_employee_identity(UUID, public.app_profile_role, VARCHAR, VARCHAR, UUID, DATE) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.provision_employee_identity(UUID, public.app_profile_role, VARCHAR, VARCHAR, UUID, DATE) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.provision_employee_identity(UUID, public.app_profile_role, VARCHAR, VARCHAR, UUID, DATE) TO service_role;

-- ============================================================
-- 4. JOURNAL WORKFLOW RPCS
-- ============================================================

-- A. Create Journal (Snapshot diisi murni dari database internal dengan effective dating)
CREATE OR REPLACE FUNCTION public.create_journal(
    p_item_id UUID,
    p_activity_date DATE,
    p_start_time TIME,
    p_end_time TIME,
    p_realization INTEGER,
    p_location VARCHAR,
    p_note TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_employee_id UUID;
    v_position_id UUID;
    v_matrix_version_id UUID;
    v_group_name VARCHAR;
    v_item_name TEXT;
    v_target INTEGER;
    v_unit VARCHAR;
    v_journal_id UUID;
BEGIN
    -- Validasi Employee dari auth.uid()
    SELECT id INTO v_employee_id 
    FROM public.employees 
    WHERE profile_id = auth.uid() 
    LIMIT 1;

    IF v_employee_id IS NULL THEN
        RAISE EXCEPTION 'Unauthorized: Employee record not found for authenticated user.' USING ERRCODE = '42501';
    END IF;

    -- Validasi Active Assignment pada tanggal aktivitas (TANPA fallback ke current assignment)
    SELECT epa.position_id INTO v_position_id
    FROM public.employee_position_assignments epa
    WHERE epa.employee_id = v_employee_id
      AND epa.status = 'active'
      AND epa.effective_from <= p_activity_date
      AND (epa.effective_to IS NULL OR epa.effective_to > p_activity_date);

    IF v_position_id IS NULL THEN
        RAISE EXCEPTION 'No active position assignment found for employee on activity date %.', p_activity_date USING ERRCODE = '22000';
    END IF;

    -- Ambil Snapshot dari DB internal (Published atau Locked matrix dengan validasi effective date)
    SELECT 
        mv.id, pg.name, pi.name, pt.monthly_target, pi.unit
    INTO
        v_matrix_version_id, v_group_name, v_item_name, v_target, v_unit
    FROM public.performance_items pi
    JOIN public.performance_groups pg ON pg.id = pi.group_id
    JOIN public.matrix_versions mv ON mv.id = pg.matrix_version_id
    JOIN public.performance_targets pt ON pt.item_id = pi.id
    WHERE pi.id = p_item_id
      AND mv.position_id = v_position_id
      AND mv.status IN ('Published', 'Locked')
      AND mv.effective_from <= p_activity_date
      AND (mv.effective_to IS NULL OR p_activity_date < mv.effective_to)
    ORDER BY mv.effective_from DESC
    LIMIT 1;

    IF v_matrix_version_id IS NULL THEN
        RAISE EXCEPTION 'Invalid performance item: No published/locked matrix version effective on % for employee position.', p_activity_date USING ERRCODE = '22000';
    END IF;

    -- Insert Journal dengan status Draft
    INSERT INTO public.performance_journals (
        employee_id,
        item_id,
        activity_date,
        start_time,
        end_time,
        matrix_version_id_snapshot,
        group_name_snapshot,
        item_name_snapshot,
        target_snapshot,
        unit_snapshot,
        realization,
        location,
        note,
        status
    ) VALUES (
        v_employee_id,
        p_item_id,
        p_activity_date,
        p_start_time,
        p_end_time,
        v_matrix_version_id,
        v_group_name,
        v_item_name,
        v_target,
        v_unit,
        p_realization,
        p_location,
        p_note,
        'Draft'::public.journal_status
    ) RETURNING id INTO v_journal_id;

    RETURN v_journal_id;
END;
$$;

-- B. Update Journal (Hanya Draft / Returned milik sendiri dengan effective dating)
CREATE OR REPLACE FUNCTION public.update_journal(
    p_journal_id UUID,
    p_item_id UUID,
    p_activity_date DATE,
    p_start_time TIME,
    p_end_time TIME,
    p_realization INTEGER,
    p_location VARCHAR,
    p_note TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_employee_id UUID;
    v_journal_owner_id UUID;
    v_status public.journal_status;
    v_position_id UUID;
    v_matrix_version_id UUID;
    v_group_name VARCHAR;
    v_item_name TEXT;
    v_target INTEGER;
    v_unit VARCHAR;
BEGIN
    SELECT id INTO v_employee_id 
    FROM public.employees 
    WHERE profile_id = auth.uid() 
    LIMIT 1;

    SELECT employee_id, status INTO v_journal_owner_id, v_status
    FROM public.performance_journals
    WHERE id = p_journal_id;

    IF v_journal_owner_id IS NULL THEN
        RAISE EXCEPTION 'Journal not found.' USING ERRCODE = 'P0002';
    END IF;

    IF v_journal_owner_id <> v_employee_id THEN
        RAISE EXCEPTION 'Unauthorized: You do not own this journal.' USING ERRCODE = '42501';
    END IF;

    IF v_status NOT IN ('Draft'::public.journal_status, 'Returned'::public.journal_status) THEN
        RAISE EXCEPTION 'Journal is immutable and cannot be edited in current status (%).', v_status USING ERRCODE = '22000';
    END IF;

    -- Validasi position pada tanggal aktivitas (TANPA fallback ke current assignment)
    SELECT epa.position_id INTO v_position_id
    FROM public.employee_position_assignments epa
    WHERE epa.employee_id = v_employee_id
      AND epa.status = 'active'
      AND epa.effective_from <= p_activity_date
      AND (epa.effective_to IS NULL OR epa.effective_to > p_activity_date);

    IF v_position_id IS NULL THEN
        RAISE EXCEPTION 'No active position assignment found for employee on activity date %.', p_activity_date USING ERRCODE = '22000';
    END IF;

    -- Ambil Snapshot dari DB internal dengan validasi effective date
    SELECT 
        mv.id, pg.name, pi.name, pt.monthly_target, pi.unit
    INTO
        v_matrix_version_id, v_group_name, v_item_name, v_target, v_unit
    FROM public.performance_items pi
    JOIN public.performance_groups pg ON pg.id = pi.group_id
    JOIN public.matrix_versions mv ON mv.id = pg.matrix_version_id
    JOIN public.performance_targets pt ON pt.item_id = pi.id
    WHERE pi.id = p_item_id
      AND mv.position_id = v_position_id
      AND mv.status IN ('Published', 'Locked')
      AND mv.effective_from <= p_activity_date
      AND (mv.effective_to IS NULL OR p_activity_date < mv.effective_to)
    ORDER BY mv.effective_from DESC
    LIMIT 1;

    IF v_matrix_version_id IS NULL THEN
        RAISE EXCEPTION 'Invalid performance item: No published/locked matrix version effective on % for employee position.', p_activity_date USING ERRCODE = '22000';
    END IF;

    UPDATE public.performance_journals
    SET item_id = p_item_id,
        activity_date = p_activity_date,
        start_time = p_start_time,
        end_time = p_end_time,
        matrix_version_id_snapshot = v_matrix_version_id,
        group_name_snapshot = v_group_name,
        item_name_snapshot = v_item_name,
        target_snapshot = v_target,
        unit_snapshot = v_unit,
        realization = p_realization,
        location = p_location,
        note = p_note,
        return_reason = NULL,
        updated_at = now()
    WHERE id = p_journal_id;
END;
$$;

-- C. Submit Journal
CREATE OR REPLACE FUNCTION public.submit_journal(p_journal_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_employee_id UUID;
    v_journal_owner_id UUID;
    v_status public.journal_status;
BEGIN
    SELECT id INTO v_employee_id 
    FROM public.employees 
    WHERE profile_id = auth.uid() 
    LIMIT 1;

    SELECT employee_id, status INTO v_journal_owner_id, v_status
    FROM public.performance_journals
    WHERE id = p_journal_id;

    IF v_journal_owner_id IS NULL THEN
        RAISE EXCEPTION 'Journal not found.' USING ERRCODE = 'P0002';
    END IF;

    IF v_journal_owner_id <> v_employee_id THEN
        RAISE EXCEPTION 'Unauthorized: You do not own this journal.' USING ERRCODE = '42501';
    END IF;

    IF v_status NOT IN ('Draft'::public.journal_status, 'Returned'::public.journal_status) THEN
        RAISE EXCEPTION 'Cannot submit journal with status %.', v_status USING ERRCODE = '22000';
    END IF;

    UPDATE public.performance_journals
    SET status = 'Submitted'::public.journal_status,
        updated_at = now()
    WHERE id = p_journal_id;
END;
$$;

-- D. Return Journal (Carik dari Submitted, Lurah dari Verified)
CREATE OR REPLACE FUNCTION public.return_journal(p_journal_id UUID, p_reason TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_status public.journal_status;
BEGIN
    IF p_reason IS NULL OR trim(p_reason) = '' THEN
        RAISE EXCEPTION 'Return reason is required.' USING ERRCODE = '22004';
    END IF;

    SELECT status INTO v_status
    FROM public.performance_journals
    WHERE id = p_journal_id;

    IF v_status IS NULL THEN
        RAISE EXCEPTION 'Journal not found.' USING ERRCODE = 'P0002';
    END IF;

    IF v_status = 'Submitted'::public.journal_status THEN
        IF NOT public.fn_is_carik() THEN
            RAISE EXCEPTION 'Unauthorized: Only Carik can return Submitted journals.' USING ERRCODE = '42501';
        END IF;
    ELSIF v_status = 'Verified'::public.journal_status THEN
        IF NOT public.fn_is_lurah() THEN
            RAISE EXCEPTION 'Unauthorized: Only Lurah can return Verified journals.' USING ERRCODE = '42501';
        END IF;
    ELSE
        RAISE EXCEPTION 'Cannot return journal with current status %.', v_status USING ERRCODE = '22000';
    END IF;

    UPDATE public.performance_journals
    SET status = 'Returned'::public.journal_status,
        return_reason = p_reason,
        updated_at = now()
    WHERE id = p_journal_id;
END;
$$;

-- E. Verify Journal (Carik only)
CREATE OR REPLACE FUNCTION public.verify_journal(p_journal_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_status public.journal_status;
BEGIN
    IF NOT public.fn_is_carik() THEN
        RAISE EXCEPTION 'Unauthorized: Only Carik can verify journals.' USING ERRCODE = '42501';
    END IF;

    SELECT status INTO v_status
    FROM public.performance_journals
    WHERE id = p_journal_id;

    IF v_status IS NULL THEN
        RAISE EXCEPTION 'Journal not found.' USING ERRCODE = 'P0002';
    END IF;

    IF v_status <> 'Submitted'::public.journal_status THEN
        RAISE EXCEPTION 'Cannot verify journal with status % (must be Submitted).', v_status USING ERRCODE = '22000';
    END IF;

    UPDATE public.performance_journals
    SET status = 'Verified'::public.journal_status,
        updated_at = now()
    WHERE id = p_journal_id;
END;
$$;

-- F. Approve Journal (Lurah only -> creates assessment dengan validasi integritas)
CREATE OR REPLACE FUNCTION public.approve_journal(
    p_journal_id UUID,
    p_assessed_realization INTEGER,
    p_capaian_value NUMERIC,
    p_note TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_status public.journal_status;
    v_journal_realization INTEGER;
    v_target_snapshot INTEGER;
BEGIN
    IF NOT public.fn_is_lurah() THEN
        RAISE EXCEPTION 'Unauthorized: Only Lurah can approve journals and create performance assessment.' USING ERRCODE = '42501';
    END IF;

    SELECT status, realization, target_snapshot 
    INTO v_status, v_journal_realization, v_target_snapshot
    FROM public.performance_journals
    WHERE id = p_journal_id;

    IF v_status IS NULL THEN
        RAISE EXCEPTION 'Journal not found.' USING ERRCODE = 'P0002';
    END IF;

    IF v_status <> 'Verified'::public.journal_status THEN
        RAISE EXCEPTION 'Cannot approve journal with status % (must be Verified).', v_status USING ERRCODE = '22000';
    END IF;

    -- Validasi nilai assessment terhadap data jurnal internal
    IF p_assessed_realization < 0 THEN
        RAISE EXCEPTION 'Assessed realization cannot be negative (provided: %).', p_assessed_realization USING ERRCODE = '22000';
    END IF;

    IF p_assessed_realization > v_journal_realization THEN
        RAISE EXCEPTION 'Assessed realization (%) cannot exceed reported journal realization (%).', 
            p_assessed_realization, v_journal_realization USING ERRCODE = '22000';
    END IF;

    IF v_target_snapshot <= 0 THEN
        RAISE EXCEPTION 'Invalid journal target snapshot (%) for assessment calculation.', v_target_snapshot USING ERRCODE = '22000';
    END IF;

    -- Capaian Kinerja Parsial (Hitungan Capaian Parsial Output) belum final di specification
    -- Jangan mengunci formula (misal: realization/target*100) di level RPC
    IF p_capaian_value IS NULL THEN
        RAISE EXCEPTION 'capaian_value must be provided explicitly as the formula is currently unresolved and delegated to client/business logic.' USING ERRCODE = '22004';
    END IF;

    IF p_capaian_value < 0 THEN
        RAISE EXCEPTION 'capaian_value cannot be negative (provided: %).', p_capaian_value USING ERRCODE = '22000';
    END IF;

    -- Create / Upsert Performance Assessment
    INSERT INTO public.performance_assessments (
        journal_id,
        assessed_realization,
        capaian_value,
        assessment_note,
        assessed_by,
        assessed_at
    ) VALUES (
        p_journal_id,
        p_assessed_realization,
        p_capaian_value,
        p_note,
        auth.uid(),
        now()
    )
    ON CONFLICT (journal_id) DO UPDATE SET
        assessed_realization = EXCLUDED.assessed_realization,
        capaian_value = EXCLUDED.capaian_value,
        assessment_note = EXCLUDED.assessment_note,
        assessed_by = EXCLUDED.assessed_by,
        assessed_at = now(),
        updated_at = now();

    -- Update status jurnal ke Approved
    UPDATE public.performance_journals
    SET status = 'Approved'::public.journal_status,
        updated_at = now()
    WHERE id = p_journal_id;
END;
$$;

-- Grant permissions for journal workflow RPCs
REVOKE EXECUTE ON FUNCTION public.create_journal(UUID, DATE, TIME, TIME, INTEGER, VARCHAR, TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.update_journal(UUID, UUID, DATE, TIME, TIME, INTEGER, VARCHAR, TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.submit_journal(UUID) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.return_journal(UUID, TEXT) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.verify_journal(UUID) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.approve_journal(UUID, INTEGER, NUMERIC, TEXT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.create_journal(UUID, DATE, TIME, TIME, INTEGER, VARCHAR, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_journal(UUID, UUID, DATE, TIME, TIME, INTEGER, VARCHAR, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.submit_journal(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.return_journal(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.verify_journal(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.approve_journal(UUID, INTEGER, NUMERIC, TEXT) TO authenticated;

-- ============================================================
-- 5. MATRIX PUBLISH WORKFLOW RPC (LURAH ONLY)
-- ============================================================
CREATE OR REPLACE FUNCTION public.publish_matrix_version(
    p_matrix_version_id UUID,
    p_effective_from DATE DEFAULT CURRENT_DATE
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_target_matrix RECORD;
    v_group_count INTEGER;
    v_item_count INTEGER;
    v_current_published_id UUID;
BEGIN
    IF NOT public.fn_is_lurah() THEN
        RAISE EXCEPTION 'Unauthorized: Only Lurah can publish matrix versions.' USING ERRCODE = '42501';
    END IF;

    IF p_effective_from IS NULL THEN
        RAISE EXCEPTION 'effective_from date cannot be null.' USING ERRCODE = '22004';
    END IF;

    -- 1. Lock target matrix row
    SELECT * INTO v_target_matrix
    FROM public.matrix_versions
    WHERE id = p_matrix_version_id
    FOR UPDATE;

    IF v_target_matrix IS NULL THEN
        RAISE EXCEPTION 'Matrix version not found.' USING ERRCODE = 'P0002';
    END IF;

    IF v_target_matrix.status <> 'Review'::public.matrix_version_status THEN
        RAISE EXCEPTION 'Matrix version must be in Review status to be published (current: %).', v_target_matrix.status USING ERRCODE = '22000';
    END IF;

    -- 2. Validasi kelengkapan: Wajib punya minimal 1 group & 1 item
    SELECT count(*) INTO v_group_count
    FROM public.performance_groups
    WHERE matrix_version_id = p_matrix_version_id;

    SELECT count(*) INTO v_item_count
    FROM public.performance_items pi
    JOIN public.performance_groups pg ON pg.id = pi.group_id
    WHERE pg.matrix_version_id = p_matrix_version_id;

    IF v_group_count = 0 OR v_item_count = 0 THEN
        RAISE EXCEPTION 'Cannot publish empty matrix version without groups or items.' USING ERRCODE = '22000';
    END IF;

    -- 3. Cari current Published matrix untuk posisi yang sama
    SELECT id INTO v_current_published_id
    FROM public.matrix_versions
    WHERE position_id = v_target_matrix.position_id
      AND status = 'Published'::public.matrix_version_status
      AND effective_from <= p_effective_from
      AND (effective_to IS NULL OR p_effective_from < effective_to)
    FOR UPDATE;

    -- 4. Jika current Published matrix ditemukan, kunci (Locked) dan set effective_to
    IF v_current_published_id IS NOT NULL THEN
        UPDATE public.matrix_versions
        SET status = 'Locked'::public.matrix_version_status,
            effective_to = p_effective_from,
            updated_at = now()
        WHERE id = v_current_published_id;
    END IF;

    -- 5. Publish target matrix
    UPDATE public.matrix_versions
    SET status = 'Published'::public.matrix_version_status,
        effective_from = p_effective_from,
        effective_to = NULL,
        updated_at = now()
    WHERE id = p_matrix_version_id;

END;
$$;

REVOKE EXECUTE ON FUNCTION public.publish_matrix_version(UUID, DATE) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.publish_matrix_version(UUID, DATE) TO authenticated;

-- ============================================================
-- 6. TUKIN CALCULATION ENGINE RPC
-- ============================================================
CREATE OR REPLACE FUNCTION public.generate_calculations(p_period_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_period RECORD;
    v_period_month DATE;
    v_start_date DATE;
    v_end_date DATE;
    v_locked_by UUID := NULL;
    v_formula_version VARCHAR := 'V1.0';
    v_attendance_policy_version VARCHAR := 'V1.0';

    -- Loop Pamong Variables
    v_emp RECORD;
    v_multi_count INTEGER;
    v_pagu NUMERIC(15,2);
    v_min_ckb INTEGER;
    v_mk INTEGER;
    v_hk INTEGER;
    v_pb NUMERIC(8,4);
    v_ckb NUMERIC(8,4);
    v_tkb INTEGER;
    v_actual_kb NUMERIC(8,4);
    v_kb_used NUMERIC(8,4);
    v_npk NUMERIC(8,4);
    v_tukin_pct NUMERIC(5,2);
    v_gross NUMERIC(15,2);
    v_adj_count INTEGER;
    v_adj_pct NUMERIC(5,2);
    v_adj_amount NUMERIC(15,2);
    v_final NUMERIC(15,2);
    v_is_eligible_for_avg BOOLEAN;

    -- Lurah Variables
    v_lurah_count INTEGER;
    v_lurah_emp_id UUID;
    v_lurah_pos_id UUID;
    v_lurah_pagu NUMERIC(15,2);
    v_lurah_min_ckb INTEGER;
    v_avg_pct NUMERIC(5,2);
    v_eligible_count INTEGER;
    v_lurah_gross NUMERIC(15,2);
    v_lurah_adj_count INTEGER;
    v_lurah_adj_pct NUMERIC(5,2);
    v_lurah_adj_amount NUMERIC(15,2);
    v_lurah_final NUMERIC(15,2);
    v_lurah_calc_id UUID;
    v_authoritative_matrix_id UUID;

    v_total_calculated INTEGER := 0;
BEGIN
    -- 1. Otorisasi: Carik ATAU System / service_role (auth.uid() is null)
    IF auth.uid() IS NOT NULL THEN
        IF NOT public.fn_is_carik() THEN
            RAISE EXCEPTION 'Unauthorized: Only Carik or System CRON can generate calculations.' USING ERRCODE = '42501';
        END IF;
        v_locked_by := auth.uid();
    ELSE
        v_locked_by := NULL;
    END IF;

    -- 2. Lock baris tukin_periods FOR UPDATE (Atomisitas)
    SELECT * INTO v_period
    FROM public.tukin_periods
    WHERE id = p_period_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tukin period not found.' USING ERRCODE = 'P0002';
    END IF;

    -- Periode WAJIB dalam status Draft (Tolak mutlak semua status selain Draft)
    IF v_period.status <> 'Draft'::public.tukin_period_status THEN
        RAISE EXCEPTION 'Tukin period % must be in Draft status to generate calculations (current status: %).', v_period.period_month, v_period.status USING ERRCODE = '22000';
    END IF;

    v_period_month := v_period.period_month;
    v_start_date := v_period_month;
    v_end_date := (v_period_month + interval '1 month - 1 day')::DATE;

    -- Hapus kalkulasi sebelumnya jika ada pada Draft period ini (idempotensi kalkulasi)
    DELETE FROM public.tukin_calculation_components 
    WHERE lurah_calculation_id IN (
        SELECT id FROM public.tukin_calculations WHERE period_id = p_period_id
    );
    DELETE FROM public.tukin_calculations WHERE period_id = p_period_id;

    -- 3. Loop Pamong Aktif yang Memenuhi Syarat (is_pamong_tukin_eligible = true, non-Lurah, non-Bamuskal)
    FOR v_emp IN
        SELECT 
            e.id AS employee_id,
            epa.position_id,
            pos.name AS position_name,
            pos.is_pamong_tukin_eligible
        FROM public.employees e
        JOIN public.employee_position_assignments epa ON epa.employee_id = e.id
        JOIN public.positions pos ON pos.id = epa.position_id
        WHERE epa.status = 'active'
          AND epa.effective_from <= v_end_date
          AND (epa.effective_to IS NULL OR epa.effective_to > v_start_date)
          AND pos.is_pamong_tukin_eligible = true
          AND pos.name <> 'Lurah'
          AND pos.name NOT ILIKE '%Bamuskal%'
    LOOP
        -- Validasi fail-safe mutasi tengah periode (Deferred Policy Check)
        SELECT count(*) INTO v_multi_count
        FROM public.employee_position_assignments
        WHERE employee_id = v_emp.employee_id
          AND status = 'active'
          AND effective_from <= v_end_date
          AND (effective_to IS NULL OR effective_to > v_start_date);

        IF v_multi_count > 1 THEN
            RAISE EXCEPTION 'Multi-mutation detected for employee % in period %. Calculation aborted per mutation policy.', v_emp.employee_id, v_period_month USING ERRCODE = '22000';
        END IF;

        -- Ambil Parameter Tukin Posisi
        SELECT tp.pagu_tukin, tp.min_ckb_target
        INTO v_pagu, v_min_ckb
        FROM public.tukin_parameters tp
        WHERE tp.position_id = v_emp.position_id
          AND tp.effective_from <= v_period_month
          AND (tp.effective_to IS NULL OR tp.effective_to > v_period_month)
        ORDER BY tp.effective_from DESC
        LIMIT 1;

        IF v_pagu IS NULL THEN
            RAISE EXCEPTION 'Tukin parameter not found for position % in period %.', v_emp.position_name, v_period_month USING ERRCODE = '22000';
        END IF;

        -- Kehadiran Faktual: MK (Masuk Kerja) dari data attendances yang sah
        SELECT count(*)::INTEGER INTO v_mk
        FROM public.attendances a
        WHERE a.employee_id = v_emp.employee_id
          AND a.attendance_date >= v_start_date
          AND a.attendance_date <= v_end_date
          AND a.status IN ('Hadir', 'hadir', 'PRESENT', 'present');

        -- Evaluasi HK (Hari Kerja):
        -- Mencari sumber HK authoritative dari village_settings
        -- Migration 015 akan men-seed SATU key 'working_days' authoritative
        SELECT (setting_value->>'hk')::INTEGER INTO v_hk
        FROM public.village_settings
        WHERE setting_key = 'working_days'
        LIMIT 1;

        -- Jika schema saat ini belum menyediakan sumber HK authoritative, tolak kalkulasi
        -- untuk mencegah kesalahan perhitungan PB akibat denominator arbitrer.
        IF v_hk IS NULL OR v_hk <= 0 THEN
            RAISE EXCEPTION 'Authoritative working days (HK) source is not available in village_settings for period %. Cannot compute PB without valid HK denominator.', v_period_month USING ERRCODE = '22000';
        END IF;

        -- PB = (MK / HK) * 100
        v_pb := round((v_mk::NUMERIC / v_hk::NUMERIC) * 100.0, 4);
        IF v_pb > 100.0 THEN
            v_pb := 100.0000;
        END IF;

        -- Capaian Kinerja (CK.B) dari jurnal Approved & dinilai
        SELECT coalesce(sum(pa.assessed_realization), 0)::NUMERIC
        INTO v_ckb
        FROM public.performance_journals pj
        JOIN public.performance_assessments pa ON pa.journal_id = pj.id
        WHERE pj.employee_id = v_emp.employee_id
          AND pj.activity_date >= v_start_date
          AND pj.activity_date <= v_end_date
          AND pj.status = 'Approved';

        -- Pilih tepat SATU matrix version authoritative
        SELECT id INTO v_authoritative_matrix_id
        FROM public.matrix_versions mv
        WHERE mv.position_id = v_emp.position_id
          AND mv.status IN ('Published', 'Locked')
          AND mv.effective_from <= v_period_month
          AND (mv.effective_to IS NULL OR v_period_month < mv.effective_to)
        ORDER BY mv.effective_from DESC
        LIMIT 1;

        IF v_authoritative_matrix_id IS NULL THEN
            RAISE EXCEPTION 'No authoritative matrix version found for position % in period %.', v_emp.position_name, v_period_month USING ERRCODE = '22000';
        END IF;

        -- Target Kinerja Bulanan (TK.B) HANYA dari matrix authoritative tersebut
        SELECT coalesce(sum(pt.monthly_target), 0)::INTEGER
        INTO v_tkb
        FROM public.performance_targets pt
        JOIN public.performance_items pi ON pi.id = pt.item_id
        JOIN public.performance_groups pg ON pg.id = pi.group_id
        WHERE pg.matrix_version_id = v_authoritative_matrix_id;

        IF v_tkb = 0 THEN
            v_tkb := v_min_ckb;
        END IF;
        IF v_tkb = 0 THEN
            v_tkb := 1;
        END IF;

        -- KB = (CK.B / TK.B) * 100
        v_actual_kb := round((v_ckb / v_tkb::NUMERIC) * 100.0, 4);
        v_kb_used := v_actual_kb; -- Capping >100% adalah deferred policy

        -- NPK = (PB * 0.4) + (KB * 0.6)
        v_npk := round((v_pb * 0.4) + (v_kb_used * 0.6), 4);

        -- Mapping Interval NPK -> Tukin Percentage
        -- Aturan: batas minimum wajib 40 (jangan gunakan >= 39)
        IF v_npk >= 91.0 THEN
            v_tukin_pct := 100.00;
        ELSIF v_npk >= 81.0 THEN
            v_tukin_pct := 90.00;
        ELSIF v_npk >= 71.0 THEN
            v_tukin_pct := 70.00;
        ELSIF v_npk >= 40.0 THEN
            v_tukin_pct := 40.00;
        ELSIF v_npk >= 10.0 THEN
            v_tukin_pct := 10.00;
        ELSE
            v_tukin_pct := 0.00;
        END IF;

        v_gross := round(v_pagu * (v_tukin_pct / 100.0), 2);

        -- Penyesuaian Disiplin: Stacking masih deferred. Tolak multiple actions yang ambigu.
        SELECT count(*), coalesce(max(da.adjustment_percentage), 0)::NUMERIC
        INTO v_adj_count, v_adj_pct
        FROM public.disciplinary_actions da
        WHERE da.employee_id = v_emp.employee_id
          AND da.period_id = p_period_id;

        IF v_adj_count > 1 THEN
            RAISE EXCEPTION 'Multiple disciplinary actions (%) detected for employee % in period %. Disciplinary stacking policy is deferred.', v_adj_count, v_emp.employee_id, v_period_month USING ERRCODE = '22000';
        END IF;

        v_adj_amount := round(v_gross * (v_adj_pct / 100.0), 2);
        v_final := greatest(0.00, v_gross - v_adj_amount);

        -- Kelayakan Masuk Rata-rata Lurah:
        -- Posisi berstatus pamong tukin eligible, exclude Lurah dan Bamuskal
        v_is_eligible_for_avg := (
            v_emp.is_pamong_tukin_eligible = true
            AND v_emp.position_name <> 'Lurah'
            AND v_emp.position_name NOT ILIKE '%Bamuskal%'
        );

        -- Insert Kalkulasi Pamong
        INSERT INTO public.tukin_calculations (
            period_id,
            employee_id,
            tukin_formula_role,
            lurah_average_eligible,
            position_id_snapshot,
            pagu_snapshot,
            min_ckb_snapshot,
            formula_version,
            attendance_policy_version,
            mk,
            hk,
            pb,
            ckb,
            tkb,
            actual_kb,
            kb_used_for_npk,
            npk,
            tukin_percentage,
            gross_tukin,
            adjustment_amount,
            final_tukin
        ) VALUES (
            p_period_id,
            v_emp.employee_id,
            'Pamong'::public.tukin_formula_role,
            v_is_eligible_for_avg,
            v_emp.position_id,
            v_pagu,
            v_min_ckb,
            v_formula_version,
            v_attendance_policy_version,
            v_mk,
            v_hk,
            v_pb,
            v_ckb,
            v_tkb,
            v_actual_kb,
            v_kb_used,
            v_npk,
            v_tukin_pct,
            v_gross,
            v_adj_amount,
            v_final
        );

        v_total_calculated := v_total_calculated + 1;
    END LOOP;

    -- 4. Kalkulasi Tukin Lurah (Rata-rata Persentase Pamong Berhak)
    SELECT 
        coalesce(avg(tc.tukin_percentage), 0.00)::NUMERIC(5,2),
        count(*)::INTEGER
    INTO 
        v_avg_pct,
        v_eligible_count
    FROM public.tukin_calculations tc
    WHERE tc.period_id = p_period_id
      AND tc.lurah_average_eligible = true;

    -- Verifikasi Keberadaan Tepat 1 Penugasan Aktif Lurah (Invarian Unik Tanpa LIMIT 1)
    SELECT 
        count(*),
        min(e.id),
        min(epa.position_id)
    INTO 
        v_lurah_count,
        v_lurah_emp_id,
        v_lurah_pos_id
    FROM public.employees e
    JOIN public.employee_position_assignments epa ON epa.employee_id = e.id
    JOIN public.positions pos ON pos.id = epa.position_id
    WHERE pos.name = 'Lurah' 
      AND epa.status = 'active'
      AND epa.effective_from <= v_end_date
      AND (epa.effective_to IS NULL OR epa.effective_to > v_start_date);

    IF v_lurah_count = 0 THEN
        RAISE EXCEPTION 'No active Lurah position assignment found for period %.', v_period_month USING ERRCODE = '22000';
    ELSIF v_lurah_count > 1 THEN
        RAISE EXCEPTION 'Multiple active Lurah position assignments (%) detected for period %. Unique Lurah invariant violated.', v_lurah_count, v_period_month USING ERRCODE = '22000';
    END IF;

    -- Ambil parameter Tukin Lurah
    SELECT tp.pagu_tukin, tp.min_ckb_target 
    INTO v_lurah_pagu, v_lurah_min_ckb
    FROM public.tukin_parameters tp
    WHERE tp.position_id = v_lurah_pos_id
      AND tp.effective_from <= v_period_month
      AND (tp.effective_to IS NULL OR tp.effective_to > v_period_month)
    ORDER BY tp.effective_from DESC
    LIMIT 1;

    IF v_lurah_pagu IS NULL THEN
        RAISE EXCEPTION 'Tukin parameter not found for Lurah in period %.', v_period_month USING ERRCODE = '22000';
    END IF;

    -- gross_tukin_lurah = pagu_snapshot_lurah * (average_eligible_percentage / 100)
    v_lurah_gross := round(v_lurah_pagu * (v_avg_pct / 100.0), 2);

    -- Disiplin Lurah: Tolak multiple actions jika ada stacking ambigu
    SELECT count(*), coalesce(max(da.adjustment_percentage), 0)::NUMERIC
    INTO v_lurah_adj_count, v_lurah_adj_pct
    FROM public.disciplinary_actions da
    WHERE da.employee_id = v_lurah_emp_id
      AND da.period_id = p_period_id;

    IF v_lurah_adj_count > 1 THEN
        RAISE EXCEPTION 'Multiple disciplinary actions (%) detected for Lurah in period %. Disciplinary stacking policy is deferred.', v_lurah_adj_count, v_period_month USING ERRCODE = '22000';
    END IF;

    v_lurah_adj_amount := round(v_lurah_gross * (v_lurah_adj_pct / 100.0), 2);
    v_lurah_final := greatest(0.00, v_lurah_gross - v_lurah_adj_amount);

    INSERT INTO public.tukin_calculations (
        period_id,
        employee_id,
        tukin_formula_role,
        lurah_average_eligible,
        position_id_snapshot,
        pagu_snapshot,
        min_ckb_snapshot,
        formula_version,
        attendance_policy_version,
        mk,
        hk,
        pb,
        ckb,
        tkb,
        actual_kb,
        kb_used_for_npk,
        npk,
        tukin_percentage,
        gross_tukin,
        adjustment_amount,
        final_tukin
    ) VALUES (
        p_period_id,
        v_lurah_emp_id,
        'Lurah'::public.tukin_formula_role,
        false,
        v_lurah_pos_id,
        v_lurah_pagu,
        v_lurah_min_ckb,
        v_formula_version,
        v_attendance_policy_version,
        0,
        0,
        0.0000,
        0.0000,
        0,
        0.0000,
        0.0000,
        0.0000,
        v_avg_pct,
        v_lurah_gross,
        v_lurah_adj_amount,
        v_lurah_final
    ) RETURNING id INTO v_lurah_calc_id;

    -- Catat breakdown komponen audit rata-rata Lurah
    INSERT INTO public.tukin_calculation_components (
        lurah_calculation_id,
        source_employee_id,
        source_percentage_snapshot
    )
    SELECT 
        v_lurah_calc_id,
        tc.employee_id,
        tc.tukin_percentage
    FROM public.tukin_calculations tc
    WHERE tc.period_id = p_period_id
      AND tc.lurah_average_eligible = true;

    v_total_calculated := v_total_calculated + 1;

    -- 5. Lock Seluruh Jurnal Approved pada Periode Berjalan
    UPDATE public.performance_journals
    SET status = 'Locked'::public.journal_status,
        updated_at = now()
    WHERE activity_date >= v_start_date
      AND activity_date <= v_end_date
      AND status = 'Approved'::public.journal_status;

    -- 6. Lock Periode Tukin
    UPDATE public.tukin_periods
    SET status = 'Locked'::public.tukin_period_status,
        locked_at = now(),
        locked_by = v_locked_by,
        updated_at = now()
    WHERE id = p_period_id;

    RETURN jsonb_build_object(
        'period_id', p_period_id,
        'period_month', v_period_month,
        'status', 'Locked',
        'total_calculated', v_total_calculated,
        'lurah_average_percentage', v_avg_pct,
        'lurah_eligible_population', v_eligible_count
    );
END;
$$;

REVOKE EXECUTE ON FUNCTION public.generate_calculations(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.generate_calculations(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.generate_calculations(UUID) TO service_role;
