-- Migration 016: Workflow Reconciliation
-- Deskripsi: Menghapus peran Carik sebagai verifikator perantara dan mengizinkan Lurah untuk langsung mengevaluasi jurnal Submitted.
-- Prerequisite: 014_rpc_functions.sql

-- ============================================================
-- 1. REVOKE VERIFY_JOURNAL
-- ============================================================
-- Cabut akses eksekusi verify_journal agar tidak ada lagi yang bisa/wajib memanggilnya dari aplikasi
REVOKE EXECUTE ON FUNCTION public.verify_journal(UUID) FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.verify_journal(UUID) FROM PUBLIC;

-- ============================================================
-- 2. UPDATE APPROVE_JOURNAL
-- ============================================================
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

    -- UBAH: Lurah langsung mengevaluasi Submitted, bukan Verified
    IF v_status <> 'Submitted'::public.journal_status THEN
        RAISE EXCEPTION 'Cannot approve journal with status % (must be Submitted).', v_status USING ERRCODE = '22000';
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
    ON CONFLICT (journal_id) DO UPDATE 
    SET assessed_realization = EXCLUDED.assessed_realization,
        capaian_value = EXCLUDED.capaian_value,
        assessment_note = EXCLUDED.assessment_note,
        assessed_by = EXCLUDED.assessed_by,
        assessed_at = EXCLUDED.assessed_at;

    UPDATE public.performance_journals
    SET status = 'Approved'::public.journal_status
    WHERE id = p_journal_id;
END;
$$;

-- Pastikan izin eksekusi tetap ada
GRANT EXECUTE ON FUNCTION public.approve_journal(UUID, INTEGER, NUMERIC, TEXT) TO authenticated;

-- ============================================================
-- 3. UPDATE RETURN_JOURNAL
-- ============================================================
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

    -- UBAH: Hanya Lurah yang bisa meretur jurnal Submitted (Carik tidak lagi terlibat)
    IF v_status = 'Submitted'::public.journal_status THEN
        IF NOT public.fn_is_lurah() THEN
            RAISE EXCEPTION 'Unauthorized: Only Lurah can return Submitted journals.' USING ERRCODE = '42501';
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

GRANT EXECUTE ON FUNCTION public.return_journal(UUID, TEXT) TO authenticated;
