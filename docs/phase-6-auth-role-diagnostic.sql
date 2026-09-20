-- PHASE 6.4.1 DIAGNOSTIC: Verify auth schema helpers
SELECT n.nspname AS schema_name, p.proname AS function_name, pg_get_function_identity_arguments(p.oid) AS arguments, pg_get_function_result(p.oid) AS return_type FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace WHERE n.nspname = 'auth' AND p.proname IN ('uid', 'role', 'jwt') ORDER BY p.proname;
