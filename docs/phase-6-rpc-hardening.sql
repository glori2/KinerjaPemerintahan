-- PHASE 6.4.3 RPC HARDENING

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
    -- 1. Otorisasi: Carik ATAU System / service_role (Fail-Closed)
    IF current_user = 'postgres' AND current_setting('request.jwt.claims', true) IS NULL THEN
        -- Trusted Internal DB Cron
        v_locked_by := NULL;
    ELSIF coalesce(current_setting('request.jwt.claims', true), '{}')::jsonb->>'role' = 'service_role' THEN
        -- Trusted PostgREST Service Role
        v_locked_by := NULL;
    ELSIF auth.uid() IS NOT NULL AND public.fn_is_carik() THEN
        -- Trusted Carik (Authenticated API)
        v_locked_by := auth.uid();
    ELSE
        -- Fail-closed explicitly! Deny anonymous and unauthorized roles.
        RAISE EXCEPTION 'Unauthorized: Caller identification rejected. Only Carik, System Cron, or Service Role may generate calculations.' USING ERRCODE = '42501';
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