-- Migration 010: Tukin Calculations
-- Deskripsi: Menyimpan periode tukin, hasil kalkulasi tukin, dan breakdown komponen lurah.
-- Prerequisite:
-- - 001_extensions_and_types.sql (enum tukin_period_status, tukin_formula_role)
-- - 002_core_auth.sql (public.profiles, public.employees, public.set_updated_at)
-- - 009_disciplinary_actions.sql (untuk foreign key period_id)

-- ============================================================
-- 1. TUKIN PERIODS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.tukin_periods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    period_month DATE NOT NULL UNIQUE,
    status public.tukin_period_status NOT NULL,
    locked_at TIMESTAMPTZ NULL,
    locked_by UUID NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_tukin_period_month CHECK (
        date_trunc('month', period_month) = period_month
    )
);

-- ============================================================
-- 2. FK TERTUNDA DARI MIGRATION 009
-- ============================================================
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_disciplinary_actions_period' 
          AND table_schema = 'public' 
          AND table_name = 'disciplinary_actions'
    ) THEN
        ALTER TABLE public.disciplinary_actions
            ADD CONSTRAINT fk_disciplinary_actions_period
            FOREIGN KEY (period_id) REFERENCES public.tukin_periods(id)
            ON DELETE RESTRICT;
    END IF;
END $$;

-- ============================================================
-- 3. TUKIN CALCULATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.tukin_calculations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    period_id UUID NOT NULL REFERENCES public.tukin_periods(id) ON DELETE RESTRICT,
    employee_id UUID NOT NULL REFERENCES public.employees(id) ON DELETE RESTRICT,
    
    tukin_formula_role public.tukin_formula_role NOT NULL,
    lurah_average_eligible BOOLEAN NOT NULL,
    
    position_id_snapshot UUID NOT NULL,
    pagu_snapshot NUMERIC(15,2) NOT NULL,
    min_ckb_snapshot INTEGER NOT NULL,
    formula_version VARCHAR NOT NULL,
    attendance_policy_version VARCHAR NOT NULL,
    
    mk INTEGER NOT NULL,
    hk INTEGER NOT NULL,
    pb NUMERIC(8,4) NOT NULL,
    ckb NUMERIC(8,4) NOT NULL,
    tkb INTEGER NOT NULL,
    actual_kb NUMERIC(8,4) NOT NULL,
    kb_used_for_npk NUMERIC(8,4) NOT NULL,
    npk NUMERIC(8,4) NOT NULL,
    tukin_percentage NUMERIC(5,2) NOT NULL,
    gross_tukin NUMERIC(15,2) NOT NULL,
    adjustment_amount NUMERIC(15,2) NOT NULL,
    final_tukin NUMERIC(15,2) NOT NULL,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_tukin_calculation_period_employee UNIQUE (period_id, employee_id),

    CONSTRAINT chk_tukin_calculation_values CHECK (
        tukin_percentage >= 0
        AND gross_tukin >= 0
        AND final_tukin >= 0
    )
);

CREATE INDEX IF NOT EXISTS idx_tukin_calculations_employee_id 
    ON public.tukin_calculations(employee_id);

-- ============================================================
-- 4. TUKIN CALCULATION COMPONENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.tukin_calculation_components (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lurah_calculation_id UUID NOT NULL REFERENCES public.tukin_calculations(id) ON DELETE RESTRICT,
    source_employee_id UUID NOT NULL REFERENCES public.employees(id) ON DELETE RESTRICT,
    source_percentage_snapshot NUMERIC(5,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_lurah_component UNIQUE (lurah_calculation_id, source_employee_id)
);

CREATE INDEX IF NOT EXISTS idx_tukin_calc_components_source_employee 
    ON public.tukin_calculation_components(source_employee_id);

-- ============================================================
-- 5. TRIGGERS (UPDATED_AT)
-- ============================================================
DROP TRIGGER IF EXISTS trg_set_tukin_periods_updated_at ON public.tukin_periods;
CREATE TRIGGER trg_set_tukin_periods_updated_at
    BEFORE UPDATE ON public.tukin_periods
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_set_tukin_calculations_updated_at ON public.tukin_calculations;
CREATE TRIGGER trg_set_tukin_calculations_updated_at
    BEFORE UPDATE ON public.tukin_calculations
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 6. SECURITY & PRIVILEGE RESTRICTION
-- ============================================================
REVOKE DELETE ON public.tukin_periods FROM authenticated;
REVOKE DELETE ON public.tukin_calculations FROM authenticated;
REVOKE DELETE ON public.tukin_calculation_components FROM authenticated;

REVOKE INSERT, UPDATE ON public.tukin_calculations FROM authenticated;
REVOKE INSERT, UPDATE ON public.tukin_calculation_components FROM authenticated;
