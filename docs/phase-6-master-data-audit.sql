-- PHASE 6.5 PRODUCTION MASTER DATA RECONCILIATION
-- READ-ONLY AUDIT SCRIPT

-- 1. SCHEMA INVENTORY
SELECT table_schema, table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- 2. POSITIONS
SELECT id, name, is_pamong_tukin_eligible 
FROM public.positions 
ORDER BY name;

-- 3. EMPLOYEES
SELECT e.id, p.full_name, p.role, e.nip_nipt 
FROM public.employees e 
JOIN public.profiles p ON p.id = e.profile_id 
ORDER BY p.full_name;

-- 4. ACTIVE POSITION ASSIGNMENTS
SELECT p.full_name, pos.name AS position_name, epa.status, epa.effective_from, epa.effective_to 
FROM public.employee_position_assignments epa 
JOIN public.employees e ON e.id = epa.employee_id 
JOIN public.profiles p ON p.id = e.profile_id 
JOIN public.positions pos ON pos.id = epa.position_id 
WHERE epa.status = 'active' 
ORDER BY pos.name, p.full_name;

-- 5. BUMSKAL CHECK
SELECT table_schema, table_name 
FROM information_schema.tables 
WHERE lower(table_name) LIKE '%bamuskal%';

SELECT name 
FROM public.positions 
WHERE lower(name) LIKE '%bamuskal%';

-- 6. VILLAGE SETTINGS
SELECT setting_key, setting_value 
FROM public.village_settings 
ORDER BY setting_key;

-- 7. TUKIN PARAMETERS
SELECT pos.name AS position_name, tp.pagu_tukin, tp.min_ckb_target, tp.effective_from, tp.effective_to 
FROM public.tukin_parameters tp 
JOIN public.positions pos ON pos.id = tp.position_id 
WHERE tp.effective_from <= DATE '2027-01-01' 
  AND (tp.effective_to IS NULL OR tp.effective_to > DATE '2027-01-01') 
ORDER BY pos.name;

-- 8. MATRIX VERSIONS
SELECT pos.name AS position_name, mv.version_number, mv.status, mv.effective_from, mv.effective_to 
FROM public.matrix_versions mv 
JOIN public.positions pos ON pos.id = mv.position_id 
WHERE mv.status = 'Published' 
ORDER BY pos.name;

-- 9. MATRIX ITEM / TARGET INTEGRITY
SELECT pos.name AS position_name, COUNT(DISTINCT pg.id) AS group_count, COUNT(DISTINCT pi.id) AS item_count, COUNT(DISTINCT pt.item_id) AS target_count 
FROM public.matrix_versions mv 
JOIN public.positions pos ON pos.id = mv.position_id 
JOIN public.performance_groups pg ON pg.matrix_version_id = mv.id 
JOIN public.performance_items pi ON pi.group_id = pg.id 
LEFT JOIN public.performance_targets pt ON pt.item_id = pi.id 
WHERE mv.status = 'Published' 
GROUP BY pos.name 
ORDER BY pos.name;

-- 10. WORKFLOW ENUM / STATUS
SELECT t.typname, string_agg(e.enumlabel, ', ' ORDER BY e.enumsortorder) AS enum_values
FROM pg_type t
JOIN pg_enum e ON t.oid = e.enumtypid
WHERE t.typname IN ('journal_status', 'matrix_version_status', 'tukin_period_status', 'app_profile_role')
GROUP BY t.typname;
