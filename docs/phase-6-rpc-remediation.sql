-- PHASE 6.4 CRITICAL RPC PRIVILEGE REMEDIATION

-- PART 1: REVOKE FROM PUBLIC, ANON, & AUTHENTICATED

REVOKE EXECUTE ON FUNCTION public.provision_employee_identity(uuid, app_profile_role, character varying, character varying, uuid, date) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.provision_employee_identity(uuid, app_profile_role, character varying, character varying, uuid, date) FROM anon;
REVOKE EXECUTE ON FUNCTION public.provision_employee_identity(uuid, app_profile_role, character varying, character varying, uuid, date) FROM authenticated;

REVOKE EXECUTE ON FUNCTION public.generate_calculations(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.generate_calculations(uuid) FROM anon;

REVOKE EXECUTE ON FUNCTION public.create_journal(uuid, date, time without time zone, time without time zone, integer, character varying, text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.create_journal(uuid, date, time without time zone, time without time zone, integer, character varying, text) FROM anon;

REVOKE EXECUTE ON FUNCTION public.update_journal(uuid, uuid, date, time without time zone, time without time zone, integer, character varying, text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.update_journal(uuid, uuid, date, time without time zone, time without time zone, integer, character varying, text) FROM anon;

REVOKE EXECUTE ON FUNCTION public.submit_journal(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.submit_journal(uuid) FROM anon;

REVOKE EXECUTE ON FUNCTION public.approve_journal(uuid, integer, numeric, text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.approve_journal(uuid, integer, numeric, text) FROM anon;

REVOKE EXECUTE ON FUNCTION public.return_journal(uuid, text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.return_journal(uuid, text) FROM anon;

REVOKE EXECUTE ON FUNCTION public.publish_matrix_version(uuid, date) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.publish_matrix_version(uuid, date) FROM anon;


-- PART 2: HARDEN DEFAULT PRIVILEGES
-- Prevent future functions created by db admins from implicitly granting EXECUTE to anon or authenticated.

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM authenticated;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM authenticated;


-- PART 3: AUDIT AFTER REMEDIATION (READ-ONLY)

SELECT
    n.nspname AS schema_name,
    p.proname AS function_name,
    p.proacl,
    p.prosecdef,
    p.proconfig
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
AND p.proname IN (
    'create_journal',
    'update_journal',
    'submit_journal',
    'approve_journal',
    'return_journal',
    'generate_calculations',
    'publish_matrix_version',
    'provision_employee_identity'
)
ORDER BY p.proname;

SELECT
    routine_schema,
    routine_name,
    grantee,
    privilege_type
FROM information_schema.routine_privileges
WHERE routine_schema = 'public'
  AND routine_name IN (
      'create_journal',
      'update_journal',
      'submit_journal',
      'approve_journal',
      'return_journal',
      'generate_calculations',
      'publish_matrix_version',
      'provision_employee_identity'
  )
ORDER BY routine_name, grantee, privilege_type;
