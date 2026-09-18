-- Migration 013: RLS and Privileges
-- Deskripsi: Mengimplementasikan RLS final dan rule authorization sesuai Security Matrix V3.2.2.4.
-- Prerequisite: 001 - 012

-- ============================================================
-- 1. HELPER FUNCTIONS UNTUK MENCEGAH RLS RECURSION
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_is_carik()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_is_carik BOOLEAN := false;
BEGIN
    SELECT true INTO v_is_carik
    FROM public.profiles p
    JOIN public.employees e ON e.profile_id = p.id
    JOIN public.employee_position_assignments epa ON epa.employee_id = e.id
    JOIN public.positions pos ON pos.id = epa.position_id
    WHERE p.id = auth.uid()
      AND p.role = 'admin'
      AND epa.status = 'active'
      AND pos.name = 'Carik';
      
    RETURN coalesce(v_is_carik, false);
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_is_lurah()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_is_lurah BOOLEAN := false;
BEGIN
    SELECT true INTO v_is_lurah
    FROM public.employees e
    JOIN public.employee_position_assignments epa ON epa.employee_id = e.id
    JOIN public.positions pos ON pos.id = epa.position_id
    WHERE e.profile_id = auth.uid()
      AND epa.status = 'active'
      AND pos.name = 'Lurah';
      
    RETURN coalesce(v_is_lurah, false);
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_get_employee_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_employee_id UUID;
BEGIN
    SELECT id INTO v_employee_id 
    FROM public.employees 
    WHERE profile_id = auth.uid() 
    LIMIT 1;
    
    RETURN v_employee_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.fn_is_carik() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.fn_is_lurah() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.fn_get_employee_id() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_is_carik() TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_is_lurah() TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_get_employee_id() TO authenticated;

-- ============================================================
-- 2. ENABLE RLS
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_position_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.village_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tukin_parameters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matrix_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.performance_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.performance_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.performance_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.official_duties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.performance_journals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.disciplinary_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tukin_periods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tukin_calculations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tukin_calculation_components ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 3. PROFILES POLICIES
-- ============================================================
DROP POLICY IF EXISTS "profiles_select_self" ON public.profiles;
CREATE POLICY "profiles_select_self" ON public.profiles FOR SELECT TO authenticated USING (id = auth.uid());

DROP POLICY IF EXISTS "profiles_select_admin_lurah" ON public.profiles;
CREATE POLICY "profiles_select_admin_lurah" ON public.profiles FOR SELECT TO authenticated USING (public.fn_is_carik() OR public.fn_is_lurah());

DROP POLICY IF EXISTS "profiles_update_self" ON public.profiles;
CREATE POLICY "profiles_update_self" ON public.profiles FOR UPDATE TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "profiles_update_carik" ON public.profiles;
CREATE POLICY "profiles_update_carik" ON public.profiles FOR UPDATE TO authenticated
USING (public.fn_is_carik())
WITH CHECK (public.fn_is_carik());

-- ============================================================
-- 4. POSITIONS POLICIES
-- ============================================================
DROP POLICY IF EXISTS "positions_select_all" ON public.positions;
CREATE POLICY "positions_select_all" ON public.positions FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "positions_insert_carik" ON public.positions;
CREATE POLICY "positions_insert_carik" ON public.positions FOR INSERT TO authenticated WITH CHECK (public.fn_is_carik());

DROP POLICY IF EXISTS "positions_update_carik" ON public.positions;
CREATE POLICY "positions_update_carik" ON public.positions FOR UPDATE TO authenticated
USING (public.fn_is_carik())
WITH CHECK (public.fn_is_carik());

-- ============================================================
-- 5. EMPLOYEES POLICIES
-- ============================================================
DROP POLICY IF EXISTS "employees_select_self" ON public.employees;
CREATE POLICY "employees_select_self" ON public.employees FOR SELECT TO authenticated USING (profile_id = auth.uid());

DROP POLICY IF EXISTS "employees_select_carik_lurah" ON public.employees;
CREATE POLICY "employees_select_carik_lurah" ON public.employees FOR SELECT TO authenticated USING (public.fn_is_carik() OR public.fn_is_lurah());

