-- Migration 018: Create Tukin Period RPC
-- Deskripsi: Fungsi untuk membuat periode tukin baru (hanya untuk Carik)

CREATE OR REPLACE FUNCTION public.create_tukin_period(p_period_month DATE)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_new_id UUID;
BEGIN
    -- 1. Otorisasi: Hanya Carik
    IF NOT public.fn_is_carik() THEN
        RAISE EXCEPTION 'Anda tidak memiliki hak untuk membuat periode.';
    END IF;

    -- 2. Validasi: Harus hari pertama bulan
    IF date_trunc('month', p_period_month) != p_period_month THEN
        RAISE EXCEPTION 'Periode harus menggunakan awal bulan.';
    END IF;

    -- 3. Insert data dengan penanganan duplicate dari UNIQUE constraint
    BEGIN
        INSERT INTO public.tukin_periods (period_month, status)
        VALUES (p_period_month, 'Draft'::public.tukin_period_status)
        RETURNING id INTO v_new_id;
    EXCEPTION WHEN unique_violation THEN
        RAISE EXCEPTION 'Periode tersebut sudah tersedia.';
    END;

    RETURN v_new_id;
END;
$$;

-- Security Grants
REVOKE EXECUTE ON FUNCTION public.create_tukin_period(DATE) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.create_tukin_period(DATE) FROM anon;
GRANT EXECUTE ON FUNCTION public.create_tukin_period(DATE) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_tukin_period(DATE) TO service_role;
