-- PHASE 6 PRODUCTION AUDIT SCRIPT  
-- RUN THIS SCRIPT IN SUPABASE SQL EDITOR  
SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;  
SELECT routine_schema, routine_name, routine_type FROM information_schema.routines WHERE routine_schema = 'public' ORDER BY routine_name;  
SELECT (SELECT count(*) FROM positions) AS positions_count, (SELECT count(*) FROM employees) AS employees_count, (SELECT count(*) FROM employee_position_assignments WHERE status = 'active') AS active_assignments_count, (SELECT count(*) FROM matrix_versions WHERE status = 'Published') AS published_matrices_count;  
SELECT p.name as position_name, count(*) as active_count FROM employee_position_assignments epa JOIN positions p ON epa.position_id = p.id WHERE epa.status = 'active' GROUP BY p.name;  
SELECT pr.full_name, p.name as position_name, pr.role FROM profiles pr JOIN employees e ON e.profile_id = pr.id JOIN employee_position_assignments epa ON e.id = epa.employee_id JOIN positions p ON epa.position_id = p.id WHERE epa.status = 'active' ORDER BY p.name;  
SELECT p.name as position_name, mv.version_name, mv.status, mv.effective_start_date, mv.effective_end_date FROM matrix_versions mv JOIN positions p ON mv.position_id = p.id WHERE mv.status = 'Published' ORDER BY p.name;  
SELECT mi.item_name, mit.target_score FROM matrix_items mi JOIN matrix_item_targets mit ON mi.id = mit.item_id LIMIT 10;  
SELECT p.name as position_name, tp.pagu_tukin, tp.minimum_target, tp.effective_date FROM tukin_parameters tp JOIN positions p ON tp.position_id = p.id WHERE tp.effective_date <= '2027-01-01' ORDER BY tp.effective_date DESC;  
SELECT setting_value FROM village_settings WHERE setting_key = 'working_days';  
SELECT n.nspname AS schema, p.proname AS function_name, pg_get_function_arguments(p.oid) AS argument_signature, CASE WHEN p.prosecdef THEN 'DEFINER' ELSE 'INVOKER' END AS security_definition, p.proconfig AS search_path, p.prosrc AS source_definition FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace WHERE p.proname IN ('create_journal', 'update_journal', 'submit_journal', 'approve_journal', 'return_journal', 'generate_calculations', 'publish_matrix_version', 'provision_employee_identity') AND n.nspname = 'public';  
SELECT schemaname, tablename, policyname, permissive, roles, cmd FROM pg_policies WHERE schemaname = 'public';  
SELECT name, public FROM storage.buckets WHERE name = 'evidence';  
SELECT policyname, tablename, cmd FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects'; 