DROP POLICY IF EXISTS "employees_update_self" ON public.employees;
CREATE POLICY "employees_update_self" ON public.employees FOR UPDATE TO authenticated
USING (profile_id = auth.uid())
WITH CHECK (profile_id = auth.uid());

DROP POLICY IF EXISTS "employees_update_carik" ON public.employees;
CREATE POLICY "employees_update_carik" ON public.employees FOR UPDATE TO authenticated
USING (public.fn_is_carik())
WITH CHECK (public.fn_is_carik());

-- ============================================================
-- 6. EMPLOYEE POSITION ASSIGNMENTS POLICIES
-- ============================================================
DROP POLICY IF EXISTS "assign_select_self" ON public.employee_position_assignments;
CREATE POLICY "assign_select_self" ON public.employee_position_assignments FOR SELECT TO authenticated USING (employee_id = public.fn_get_employee_id());

DROP POLICY IF EXISTS "assign_select_carik_lurah" ON public.employee_position_assignments;
CREATE POLICY "assign_select_carik_lurah" ON public.employee_position_assignments FOR SELECT TO authenticated USING (public.fn_is_carik() OR public.fn_is_lurah());

DROP POLICY IF EXISTS "assign_insert_carik" ON public.employee_position_assignments;
CREATE POLICY "assign_insert_carik" ON public.employee_position_assignments FOR INSERT TO authenticated WITH CHECK (
    public.fn_is_carik() AND 
    position_id NOT IN (SELECT id FROM public.positions WHERE name = 'Lurah')
);

DROP POLICY IF EXISTS "assign_update_carik" ON public.employee_position_assignments;
CREATE POLICY "assign_update_carik" ON public.employee_position_assignments FOR UPDATE TO authenticated
USING (
    public.fn_is_carik() AND 
    position_id NOT IN (SELECT id FROM public.positions WHERE name = 'Lurah')
)
WITH CHECK (
    public.fn_is_carik() AND 
    position_id NOT IN (SELECT id FROM public.positions WHERE name = 'Lurah')
);

-- ============================================================
-- 7. SETTINGS & PARAMETERS
-- ============================================================
DROP POLICY IF EXISTS "village_settings_select" ON public.village_settings;
CREATE POLICY "village_settings_select" ON public.village_settings FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "village_settings_update_carik" ON public.village_settings;
CREATE POLICY "village_settings_update_carik" ON public.village_settings FOR UPDATE TO authenticated
USING (public.fn_is_carik())
WITH CHECK (public.fn_is_carik());

DROP POLICY IF EXISTS "tukin_params_select" ON public.tukin_parameters;
CREATE POLICY "tukin_params_select" ON public.tukin_parameters FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "tukin_params_insert_carik" ON public.tukin_parameters;
CREATE POLICY "tukin_params_insert_carik" ON public.tukin_parameters FOR INSERT TO authenticated WITH CHECK (public.fn_is_carik());
DROP POLICY IF EXISTS "tukin_params_update_carik" ON public.tukin_parameters;

-- ============================================================
-- 8. MATRIX POLICIES
-- ============================================================
DROP POLICY IF EXISTS "matrix_select" ON public.matrix_versions;
CREATE POLICY "matrix_select" ON public.matrix_versions FOR SELECT TO authenticated
USING (status IN ('Published', 'Locked') OR public.fn_is_carik() OR public.fn_is_lurah());

DROP POLICY IF EXISTS "matrix_insert_carik" ON public.matrix_versions;
CREATE POLICY "matrix_insert_carik" ON public.matrix_versions FOR INSERT TO authenticated
WITH CHECK (public.fn_is_carik() AND status IN ('Draft', 'Review'));

DROP POLICY IF EXISTS "matrix_update_carik" ON public.matrix_versions;
CREATE POLICY "matrix_update_carik" ON public.matrix_versions FOR UPDATE TO authenticated
USING (public.fn_is_carik() AND status IN ('Draft', 'Review'))
WITH CHECK (public.fn_is_carik() AND status IN ('Draft', 'Review'));

