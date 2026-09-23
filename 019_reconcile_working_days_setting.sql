-- Migration 019: Reconcile Working Days Setting
-- Deskripsi: Mengubah legacy key 'working_days_per_month' menjadi 'working_days' dengan format JSON.

DO $$
BEGIN
    -- Jika legacy key ada, lakukan update ke format JSON
    IF EXISTS (SELECT 1 FROM public.village_settings WHERE setting_key = 'working_days_per_month') THEN
        UPDATE public.village_settings
        SET setting_key = 'working_days',
            setting_value = '{"hk": 22}'::jsonb
        WHERE setting_key = 'working_days_per_month';
    END IF;

    -- Pastikan key authoritative sudah ada jika belum di-insert
    INSERT INTO public.village_settings (setting_key, setting_value)
    VALUES ('working_days', '{"hk": 22}'::jsonb)
    ON CONFLICT (setting_key) DO NOTHING;
END $$;
