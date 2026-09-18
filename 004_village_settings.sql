-- Migration 004: Village Settings
-- Deskripsi: Menyimpan konfigurasi aplikasi/kalurahan berbasis key-value JSONB.
-- Prerequisite: 
-- - 001_extensions_and_types.sql
-- - 002_core_auth.sql (untuk public.set_updated_at)

CREATE TABLE public.village_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    setting_key VARCHAR NOT NULL UNIQUE,
    setting_value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Trigger untuk update updated_at otomatis
DROP TRIGGER IF EXISTS trg_set_village_settings_updated_at
ON public.village_settings;

CREATE TRIGGER trg_set_village_settings_updated_at
    BEFORE UPDATE ON public.village_settings
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

-- Security: Client tidak boleh menghapus konfigurasi kalurahan
REVOKE DELETE ON public.village_settings FROM authenticated;