-- groups
DROP POLICY IF EXISTS "matrix_groups_select" ON public.performance_groups;
CREATE POLICY "matrix_groups_select" ON public.performance_groups FOR SELECT TO authenticated
USING (
    public.fn_is_carik() OR public.fn_is_lurah() OR
    matrix_version_id IN (SELECT id FROM public.matrix_versions WHERE status IN ('Published', 'Locked'))
);

DROP POLICY IF EXISTS "matrix_groups_insert_carik" ON public.performance_groups;
CREATE POLICY "matrix_groups_insert_carik" ON public.performance_groups FOR INSERT TO authenticated
WITH CHECK (
    public.fn_is_carik() AND 
    matrix_version_id IN (SELECT id FROM public.matrix_versions WHERE status IN ('Draft', 'Review'))
);

DROP POLICY IF EXISTS "matrix_groups_update_carik" ON public.performance_groups;
CREATE POLICY "matrix_groups_update_carik" ON public.performance_groups FOR UPDATE TO authenticated
USING (
    public.fn_is_carik() AND 
    matrix_version_id IN (SELECT id FROM public.matrix_versions WHERE status IN ('Draft', 'Review'))
)
WITH CHECK (
    public.fn_is_carik() AND 
    matrix_version_id IN (SELECT id FROM public.matrix_versions WHERE status IN ('Draft', 'Review'))
);

-- items
DROP POLICY IF EXISTS "matrix_items_select" ON public.performance_items;
CREATE POLICY "matrix_items_select" ON public.performance_items FOR SELECT TO authenticated
USING (
    public.fn_is_carik() OR public.fn_is_lurah() OR
    group_id IN (
        SELECT pg.id FROM public.performance_groups pg
        JOIN public.matrix_versions mv ON mv.id = pg.matrix_version_id
        WHERE mv.status IN ('Published', 'Locked')
    )
);

DROP POLICY IF EXISTS "matrix_items_insert_carik" ON public.performance_items;
CREATE POLICY "matrix_items_insert_carik" ON public.performance_items FOR INSERT TO authenticated
WITH CHECK (
    public.fn_is_carik() AND 
    group_id IN (
        SELECT pg.id FROM public.performance_groups pg
        JOIN public.matrix_versions mv ON mv.id = pg.matrix_version_id
        WHERE mv.status IN ('Draft', 'Review')
    )
);

DROP POLICY IF EXISTS "matrix_items_update_carik" ON public.performance_items;
CREATE POLICY "matrix_items_update_carik" ON public.performance_items FOR UPDATE TO authenticated
USING (
    public.fn_is_carik() AND 
    group_id IN (
        SELECT pg.id FROM public.performance_groups pg
        JOIN public.matrix_versions mv ON mv.id = pg.matrix_version_id
        WHERE mv.status IN ('Draft', 'Review')
    )
)
WITH CHECK (
    public.fn_is_carik() AND 
    group_id IN (
        SELECT pg.id FROM public.performance_groups pg
        JOIN public.matrix_versions mv ON mv.id = pg.matrix_version_id
        WHERE mv.status IN ('Draft', 'Review')
    )
);

-- targets
DROP POLICY IF EXISTS "matrix_targets_select" ON public.performance_targets;
CREATE POLICY "matrix_targets_select" ON public.performance_targets FOR SELECT TO authenticated
USING (
    public.fn_is_carik() OR public.fn_is_lurah() OR
    item_id IN (
        SELECT pi.id FROM public.performance_items pi
        JOIN public.performance_groups pg ON pg.id = pi.group_id
        JOIN public.matrix_versions mv ON mv.id = pg.matrix_version_id
        WHERE mv.status IN ('Published', 'Locked')
    )
);

DROP POLICY IF EXISTS "matrix_targets_insert_carik" ON public.performance_targets;
CREATE POLICY "matrix_targets_insert_carik" ON public.performance_targets FOR INSERT TO authenticated
WITH CHECK (
    public.fn_is_carik() AND 
    item_id IN (
        SELECT pi.id FROM public.performance_items pi
        JOIN public.performance_groups pg ON pg.id = pi.group_id
        JOIN public.matrix_versions mv ON mv.id = pg.matrix_version_id
        WHERE mv.status IN ('Draft', 'Review')
    )
);

