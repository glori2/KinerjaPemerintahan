-- 1. Create Helper Functions for Auth
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = auth.uid() 
        AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_my_employee_id()
RETURNS uuid AS $$
DECLARE
    emp_id uuid;
BEGIN
    SELECT id INTO emp_id 
    FROM employees 
    WHERE profile_id = auth.uid() 
    LIMIT 1;
    RETURN emp_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE matrix_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE performance_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE performance_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE performance_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE performance_journals ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE official_duties ENABLE ROW LEVEL SECURITY;
ALTER TABLE tukin_periods ENABLE ROW LEVEL SECURITY;
ALTER TABLE tukin_calculations ENABLE ROW LEVEL SECURITY;
ALTER TABLE tukin_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE disciplinary_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- 3. Profiles Policies
-- Admin can do everything, Users can read and update their own profile
CREATE POLICY "Profiles: Admin can manage all" ON profiles FOR ALL USING (is_admin());
CREATE POLICY "Profiles: Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Profiles: Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- 4. Positions Policies
-- Everyone can read positions, Admin can manage
CREATE POLICY "Positions: Anyone can view" ON positions FOR SELECT USING (true);
CREATE POLICY "Positions: Admin can manage" ON positions FOR ALL USING (is_admin());

-- 5. Employees Policies
-- Admin can manage all, Users can view their own employee record
CREATE POLICY "Employees: Admin can manage all" ON employees FOR ALL USING (is_admin());
CREATE POLICY "Employees: Users can view own record" ON employees FOR SELECT USING (profile_id = auth.uid());

-- 6. Village Settings
-- Everyone can read, Admin can manage
CREATE POLICY "Settings: Anyone can view" ON village_settings FOR SELECT USING (true);
CREATE POLICY "Settings: Admin can manage" ON village_settings FOR ALL USING (is_admin());

-- 7. Matrix & Targets (matrix_versions, performance_groups, performance_items, performance_targets)
-- Everyone can read, Admin can manage
CREATE POLICY "Matrix: Anyone can view versions" ON matrix_versions FOR SELECT USING (true);
CREATE POLICY "Matrix: Admin can manage versions" ON matrix_versions FOR ALL USING (is_admin());

CREATE POLICY "Matrix: Anyone can view groups" ON performance_groups FOR SELECT USING (true);
CREATE POLICY "Matrix: Admin can manage groups" ON performance_groups FOR ALL USING (is_admin());

CREATE POLICY "Matrix: Anyone can view items" ON performance_items FOR SELECT USING (true);
CREATE POLICY "Matrix: Admin can manage items" ON performance_items FOR ALL USING (is_admin());

CREATE POLICY "Matrix: Anyone can view targets" ON performance_targets FOR SELECT USING (true);
CREATE POLICY "Matrix: Admin can manage targets" ON performance_targets FOR ALL USING (is_admin());

-- 8. Journals & Evidence
-- Admin can manage all. Users can manage their own.
CREATE POLICY "Journals: Admin can manage all" ON performance_journals FOR ALL USING (is_admin());
CREATE POLICY "Journals: Users can manage own" ON performance_journals FOR ALL USING (employee_id = get_my_employee_id());

CREATE POLICY "Evidence: Admin can manage all" ON journal_evidence FOR ALL USING (is_admin());
CREATE POLICY "Evidence: Users can manage own" ON journal_evidence FOR ALL USING (
    EXISTS (
        SELECT 1 FROM performance_journals pj 
        WHERE pj.id = journal_id AND pj.employee_id = get_my_employee_id()
    )
);

-- 9. Attendance, Permissions, Official Duties
CREATE POLICY "Attendance: Admin can manage all" ON attendance FOR ALL USING (is_admin());
CREATE POLICY "Attendance: Users can manage own" ON attendance FOR ALL USING (employee_id = get_my_employee_id());

CREATE POLICY "Permissions: Admin can manage all" ON permissions FOR ALL USING (is_admin());
CREATE POLICY "Permissions: Users can manage own" ON permissions FOR ALL USING (employee_id = get_my_employee_id());

CREATE POLICY "Duties: Admin can manage all" ON official_duties FOR ALL USING (is_admin());
CREATE POLICY "Duties: Users can manage own" ON official_duties FOR ALL USING (employee_id = get_my_employee_id());

-- 10. Tukin Periods & Calculations
-- Periods: Everyone can read, Admin can manage
CREATE POLICY "TukinPeriods: Anyone can view" ON tukin_periods FOR SELECT USING (true);
CREATE POLICY "TukinPeriods: Admin can manage" ON tukin_periods FOR ALL USING (is_admin());

-- Calculations & Adjustments: Admin can manage, Users can view their own
CREATE POLICY "TukinCalc: Admin can manage all" ON tukin_calculations FOR ALL USING (is_admin());
CREATE POLICY "TukinCalc: Users can view own" ON tukin_calculations FOR SELECT USING (employee_id = get_my_employee_id());

CREATE POLICY "TukinAdj: Admin can manage all" ON tukin_adjustments FOR ALL USING (is_admin());
CREATE POLICY "TukinAdj: Users can view own" ON tukin_adjustments FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM tukin_calculations tc 
        WHERE tc.id = calculation_id AND tc.employee_id = get_my_employee_id()
    )
);

-- 11. Disciplinary Actions
CREATE POLICY "Discipline: Admin can manage all" ON disciplinary_actions FOR ALL USING (is_admin());
CREATE POLICY "Discipline: Users can view own" ON disciplinary_actions FOR SELECT USING (employee_id = get_my_employee_id());

-- 12. Audit Logs
-- Only Admin can read. Audit logs are usually inserted via triggers (bypass RLS) or by admin.
CREATE POLICY "Audit: Admin can view all" ON audit_logs FOR SELECT USING (is_admin());
CREATE POLICY "Audit: Admin can insert" ON audit_logs FOR INSERT WITH CHECK (is_admin());
