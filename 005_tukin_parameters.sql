-- Migration 005: Tukin Parameters
-- Deskripsi: Menyimpan parameter Tukin berdasarkan posisi dan masa berlaku (effective dating).
-- Prerequisite: 
-- - 001_extensions_and_types.sql (menyediakan ekstensi btree_gist)
-- - 002_core_auth.sql (untuk public.positions dan fungsi public.set_updated_at)
-- - 003_employee_assignments.sql
-- - 004_village_settings.sql

CREATE TABLE IF NOT EXISTS public.tukin_parameters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    position_id UUID NOT NULL REFERENCES public.positions(id) ON DELETE RESTRICT,
    min_ckb_target INTEGER NOT NULL,
    pagu_tukin NUMERIC(15,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    CONSTRAINT chk_tukin_param_values CHECK (
        pagu_tukin >= 0 AND min_ckb_target >= 0
    ),
    
    CONSTRAINT chk_tukin_param_dates CHECK (
        effective_to IS NULL OR effective_to > effective_from
    ),
    
    CONSTRAINT ex_tukin_parameters_no_overlap EXCLUDE USING gist (
        position_id WITH =,
        daterange(
            effective_from,
            coalesce(effective_to, 'infinity'::date),
            '[)'
        ) WITH &&
    )
);

-- Trigger untuk update updated_at otomatis
DROP TRIGGER IF EXISTS trg_set_tukin_parameters_updated_at ON public.tukin_parameters;

CREATE TRIGGER trg_set_tukin_parameters_updated_at
    BEFORE UPDATE ON public.tukin_parameters
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

-- Security: Client tidak boleh menghapus parameter tukin secara langsung
REVOKE DELETE ON public.tukin_parameters FROM authenticated;