DROP POLICY IF EXISTS "matrix_targets_update_carik" ON public.performance_targets;
CREATE POLICY "matrix_targets_update_carik" ON public.performance_targets FOR UPDATE TO authenticated
USING (
    public.fn_is_carik() AND 
    item_id IN (
        SELECT pi.id FROM public.performance_items pi
        JOIN public.performance_groups pg ON pg.id = pi.group_id
        JOIN public.matrix_versions mv ON mv.id = pg.matrix_version_id
        WHERE mv.status IN ('Draft', 'Review')
    )
)
WITH CHECK (
    public.fn_is_carik() AND 
    item_id IN (
        SELECT pi.id FROM public.performance_items pi
        JOIN public.performance_groups pg ON pg.id = pi.group_id
        JOIN public.matrix_versions mv ON mv.id = pg.matrix_version_id
        WHERE mv.status IN ('Draft', 'Review')
    )
);

-- ============================================================
-- 9. ATTENDANCES, PERMISSIONS, OFFICIAL DUTIES
-- ============================================================
DROP POLICY IF EXISTS "attendances_select" ON public.attendances;
CREATE POLICY "attendances_select" ON public.attendances FOR SELECT TO authenticated
USING (employee_id = public.fn_get_employee_id() OR public.fn_is_carik() OR public.fn_is_lurah());

DROP POLICY IF EXISTS "attendances_insert" ON public.attendances;
CREATE POLICY "attendances_insert" ON public.attendances FOR INSERT TO authenticated
WITH CHECK (employee_id = public.fn_get_employee_id() OR public.fn_is_carik());

DROP POLICY IF EXISTS "attendances_update" ON public.attendances;
CREATE POLICY "attendances_update" ON public.attendances FOR UPDATE TO authenticated
USING (employee_id = public.fn_get_employee_id() OR public.fn_is_carik())
WITH CHECK (employee_id = public.fn_get_employee_id() OR public.fn_is_carik());

DROP POLICY IF EXISTS "permissions_select" ON public.permissions;
CREATE POLICY "permissions_select" ON public.permissions FOR SELECT TO authenticated
USING (employee_id = public.fn_get_employee_id() OR public.fn_is_carik() OR public.fn_is_lurah());

DROP POLICY IF EXISTS "permissions_insert" ON public.permissions;
CREATE POLICY "permissions_insert" ON public.permissions FOR INSERT TO authenticated
WITH CHECK (employee_id = public.fn_get_employee_id());

DROP POLICY IF EXISTS "permissions_update" ON public.permissions;
DROP POLICY IF EXISTS "permissions_update_self" ON public.permissions;
DROP POLICY IF EXISTS "permissions_update_carik" ON public.permissions;
DROP POLICY IF EXISTS "permissions_update_lurah" ON public.permissions;

CREATE POLICY "permissions_update_self" ON public.permissions FOR UPDATE TO authenticated
USING (employee_id = public.fn_get_employee_id() AND status = 'Draft')
WITH CHECK (employee_id = public.fn_get_employee_id() AND status = 'Draft');

CREATE POLICY "permissions_update_carik" ON public.permissions FOR UPDATE TO authenticated
USING (public.fn_is_carik() AND status = 'Submitted')
WITH CHECK (public.fn_is_carik() AND status IN ('Submitted', 'Rejected'));

CREATE POLICY "permissions_update_lurah" ON public.permissions FOR UPDATE TO authenticated
USING (public.fn_is_lurah() AND status = 'Submitted')
WITH CHECK (public.fn_is_lurah() AND status IN ('Approved', 'Rejected'));

DROP POLICY IF EXISTS "permissions_delete" ON public.permissions;
CREATE POLICY "permissions_delete" ON public.permissions FOR DELETE TO authenticated
USING (employee_id = public.fn_get_employee_id() AND status = 'Draft');

