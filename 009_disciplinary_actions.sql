-- Migration 009: Disciplinary Actions
-- Deskripsi: Menyimpan tindakan disiplin dan penyesuaian Tukin.
-- Prerequisite:
-- - 002_core_auth.sql (public.employees, public.profiles, public.set_updated_at)
-- Catatan Dependensi:
-- Kolom period_id mengarah ke tabel public.tukin_periods yang baru akan dibuat
-- pada migration 010. Foreign Key (FK) dari period_id ke tukin_periods akan 
-- ditambahkan pada migration 010 untuk menghindari dependensi ke depan.

CREATE TABLE IF NOT EXISTS public.disciplinary_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES public.employees(id) ON DELETE RESTRICT,
    
    -- FK constraint akan ditambahkan di migration 010
    period_id UUID NOT NULL,
    
    adjustment_type VARCHAR NOT NULL,
    adjustment_percentage NUMERIC(5,2) NOT NULL,
    source_rule VARCHAR NOT NULL,
    reason TEXT NOT NULL,
    document_reference VARCHAR NOT NULL,
    
    issued_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    issued_at TIMESTAMPTZ NOT NULL,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index
CREATE INDEX IF NOT EXISTS idx_disciplinary_actions_employee_issued 
    ON public.disciplinary_actions(employee_id, issued_at);

CREATE INDEX IF NOT EXISTS idx_disciplinary_actions_period_id 
    ON public.disciplinary_actions(period_id);

-- Trigger untuk update updated_at otomatis
DROP TRIGGER IF EXISTS trg_set_disciplinary_actions_updated_at ON public.disciplinary_actions;

CREATE TRIGGER trg_set_disciplinary_actions_updated_at
    BEFORE UPDATE ON public.disciplinary_actions
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

-- Security: Client tidak boleh menghapus histori tindakan disiplin
REVOKE DELETE ON public.disciplinary_actions FROM authenticated;
