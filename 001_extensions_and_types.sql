-- ============================================================
-- 001_extensions_and_types.sql
-- Sistem Manajemen Kinerja & Presensi Pemerintah Kalurahan
-- Baseline: IMPLEMENTATION SPECIFICATION FINAL V3.2.2.4
--
-- Scope:
--   - PostgreSQL extensions required by the specification
--   - Shared enum/domain types used by later migrations
--
-- This migration intentionally does NOT create application tables,
-- RLS policies, RPCs, storage policies, or seed data.
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. Required PostgreSQL extensions
-- ------------------------------------------------------------

-- UUID generation / cryptographic helpers.
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Required for GiST exclusion constraints combining equality
-- and range operators used by:
-- employee assignments, Tukin parameters, published matrices,
-- and performance journal time ranges.
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- ------------------------------------------------------------
-- 2. Shared enum types
-- ------------------------------------------------------------
-- These types mirror the fixed status vocabularies in V3.2.2.4.
-- Business rules that remain deferred are NOT encoded here.

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
          AND t.typname = 'app_profile_role'
    ) THEN
        CREATE TYPE public.app_profile_role AS ENUM ('admin', 'user');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
          AND t.typname = 'position_assignment_status'
    ) THEN
        CREATE TYPE public.position_assignment_status AS ENUM ('active', 'inactive');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
          AND t.typname = 'matrix_version_status'
    ) THEN
        CREATE TYPE public.matrix_version_status AS ENUM ('Draft', 'Review', 'Published', 'Locked');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
          AND t.typname = 'permission_type'
    ) THEN
        CREATE TYPE public.permission_type AS ENUM ('cuti', 'izin', 'sakit', 'lainnya');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
          AND t.typname = 'workflow_status'
    ) THEN
        CREATE TYPE public.workflow_status AS ENUM ('Draft', 'Submitted', 'Approved', 'Rejected');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
          AND t.typname = 'journal_status'
    ) THEN
        CREATE TYPE public.journal_status AS ENUM (
            'Draft',
            'Submitted',
            'Verified',
            'Returned',
            'Approved',
            'Locked'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
          AND t.typname = 'tukin_period_status'
    ) THEN
        CREATE TYPE public.tukin_period_status AS ENUM ('Draft', 'Locked');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
          AND t.typname = 'tukin_formula_role'
    ) THEN
        CREATE TYPE public.tukin_formula_role AS ENUM ('Pamong', 'Lurah');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
          AND t.typname = 'audit_actor_type'
    ) THEN
        CREATE TYPE public.audit_actor_type AS ENUM ('USER', 'SYSTEM');
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
          AND t.typname = 'audit_action'
    ) THEN
        CREATE TYPE public.audit_action AS ENUM (
            'INSERT',
            'UPDATE',
            'DELETE',
            'STATE_TRANSITION'
        );
    END IF;
END
$$;

COMMIT;