DROP POLICY IF EXISTS "duties_select" ON public.official_duties;
CREATE POLICY "duties_select" ON public.official_duties FOR SELECT TO authenticated
USING (employee_id = public.fn_get_employee_id() OR public.fn_is_carik() OR public.fn_is_lurah());

DROP POLICY IF EXISTS "duties_insert" ON public.official_duties;
CREATE POLICY "duties_insert" ON public.official_duties FOR INSERT TO authenticated
WITH CHECK (employee_id = public.fn_get_employee_id());

DROP POLICY IF EXISTS "duties_update" ON public.official_duties;
DROP POLICY IF EXISTS "duties_update_self" ON public.official_duties;
DROP POLICY IF EXISTS "duties_update_carik" ON public.official_duties;
DROP POLICY IF EXISTS "duties_update_lurah" ON public.official_duties;

CREATE POLICY "duties_update_self" ON public.official_duties FOR UPDATE TO authenticated
USING (employee_id = public.fn_get_employee_id() AND status = 'Draft')
WITH CHECK (employee_id = public.fn_get_employee_id() AND status = 'Draft');

CREATE POLICY "duties_update_carik" ON public.official_duties FOR UPDATE TO authenticated
USING (public.fn_is_carik() AND status = 'Submitted')
WITH CHECK (public.fn_is_carik() AND status IN ('Submitted', 'Rejected'));

CREATE POLICY "duties_update_lurah" ON public.official_duties FOR UPDATE TO authenticated
USING (public.fn_is_lurah() AND status = 'Submitted')
WITH CHECK (public.fn_is_lurah() AND status IN ('Approved', 'Rejected'));

DROP POLICY IF EXISTS "duties_delete" ON public.official_duties;
CREATE POLICY "duties_delete" ON public.official_duties FOR DELETE TO authenticated
USING (employee_id = public.fn_get_employee_id() AND status = 'Draft');

-- ============================================================
-- 10. JOURNALS & EVIDENCE
-- ============================================================
DROP POLICY IF EXISTS "journals_select" ON public.performance_journals;
CREATE POLICY "journals_select" ON public.performance_journals FOR SELECT TO authenticated
USING (employee_id = public.fn_get_employee_id() OR public.fn_is_carik() OR public.fn_is_lurah());

DROP POLICY IF EXISTS "journals_insert" ON public.performance_journals;
DROP POLICY IF EXISTS "journals_update" ON public.performance_journals;

DROP POLICY IF EXISTS "journals_delete" ON public.performance_journals;
CREATE POLICY "journals_delete" ON public.performance_journals FOR DELETE TO authenticated
USING (employee_id = public.fn_get_employee_id() AND status = 'Draft');

DROP POLICY IF EXISTS "evidence_select" ON public.journal_evidence;
CREATE POLICY "evidence_select" ON public.journal_evidence FOR SELECT TO authenticated
USING (
    public.fn_is_carik() OR public.fn_is_lurah() OR
    journal_id IN (
        SELECT id FROM public.performance_journals 
        WHERE employee_id = public.fn_get_employee_id()
    )
);

DROP POLICY IF EXISTS "evidence_insert" ON public.journal_evidence;
CREATE POLICY "evidence_insert" ON public.journal_evidence FOR INSERT TO authenticated
WITH CHECK (
    journal_id IN (
        SELECT id FROM public.performance_journals 
        WHERE employee_id = public.fn_get_employee_id() AND status IN ('Draft', 'Returned')
    )
);

DROP POLICY IF EXISTS "evidence_delete" ON public.journal_evidence;
CREATE POLICY "evidence_delete" ON public.journal_evidence FOR DELETE TO authenticated
USING (
    journal_id IN (
        SELECT id FROM public.performance_journals 
        WHERE employee_id = public.fn_get_employee_id() AND status IN ('Draft', 'Returned')
    )
);

-- ============================================================
-- 11. OTHERS (DISCIPLINARY, TUKIN, AUDIT)
-- ============================================================
DROP POLICY IF EXISTS "disciplinary_select" ON public.disciplinary_actions;
CREATE POLICY "disciplinary_select" ON public.disciplinary_actions FOR SELECT TO authenticated
USING (employee_id = public.fn_get_employee_id() OR public.fn_is_carik() OR public.fn_is_lurah());

