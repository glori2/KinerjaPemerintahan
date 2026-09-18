-- ============================================================
-- 002_core_auth.sql
-- Sistem Manajemen Kinerja & Presensi Pemerintah Kalurahan
-- Baseline: IMPLEMENTATION SPECIFICATION FINAL V3.2.2.4
--
-- Scope:
--   - public.profiles
--   - public.positions
--   - public.employees
--   - Defense-in-depth triggers for immutable columns
--   - Strict GRANT / REVOKE restrictions against direct client mutation
--
-- Prerequisites:
--   - 001_extensions_and_types.sql (app_profile_role enum, extensions)
--
-- This migration intentionally does NOT create:
--   - public.provision_employee_identity() (deferred to 014_rpc_functions.sql)
--   - Full RLS policies (deferred to 013_rls_and_privileges.sql)
--   - Seed data (deferred to 015_seed_kalidengen.sql)
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. Table: public.profiles
-- ------------------------------------------------------------
-- Represents authoritative user profile tied 1:1 to auth.users.
-- Client INSERT is prohibited; identity provisioning is exclusively
-- executed via Trusted Provisioning.
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE RESTRICT,
    role public.app_profile_role NOT NULL,
    full_name VARCHAR NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------
-- 2. Table: public.positions
-- ------------------------------------------------------------
-- Official government position master data.
-- Specific positions will be seeded in migration 015.
CREATE TABLE IF NOT EXISTS public.positions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR NOT NULL UNIQUE,
    is_pamong_tukin_eligible BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------
-- 3. Table: public.employees
-- ------------------------------------------------------------
-- Represents the employee identity, strictly bound 1:1 to a profile.
-- profile_id is immutable after creation.
CREATE TABLE IF NOT EXISTS public.employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE RESTRICT,
    nip_nipt VARCHAR NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------
-- 4. Generic updated_at Trigger Function
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_set_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_set_positions_updated_at ON public.positions;
CREATE TRIGGER trg_set_positions_updated_at
    BEFORE UPDATE ON public.positions
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_set_employees_updated_at ON public.employees;
CREATE TRIGGER trg_set_employees_updated_at
    BEFORE UPDATE ON public.employees
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

-- ------------------------------------------------------------
-- 5. Defense-in-Depth Triggers for Immutable Columns
-- ------------------------------------------------------------

-- Enforce that profiles.role cannot be modified directly via UPDATE.
CREATE OR REPLACE FUNCTION public.enforce_profile_role_immutable()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public
AS $$
BEGIN
    IF NEW.role IS DISTINCT FROM OLD.role THEN
        RAISE EXCEPTION 'Direct modification of profiles.role is prohibited.'
            USING ERRCODE = '42501';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_protect_profile_role ON public.profiles;
CREATE TRIGGER trg_protect_profile_role
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_profile_role_immutable();

-- Enforce that employees.profile_id cannot be reassigned via UPDATE.
CREATE OR REPLACE FUNCTION public.enforce_employee_profile_id_immutable()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public
AS $$
BEGIN
    IF NEW.profile_id IS DISTINCT FROM OLD.profile_id THEN
        RAISE EXCEPTION 'Direct modification of employees.profile_id is prohibited.'
            USING ERRCODE = '42501';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_protect_employee_profile_id ON public.employees;
CREATE TRIGGER trg_protect_employee_profile_id
    BEFORE UPDATE ON public.employees
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_employee_profile_id_immutable();

-- ------------------------------------------------------------
-- 6. Privilege Restrictions (GRANT / REVOKE)
-- ------------------------------------------------------------
-- Explicitly revoke direct mutation rights on identity tables from authenticated clients.
-- Provisioning rights will be granted exclusively to trusted service contexts.

REVOKE INSERT ON public.profiles FROM authenticated;
REVOKE INSERT ON public.employees FROM authenticated;

REVOKE UPDATE (role) ON public.profiles FROM authenticated;
REVOKE UPDATE (profile_id) ON public.employees FROM authenticated;

REVOKE DELETE ON public.profiles FROM authenticated;
REVOKE DELETE ON public.employees FROM authenticated;
REVOKE DELETE ON public.positions FROM authenticated;

COMMIT;
