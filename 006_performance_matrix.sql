-- Migration 006: Performance Matrix
-- Deskripsi: Struktur master untuk template kinerja per jabatan.
-- Prerequisite:
-- - 001_extensions_and_types.sql (enum app_profile_role, btree_gist)
-- - 002_core_auth.sql (public.positions, public.set_updated_at)

-- ============================================================
-- 1. MATRIX VERSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.matrix_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    position_id UUID NOT NULL REFERENCES public.positions(id) ON DELETE RESTRICT,
    version_number INTEGER NOT NULL,
    status public.matrix_version_status NOT NULL,
    effective_from DATE NULL,
    effective_to DATE NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_matrix_version UNIQUE (position_id, version_number),

    CONSTRAINT chk_matrix_effective_dates CHECK (
        effective_to IS NULL OR effective_to > effective_from
    ),

    CONSTRAINT chk_matrix_published_effective_from CHECK (
        status IN ('Draft', 'Review')
        OR (status IN ('Published', 'Locked') AND effective_from IS NOT NULL)
    ),

    CONSTRAINT ex_matrix_published_no_overlap EXCLUDE USING gist (
        position_id WITH =,
        daterange(
            effective_from,
            coalesce(effective_to, 'infinity'::date),
            '[)'
        ) WITH &&
    ) WHERE (status = 'Published')
);

-- ============================================================
-- 2. PERFORMANCE GROUPS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.performance_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matrix_version_id UUID NOT NULL REFERENCES public.matrix_versions(id) ON DELETE RESTRICT,
    name VARCHAR NOT NULL,
    order_number INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_performance_groups_matrix_version_id 
    ON public.performance_groups(matrix_version_id);

-- ============================================================
-- 3. PERFORMANCE ITEMS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.performance_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.performance_groups(id) ON DELETE RESTRICT,
    name TEXT NOT NULL,
    unit VARCHAR NOT NULL,
    order_number INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_performance_items_group_id 
    ON public.performance_items(group_id);

-- ============================================================
-- 4. PERFORMANCE TARGETS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.performance_targets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL UNIQUE REFERENCES public.performance_items(id) ON DELETE RESTRICT,
    annual_target INTEGER NOT NULL,
    monthly_target INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Note: item_id already has UNIQUE constraint, which implies an index.

-- ============================================================
-- 5. TRIGGERS (UPDATED_AT)
-- ============================================================
DROP TRIGGER IF EXISTS trg_set_matrix_versions_updated_at ON public.matrix_versions;
CREATE TRIGGER trg_set_matrix_versions_updated_at
    BEFORE UPDATE ON public.matrix_versions
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_set_performance_groups_updated_at ON public.performance_groups;
CREATE TRIGGER trg_set_performance_groups_updated_at
    BEFORE UPDATE ON public.performance_groups
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_set_performance_items_updated_at ON public.performance_items;
CREATE TRIGGER trg_set_performance_items_updated_at
    BEFORE UPDATE ON public.performance_items
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_set_performance_targets_updated_at ON public.performance_targets;
CREATE TRIGGER trg_set_performance_targets_updated_at
    BEFORE UPDATE ON public.performance_targets
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- 6. SECURITY & PRIVILEGE RESTRICTION
-- ============================================================
REVOKE DELETE ON public.matrix_versions FROM authenticated;
REVOKE DELETE ON public.performance_groups FROM authenticated;
REVOKE DELETE ON public.performance_items FROM authenticated;
REVOKE DELETE ON public.performance_targets FROM authenticated;
