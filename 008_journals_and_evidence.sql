-- Migration 008: Journals and Evidence
-- Deskripsi: Menyimpan data jurnal kegiatan kinerja harian dan bukti (evidence) pendukungnya.
-- Prerequisite:
-- - 001_extensions_and_types.sql (enum journal_status, btree_gist)
-- - 002_core_auth.sql (public.employees, public.set_updated_at)
-- - 006_performance_matrix.sql (public.performance_items)

-- ============================================================
-- 1. PERFORMANCE JOURNALS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.performance_journals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES public.employees(id) ON DELETE RESTRICT,
    item_id UUID NOT NULL REFERENCES public.performance_items(id) ON DELETE RESTRICT,
    
    activity_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    
    matrix_version_id_snapshot UUID NOT NULL,
    group_name_snapshot VARCHAR NOT NULL,
    item_name_snapshot TEXT NOT NULL,
    target_snapshot INTEGER NOT NULL,
    unit_snapshot VARCHAR NOT NULL,
    
    realization INTEGER NOT NULL,
    location VARCHAR NOT NULL,
    note TEXT NULL,
    return_reason TEXT NULL,
    status public.journal_status NOT NULL,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_journal_time CHECK (start_time < end_time),
    
    CONSTRAINT ex_performance_journal_no_overlap EXCLUDE USING gist (
        employee_id WITH =,
        tsrange(
            (activity_date + start_time)::timestamp,
            (activity_date + end_time)::timestamp,
            '[)'
        ) WITH &&
    )
);

CREATE INDEX IF NOT EXISTS idx_journals_employee_id ON public.performance_journals(employee_id);
CREATE INDEX IF NOT EXISTS idx_journals_item_id ON public.performance_journals(item_id);
CREATE INDEX IF NOT EXISTS idx_journals_matrix_snapshot ON public.performance_journals(matrix_version_id_snapshot);

-- ============================================================
-- 2. JOURNAL EVIDENCE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.journal_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_id UUID NOT NULL REFERENCES public.performance_journals(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_name VARCHAR NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_evidence_journal_id ON public.journal_evidence(journal_id);

-- ============================================================
-- 3. TRIGGERS (UPDATED_AT)
-- ============================================================
DROP TRIGGER IF EXISTS trg_set_journals_updated_at ON public.performance_journals;
CREATE TRIGGER trg_set_journals_updated_at
    BEFORE UPDATE ON public.performance_journals
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 4. SECURITY & PRIVILEGE RESTRICTION
-- ============================================================
REVOKE DELETE ON public.performance_journals FROM authenticated;
REVOKE DELETE ON public.journal_evidence FROM authenticated;
