-- PHASE 6.3.7 FUNCTION ACL & INTERNAL AUTHORIZATION AUDIT

SELECT n.nspname AS schema_name, p.proname AS function_name, pg_get_function_identity_arguments(p.oid) AS identity_arguments, p.proacl AS function_acl, p.prosecdef AS security_definer, p.proconfig AS config, p.prosrc AS source_definition FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace WHERE n.nspname = 'public' AND p.proname IN ('create_journal', 'update_journal', 'submit_journal', 'approve_journal', 'return_journal', 'generate_calculations', 'publish_matrix_version', 'provision_employee_identity') ORDER BY p.proname;
