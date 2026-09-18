-- ============================================================
-- 003_employee_assignments.sql
-- Sistem Manajemen Kinerja & Presensi Pemerintah Kalurahan
-- Baseline: IMPLEMENTATION SPECIFICATION FINAL V3.2.2.4
--
-- Scope:
--   - public.employee_position_assignments
--   - GiST exclusion constraint preventing active assignment overlap
--   - Integrity constraints on effective dates
--   - Updated_at trigger binding
--   - Direct client DELETE restriction
--
-- Prerequisites:
--   - 001_extensions_and_types.sql (btree_gist, position_assignment_status)
--   - 002_core_auth.sql (public.employees, public.positions, public.set_updated_at)
--
-- This migration intentionally does NOT create:
--   - Seed data (deferred to 015_seed_kalidengen.sql)
--   - Full RLS policies (deferred to 013_rls_and_privileges.sql)
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. Table: public.employee_position_assignments
-- ------------------------------------------------------------
-- Tracks the historical assignments of government positions to employees.
-- An employee may hold different positions across time, but must not
-- have overlapping 'active' assignments.
CREATE TABLE IF NOT EXISTS public.employee_position_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL
        REFERENCES public.employees(id)
        ON DELETE RESTRICT,
    position_id UUID NOT NULL
        REFERENCES public.positions(id)
        ON DELETE RESTRICT,
    status public.position_assignment_status NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Check constraint ensuring effective_to is strictly after effective_from
    CONSTRAINT chk_emp_pos_assign_dates
        CHECK (effective_to IS NULL OR effective_to > effective_from),

    -- Exclusion constraint preventing overlapping active assignments for an employee.
    -- Uses half-open interval: [effective_from, effective_to).
    -- Requires btree_gist extension (installed in 001_extensions_and_types.sql).
    CONSTRAINT ex_emp_pos_assign_no_active_overlap
        EXCLUDE USING gist (
            employee_id WITH =,
            daterange(
                effective_from,
                coalesce(effective_to, 'infinity'::date),
                '[)'
            ) WITH &&
        )
        WHERE (status = 'active')
);

-- ------------------------------------------------------------
-- 2. Updated_at Trigger
-- ------------------------------------------------------------
-- Reuses the schema-qualified public.set_updated_at() defined in 002_core_auth.sql.
DROP TRIGGER IF EXISTS trg_set_employee_position_assignments_updated_at ON public.employee_position_assignments;
CREATE TRIGGER trg_set_employee_position_assignments_updated_at
    BEFORE UPDATE ON public.employee_position_assignments
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

-- ------------------------------------------------------------
-- 3. Privilege Restrictions (GRANT / REVOKE)
-- ------------------------------------------------------------
-- Prohibit direct deletion of assignment history by authenticated clients.
-- Full RLS policies and granular permissions will be applied in migration 013.
REVOKE DELETE ON public.employee_position_assignments FROM authenticated;

COMMIT;
