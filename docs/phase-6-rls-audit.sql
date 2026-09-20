-- PHASE 6.3.4 RLS POLICY EXPRESSION AUDIT

-- QUERY 1: POLICY EXPRESSIONS
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual AS using_expression, with_check FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;

-- QUERY 2: RLS ENABLEMENT
SELECT n.nspname AS schema_name, c.relname AS table_name, c.relrowsecurity AS rls_enabled, c.relforcerowsecurity AS force_rls FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relkind = 'r' ORDER BY c.relname;

-- QUERY 3: FUNCTION PRIVILEGES
SELECT routine_schema, routine_name, grantee, privilege_type FROM information_schema.routine_privileges WHERE routine_schema = 'public' AND routine_name IN ('create_journal','update_journal','submit_journal','approve_journal','return_journal','generate_calculations','publish_matrix_version','provision_employee_identity') ORDER BY routine_name, grantee, privilege_type;
