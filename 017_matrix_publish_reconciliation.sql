-- Migration 017: Matrix Publish Authorization Reconciliation
-- Deskripsi: Memperbaiki kesalahan kontrak otorisasi publish matrix dari Lurah menjadi Carik
-- sesuai dengan Authoritative Application Rule.
-- Prerequisite: 014_rpc_functions.sql

-- ============================================================
-- 1. MATRIX PUBLISH WORKFLOW RPC (CARIK ONLY)
-- ============================================================
CREATE OR REPLACE FUNCTION public.publish_matrix_version(
    p_matrix_version_id UUID,
    p_effective_from DATE DEFAULT CURRENT_DATE
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_target_matrix RECORD;
    v_group_count INTEGER;
    v_item_count INTEGER;
    v_current_published_id UUID;
BEGIN
    -- UBAH: Otorisasi sekarang menggunakan fn_is_carik()
    IF NOT public.fn_is_carik() THEN
        RAISE EXCEPTION 'Unauthorized: Only Carik can publish matrix versions.' USING ERRCODE = '42501';
    END IF;

    IF p_effective_from IS NULL THEN
        RAISE EXCEPTION 'effective_from date cannot be null.' USING ERRCODE = '22004';
    END IF;

    -- 1. Lock target matrix row
    SELECT * INTO v_target_matrix
    FROM public.matrix_versions
    WHERE id = p_matrix_version_id
    FOR UPDATE;

    IF v_target_matrix IS NULL THEN
        RAISE EXCEPTION 'Matrix version not found.' USING ERRCODE = 'P0002';
    END IF;

    IF v_target_matrix.status <> 'Review'::public.matrix_version_status THEN
        RAISE EXCEPTION 'Matrix version must be in Review status to be published (current: %).', 
v_target_matrix.status USING ERRCODE = '22000';
    END IF;

    -- 2. Validasi kelengkapan: Wajib punya minimal 1 group & 1 item
    SELECT count(*) INTO v_group_count
    FROM public.performance_groups
    WHERE matrix_version_id = p_matrix_version_id;

    SELECT count(*) INTO v_item_count
    FROM public.performance_items pi
    JOIN public.performance_groups pg ON pg.id = pi.group_id
    WHERE pg.matrix_version_id = p_matrix_version_id;

    IF v_group_count = 0 OR v_item_count = 0 THEN
        RAISE EXCEPTION 'Cannot publish empty matrix version without groups or items.' USING ERRCODE = '22000';
    END IF;

    -- 3. Cari current Published matrix untuk posisi yang sama
    SELECT id INTO v_current_published_id
    FROM public.matrix_versions
    WHERE position_id = v_target_matrix.position_id
      AND status = 'Published'::public.matrix_version_status
      AND effective_from <= p_effective_from
      AND (effective_to IS NULL OR p_effective_from < effective_to)
    FOR UPDATE;

    -- 4. Jika current Published matrix ditemukan, kunci (Locked) dan set effective_to
    IF v_current_published_id IS NOT NULL THEN
        UPDATE public.matrix_versions
        SET status = 'Locked'::public.matrix_version_status,
            effective_to = p_effective_from,
            updated_at = now()
        WHERE id = v_current_published_id;
    END IF;

    -- 5. Publish target matrix
    UPDATE public.matrix_versions
    SET status = 'Published'::public.matrix_version_status,
        effective_from = p_effective_from,
        effective_to = NULL,
        updated_at = now()
    WHERE id = p_matrix_version_id;

END;
$$;

-- Pastikan izin eksekusi tetap ada
REVOKE EXECUTE ON FUNCTION public.publish_matrix_version(UUID, DATE) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.publish_matrix_version(UUID, DATE) TO authenticated;