DROP POLICY IF EXISTS "disciplinary_insert_carik" ON public.disciplinary_actions;
CREATE POLICY "disciplinary_insert_carik" ON public.disciplinary_actions FOR INSERT TO authenticated
WITH CHECK (public.fn_is_carik());

DROP POLICY IF EXISTS "disciplinary_update_carik" ON public.disciplinary_actions;
CREATE POLICY "disciplinary_update_carik" ON public.disciplinary_actions FOR UPDATE TO authenticated
USING (public.fn_is_carik())
WITH CHECK (public.fn_is_carik());

DROP POLICY IF EXISTS "tukin_periods_select" ON public.tukin_periods;
CREATE POLICY "tukin_periods_select" ON public.tukin_periods FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "tukin_periods_insert_carik" ON public.tukin_periods;
CREATE POLICY "tukin_periods_insert_carik" ON public.tukin_periods FOR INSERT TO authenticated
WITH CHECK (public.fn_is_carik() AND status = 'Draft');

DROP POLICY IF EXISTS "tukin_periods_update_carik" ON public.tukin_periods;
CREATE POLICY "tukin_periods_update_carik" ON public.tukin_periods FOR UPDATE TO authenticated
USING (public.fn_is_carik() AND status = 'Draft')
WITH CHECK (public.fn_is_carik() AND status = 'Draft');

DROP POLICY IF EXISTS "tukin_calc_select" ON public.tukin_calculations;
CREATE POLICY "tukin_calc_select" ON public.tukin_calculations FOR SELECT TO authenticated
USING (employee_id = public.fn_get_employee_id() OR public.fn_is_carik() OR public.fn_is_lurah());

DROP POLICY IF EXISTS "tukin_comp_select" ON public.tukin_calculation_components;
CREATE POLICY "tukin_comp_select" ON public.tukin_calculation_components FOR SELECT TO authenticated
USING (public.fn_is_carik() OR public.fn_is_lurah());

DROP POLICY IF EXISTS "audit_logs_select" ON public.audit_logs;
CREATE POLICY "audit_logs_select" ON public.audit_logs FOR SELECT TO authenticated
USING (actor_profile_id = auth.uid() OR public.fn_is_carik() OR public.fn_is_lurah());

-- ============================================================
-- 12. REVOKE ALL & PRECISE GRANT TO AUTHENTICATED
-- ============================================================
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM authenticated;

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;

-- Identity
GRANT UPDATE(full_name) ON public.profiles TO authenticated; -- Ordinary fields only, NOT role
GRANT UPDATE(nip_nipt) ON public.employees TO authenticated; -- Ordinary fields only, NOT profile_id

-- Write Privileges (Application tables based on RLS filtering)
GRANT INSERT ON public.positions TO authenticated;
GRANT UPDATE(is_pamong_tukin_eligible) ON public.positions TO authenticated;
GRANT INSERT ON public.tukin_parameters TO authenticated;
GRANT INSERT, UPDATE ON public.employee_position_assignments, public.village_settings, public.matrix_versions, public.performance_groups, public.performance_items, public.performance_targets, public.attendances, public.permissions, public.official_duties, public.journal_evidence, public.disciplinary_actions, public.tukin_periods TO authenticated;
GRANT DELETE ON public.permissions, public.official_duties, public.performance_journals, public.journal_evidence TO authenticated;

-- Hard constraints over GRANTs
REVOKE INSERT, DELETE ON public.profiles FROM authenticated;
REVOKE INSERT, DELETE ON public.employees FROM authenticated;
REVOKE INSERT, UPDATE ON public.performance_journals FROM authenticated;
REVOKE INSERT, UPDATE, DELETE ON public.tukin_calculations FROM authenticated;
REVOKE INSERT, UPDATE, DELETE ON public.tukin_calculation_components FROM authenticated;
REVOKE INSERT, UPDATE, DELETE ON public.audit_logs FROM authenticated;
