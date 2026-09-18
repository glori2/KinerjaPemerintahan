-- Migration 012: Storage Security
-- Deskripsi: Menyiapkan private bucket untuk bukti (evidence) dan Supabase Storage RLS.
-- Prerequisite:
-- - 001_extensions_and_types.sql
-- - 002_core_auth.sql
-- - 008_journals_and_evidence.sql

-- ============================================================
-- 1. BUCKET CREATION (IDEMPOTENT)
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('evidence', 'evidence', false)
ON CONFLICT (id) DO UPDATE SET public = false;

-- ============================================================
-- 2. HELPER FUNCTIONS UNTUK STORAGE RLS
-- ============================================================
-- Object Path Format yang Diharapkan:
-- journal_id/filename.ext
-- Folder pertama dari object name harus berupa valid UUID dari public.performance_journals

CREATE OR REPLACE FUNCTION public.fn_can_modify_evidence(p_object_name TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_journal_id UUID;
    v_status public.journal_status;
    v_owner_profile_id UUID;
BEGIN
    -- Parsing journal_id dari object name
    BEGIN
        v_journal_id := split_part(p_object_name, '/', 1)::UUID;
    EXCEPTION WHEN invalid_text_representation THEN
        RETURN false;
    END;
    
    -- Mencari status jurnal dan owner
    SELECT pj.status, e.profile_id INTO v_status, v_owner_profile_id
    FROM public.performance_journals pj
    JOIN public.employees e ON e.id = pj.employee_id
    WHERE pj.id = v_journal_id;
    
    IF NOT FOUND THEN 
        RETURN false; 
    END IF;
    
    -- Autorisasi Owner
    IF v_owner_profile_id != auth.uid() THEN 
        RETURN false; 
    END IF;
    
    -- Pengecekan Status: Immutability mulai Submitted
    IF v_status IN ('Draft'::public.journal_status, 'Returned'::public.journal_status) THEN
        RETURN true;
    END IF;
    
    RETURN false;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.fn_can_modify_evidence(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_can_modify_evidence(TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.fn_can_read_evidence(p_object_name TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_journal_id UUID;
    v_owner_profile_id UUID;
BEGIN
    BEGIN
        v_journal_id := split_part(p_object_name, '/', 1)::UUID;
    EXCEPTION WHEN invalid_text_representation THEN
        RETURN false;
    END;
    
    SELECT e.profile_id INTO v_owner_profile_id
    FROM public.performance_journals pj
    JOIN public.employees e ON e.id = pj.employee_id
    WHERE pj.id = v_journal_id;
    
    IF NOT FOUND THEN 
        RETURN false; 
    END IF;
    
    -- Untuk saat ini, hanya owner yang dapat membaca. 
    -- Akses untuk evaluator akan ditambahkan di RLS migration berikutnya.
    IF v_owner_profile_id = auth.uid() THEN 
        RETURN true; 
    END IF;
    
    RETURN false;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.fn_can_read_evidence(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_can_read_evidence(TEXT) TO authenticated;

-- ============================================================
-- 3. STORAGE POLICIES
-- ============================================================
-- Pastikan RLS aktif untuk tabel storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "evidence_select_policy" ON storage.objects;
CREATE POLICY "evidence_select_policy" ON storage.objects
    FOR SELECT TO authenticated 
    USING (bucket_id = 'evidence' AND public.fn_can_read_evidence(name));

DROP POLICY IF EXISTS "evidence_insert_policy" ON storage.objects;
CREATE POLICY "evidence_insert_policy" ON storage.objects
    FOR INSERT TO authenticated 
    WITH CHECK (bucket_id = 'evidence' AND public.fn_can_modify_evidence(name));

DROP POLICY IF EXISTS "evidence_update_policy" ON storage.objects;
CREATE POLICY "evidence_update_policy" ON storage.objects
    FOR UPDATE TO authenticated 
    USING (bucket_id = 'evidence' AND public.fn_can_modify_evidence(name));

DROP POLICY IF EXISTS "evidence_delete_policy" ON storage.objects;
CREATE POLICY "evidence_delete_policy" ON storage.objects
    FOR DELETE TO authenticated 
    USING (bucket_id = 'evidence' AND public.fn_can_modify_evidence(name));
