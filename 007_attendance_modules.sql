-- Migration 007: Attendance Modules
-- Deskripsi: Menyimpan modul data presensi faktual, izin, dan tugas kedinasan.
-- Prerequisite:
-- - 001_extensions_and_types.sql (enum permission_type, workflow_status)
-- - 002_core_auth.sql (public.employees, public.profiles, public.set_updated_at)
-- - 003_employee_assignments.sql
-- - 004_village_settings.sql
-- - 005_tukin_parameters.sql
-- - 006_performance_matrix.sql

-- ============================================================
-- 1. ATTENDANCES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.attendances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES public.employees(id) ON DELETE RESTRICT,
    attendance_date DATE NOT NULL,
    check_in TIMESTAMPTZ NULL,
    check_out TIMESTAMPTZ NULL,
    status VARCHAR NOT NULL,
    note TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_attendance_employee_date UNIQUE (employee_id, attendance_date)
);
-- Catatan: UNIQUE constraint uq_attendance_employee_date akan secara otomatis 
-- menyediakan indeks pada (employee_id, attendance_date).

-- ============================================================
-- 2. PERMISSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES public.employees(id) ON DELETE RESTRICT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    permission_type public.permission_type NOT NULL,
    reason TEXT NOT NULL,
    status public.workflow_status NOT NULL,
    approved_by UUID NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    approved_at TIMESTAMPTZ NULL,
    evidence_url TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_permission_dates CHECK (end_date >= start_date)
);

CREATE INDEX IF NOT EXISTS idx_permissions_employee_start_date 
    ON public.permissions(employee_id, start_date);

-- ============================================================
-- 3. OFFICIAL DUTIES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.official_duties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES public.employees(id) ON DELETE RESTRICT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duty_type VARCHAR NOT NULL,
    destination VARCHAR NOT NULL,
    purpose TEXT NOT NULL,
    status public.workflow_status NOT NULL,
    approved_by UUID NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    approved_at TIMESTAMPTZ NULL,
    document_reference VARCHAR NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_official_duty_dates CHECK (end_date >= start_date)
);

CREATE INDEX IF NOT EXISTS idx_official_duties_employee_start_date 
    ON public.official_duties(employee_id, start_date);

-- ============================================================
-- 4. TRIGGERS (UPDATED_AT)
-- ============================================================
DROP TRIGGER IF EXISTS trg_set_attendances_updated_at ON public.attendances;
CREATE TRIGGER trg_set_attendances_updated_at
    BEFORE UPDATE ON public.attendances
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_set_permissions_updated_at ON public.permissions;
CREATE TRIGGER trg_set_permissions_updated_at
    BEFORE UPDATE ON public.permissions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_set_official_duties_updated_at ON public.official_duties;
CREATE TRIGGER trg_set_official_duties_updated_at
    BEFORE UPDATE ON public.official_duties
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 5. SECURITY & PRIVILEGE RESTRICTION
-- ============================================================
REVOKE DELETE ON public.attendances FROM authenticated;
REVOKE DELETE ON public.permissions FROM authenticated;
REVOKE DELETE ON public.official_duties FROM authenticated;
