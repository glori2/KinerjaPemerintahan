-- PHASE 6 PRODUCTION AUDIT SCRIPT  
-- RUN THIS SCRIPT IN SUPABASE SQL EDITOR  
-- READ-ONLY, SAFE VERIFICATION  
SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;  
SELECT routine_schema, routine_name, routine_type FROM information_schema.routines WHERE routine_schema = 'public' ORDER BY routine_name;  
SELECT version, name FROM supabase_migrations.schema_migrations ORDER BY version;  
SELECT (SELECT count(*) FROM positions) AS positions_count, (SELECT count(*) FROM employees) AS employees_count, (SELECT count(*) FROM employee_position_assignments WHERE is_active = true) AS active_assignments_count, (SELECT count(*) FROM matrix_versions WHERE status = 'Published') AS published_matrices_count;  
SELECT p.name as position_name, count(*) as active_count FROM employee_position_assignments epa JOIN positions p ON epa.position_id = p.id WHERE epa.is_active = true GROUP BY p.name;  
SELECT pr.full_name, p.name as position_name, pr.role FROM profiles pr JOIN employees e ON e.profile_id = pr.id JOIN employee_position_assignments epa ON e.id = epa.employee_id JOIN positions p ON epa.position_id = p.id WHERE epa.is_active = true ORDER BY p.name;  
SELECT p.name as position_name, mv.version_name, mv.status, mv.effective_start_date, mv.effective_end_date FROM matrix_versions mv JOIN positions p ON mv.position_id = p.id WHERE mv.status = 'Published' ORDER BY p.name;  
SELECT mi.item_name, mit.target_score FROM matrix_items mi JOIN matrix_item_targets mit ON mi.id = mit.item_id LIMIT 10;  
SELECT p.name as position_name, tp.pagu_tukin, tp.minimum_target, tp.effective_date FROM tukin_parameters tp JOIN positions p ON tp.position_id = p.id WHERE tp.effective_date <= '2027-01-01' ORDER BY tp.effective_date DESC;  
SELECT setting_value FROM village_settings WHERE setting_key = 'working_days';  
SELECT proname, prosrc FROM pg_proc WHERE proname IN ('calculate_tukin', 'approve_journal', 'submit_journal', 'return_journal');  
SELECT schemaname, tablename, policyname, permissive, roles, cmd FROM pg_policies WHERE schemaname = 'public';  
SELECT name, public FROM storage.buckets WHERE name = 'evidence';  
SELECT policyname, tablename, cmd FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects'; 
