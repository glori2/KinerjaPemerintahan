import os

file_path = r'd:\dokumen\Projek\Presensi Tukin 2027\014_rpc_functions.sql'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

target = """CREATE OR REPLACE FUNCTION public.publish_matrix_version(
    p_matrix_version_id UUID,
    p_effective_from DATE DEFAULT CURRENT_DATE
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_status public.matrix_version_status;
    v_group_count INTEGER;
    v_item_count INTEGER;
BEGIN
    IF NOT public.fn_is_lurah() THEN
        RAISE EXCEPTION 'Unauthorized: Only Lurah can publish matrix versions.' USING ERRCODE = '42501';
    END IF;

    SELECT status INTO v_status
    FROM public.matrix_versions
    WHERE id = p_matrix_version_id;

    IF v_status IS NULL THEN
        RAISE EXCEPTION 'Matrix version not found.' USING ERRCODE = 'P0002';
    END IF;

    IF v_status <> 'Review'::public.matrix_version_status THEN
        RAISE EXCEPTION 'Matrix version must be in Review status to be published (current: %).', v_status USING ERRCODE = '22000';
    END IF;

    -- Validasi kelengkapan: Wajib punya minimal 1 group & 1 item
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

    UPDATE public.matrix_versions
    SET status = 'Published'::public.matrix_version_status,
        effective_from = p_effective_from,
        updated_at = now()
    WHERE id = p_matrix_version_id;
END;
$$;"""

repl = """CREATE OR REPLACE FUNCTION public.publish_matrix_version(
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
    IF NOT public.fn_is_lurah() THEN
        RAISE EXCEPTION 'Unauthorized: Only Lurah can publish matrix versions.' USING ERRCODE = '42501';
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
        RAISE EXCEPTION 'Matrix version must be in Review status to be published (current: %).', v_target_matrix.status USING ERRCODE = '22000';
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
$$;"""

if target in content:
    content = content.replace(target, repl)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Successfully replaced publish_matrix_version.")
else:
    print("Could not find the target string in the file.")
