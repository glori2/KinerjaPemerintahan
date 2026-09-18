import re

with open('015_seed_kalidengen_fixed.sql', 'r', encoding='utf-8') as f:
    sql = f.read()

new_validation_block = """-- 7. FINAL SEED VALIDATION
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    -- 1. Exact 9 positions
    SELECT COUNT(*) INTO v_count FROM public.positions;
    IF v_count <> 9 THEN
        RAISE EXCEPTION 'Seed validation failed: expected exactly 9 positions, found %.', v_count;
    END IF;

    -- Active assignments count
    SELECT COUNT(*) INTO v_count
    FROM public.employees e
    JOIN public.employee_position_assignments a ON a.employee_id = e.id
    WHERE a.status = 'active'
      AND a.effective_from = '2027-01-01'::DATE;
    IF v_count <> 10 THEN
        RAISE EXCEPTION 'Seed validation failed: expected 10 active employee assignments for 2027-01-01, found %.', v_count;
    END IF;

    -- Published matrices count
    SELECT COUNT(*) INTO v_count
    FROM public.matrix_versions
    WHERE effective_from = '2027-01-01'::DATE
      AND status = 'Published'::public.matrix_version_status;
    IF v_count <> 8 THEN
        RAISE EXCEPTION 'Seed validation failed: expected 8 published matrix versions for 2027-01-01, found %.', v_count;
    END IF;

    -- Empty group checks
    IF EXISTS (SELECT 1 FROM public.performance_groups WHERE btrim(name) = '') THEN
        RAISE EXCEPTION 'Seed validation failed: empty performance group remains.';
    END IF;
    IF EXISTS (SELECT 1 FROM public.performance_groups WHERE btrim(name) = 'b') THEN
        RAISE EXCEPTION 'Seed validation failed: artifact performance group ''b'' remains.';
    END IF;

    -- 2. Bamuskal Check
    SELECT COUNT(*) INTO v_count FROM public.positions WHERE name ILIKE '%Bamuskal%';
    IF v_count > 0 THEN
        RAISE EXCEPTION 'Validation failed: Bamuskal position found.';
    END IF;
    SELECT COUNT(*) INTO v_count FROM public.employee_position_assignments a JOIN public.positions p ON a.position_id = p.id WHERE p.name ILIKE '%Bamuskal%';
    IF v_count > 0 THEN
        RAISE EXCEPTION 'Validation failed: Bamuskal assignment found.';
    END IF;

    -- 3. Role-Position Validation
    IF EXISTS (
        SELECT 1 FROM public.employees e
        JOIN public.profiles pr ON pr.id = e.profile_id
        JOIN public.employee_position_assignments a ON a.employee_id = e.id
        JOIN public.positions p ON p.id = a.position_id
        WHERE a.status = 'active'
          AND (
              (p.name = 'Carik' AND pr.role <> 'admin'::public.app_profile_role)
              OR (p.name <> 'Carik' AND pr.role = 'admin'::public.app_profile_role)
              OR (p.name = 'Lurah' AND pr.role <> 'user'::public.app_profile_role)
          )
    ) THEN
        RAISE EXCEPTION 'Role validation failed: mismatched admin/user roles.';
    END IF;

    -- 4. Item tanpa target
    IF EXISTS (
        SELECT 1 FROM public.performance_items pi
        LEFT JOIN public.performance_targets pt ON pt.item_id = pi.id
        WHERE pt.id IS NULL
    ) THEN
        RAISE EXCEPTION 'Validation failed: found item without target.';
    END IF;

    -- 5. Active assignment overlap / duplicate
    IF EXISTS (
        SELECT employee_id
        FROM public.employee_position_assignments
        WHERE status = 'active' AND effective_from = '2027-01-01'::DATE
        GROUP BY employee_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Validation failed: duplicate active assignments found for an employee.';
    END IF;

    -- 6. Dukuh matrix count
    SELECT COUNT(*) INTO v_count
    FROM public.matrix_versions mv
    JOIN public.positions p ON mv.position_id = p.id
    WHERE p.name = 'Dukuh' AND mv.effective_from = '2027-01-01'::DATE AND mv.status = 'Published'::public.matrix_version_status;
    IF v_count <> 1 THEN
        RAISE EXCEPTION 'Validation failed: Expected 1 Dukuh matrix, found %', v_count;
    END IF;

    -- 7. Staf active employee check
    SELECT COUNT(*) INTO v_count
    FROM public.employees e
    JOIN public.employee_position_assignments a ON a.employee_id = e.id
    JOIN public.positions p ON p.id = a.position_id
    WHERE p.name = 'Staf' AND a.status = 'active';
    IF v_count <> 0 THEN
        RAISE EXCEPTION 'Validation failed: found active Staf employee.';
    END IF;

    -- 8. Duplicate Published matrix check
    IF EXISTS (
        SELECT position_id
        FROM public.matrix_versions
        WHERE status = 'Published'::public.matrix_version_status AND effective_from = '2027-01-01'::DATE
        GROUP BY position_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Validation failed: duplicate published matrices for the same position.';
    END IF;

END $$;

COMMIT;"""

# Replace the old validation block
target_start = "-- 7. FINAL SEED VALIDATION"
if target_start in sql:
    sql = sql[:sql.find(target_start)] + new_validation_block
    with open('015_seed_kalidengen_fixed.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    print("Validation block replaced.")
else:
    print("Could not find validation block.")
