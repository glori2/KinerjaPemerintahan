-- Migration 011: Audit Logging
-- Deskripsi: Infrastruktur audit trail append-only dan generic trigger pencatatan.
-- Prerequisite:
-- - 001_extensions_and_types.sql (enum audit_actor_type, audit_action)
-- - 002_core_auth.sql (public.profiles)

-- ============================================================
-- 1. AUDIT LOGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_type public.audit_actor_type NOT NULL,
    actor_profile_id UUID NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    action public.audit_action NOT NULL,
    entity_type VARCHAR NOT NULL,
    entity_id UUID NOT NULL,
    before_snapshot JSONB NULL,
    after_snapshot JSONB NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_audit_actor CHECK (
        (actor_type = 'USER' AND actor_profile_id IS NOT NULL) OR
        (actor_type = 'SYSTEM' AND actor_profile_id IS NULL)
    )
);

-- Index Pencarian
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON public.audit_logs(actor_profile_id, created_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON public.audit_logs(entity_type, entity_id, created_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at);

-- ============================================================
-- 2. PRIVILEGE RESTRICTION (APPEND-ONLY DARI SISI CLIENT)
-- ============================================================
REVOKE INSERT, UPDATE, DELETE ON public.audit_logs FROM authenticated;

-- ============================================================
-- 3. GENERIC AUDIT TRIGGER FUNCTION
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_audit_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_actor_type public.audit_actor_type;
    v_actor_profile_id UUID;
    v_uid UUID;
    v_entity_id UUID;
    v_before JSONB := NULL;
    v_after JSONB := NULL;
    v_action public.audit_action;
BEGIN
    -- Menentukan actor berdasarkan auth.uid()
    v_uid := auth.uid();
    
    IF v_uid IS NOT NULL THEN
        -- Memastikan uid terdaftar di tabel profiles
        SELECT id INTO v_actor_profile_id 
        FROM public.profiles 
        WHERE id = v_uid;
        
        IF v_actor_profile_id IS NOT NULL THEN
            v_actor_type := 'USER'::public.audit_actor_type;
        ELSE
            RAISE EXCEPTION 'Audit failed: Authenticated user profile not found.' USING ERRCODE = '42501';
        END IF;
    ELSE
        v_actor_type := 'SYSTEM'::public.audit_actor_type;
        v_actor_profile_id := NULL;
    END IF;

    -- Menentukan data action dan snapshot
    IF TG_OP = 'INSERT' THEN
        v_action := 'INSERT'::public.audit_action;
        v_after := to_jsonb(NEW);
        v_entity_id := NEW.id;
    ELSIF TG_OP = 'UPDATE' THEN
        v_action := 'UPDATE'::public.audit_action;
        v_before := to_jsonb(OLD);
        v_after := to_jsonb(NEW);
        v_entity_id := NEW.id;
    ELSIF TG_OP = 'DELETE' THEN
        v_action := 'DELETE'::public.audit_action;
        v_before := to_jsonb(OLD);
        v_entity_id := OLD.id;
    END IF;

    -- Mencatat log tanpa loop rekursif, asalkan trigger ini 
    -- TIDAK dipasang di public.audit_logs itu sendiri.
    INSERT INTO public.audit_logs (
        actor_type,
        actor_profile_id,
        action,
        entity_type,
        entity_id,
        before_snapshot,
        after_snapshot
    ) VALUES (
        v_actor_type,
        v_actor_profile_id,
        v_action,
        TG_TABLE_NAME::VARCHAR,
        v_entity_id,
        v_before,
        v_after
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.fn_audit_trigger() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.fn_audit_trigger() FROM authenticated;
