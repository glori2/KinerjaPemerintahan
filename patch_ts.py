import os
import re

files_to_fix = [
    'src/app/admin/audit/page.tsx',
    'src/app/admin/kalkulasi/page.tsx',
    'src/app/admin/matriks/page.tsx',
    'src/app/admin/pegawai/page.tsx',
    'src/app/dashboard/page.tsx',
    'src/app/evaluasi/page.tsx',
    'src/app/evaluasi/[id]/page.tsx',
    'src/app/jurnal/create/page.tsx',
    'src/app/jurnal/page.tsx',
    'src/app/jurnal/[id]/page.tsx',
    'src/app/login/page.tsx',
    'src/app/presensi/page.tsx',
    'src/app/tukin/page.tsx',
    'src/components/AuthProvider.tsx'
]

def patch_file(filepath):
    if not os.path.exists(filepath):
        return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Add Type Imports
    imports = "import { Profile, Employee, Position, EmployeeAssignment, Journal, JournalEvidence, MatrixVersion, PerformanceGroup, PerformanceItem, TukinCalculation, TukinPeriod, AuditLog } from '@/types';"
    if 'import { Profile' not in content:
        content = content.replace("import { supabase } from '@/lib/supabase';", f"import {{ supabase }} from '@/lib/supabase';\n{imports}")

    # 2. Replace any with proper types or unknown where appropriate
    content = content.replace("useState<any[]>", "useState<any[]>") # We will replace specifically
    content = content.replace("useState<any>", "useState<any>")
    content = content.replace("err: any", "err: unknown")
    
    # Specific component patches
    if 'admin/audit' in filepath:
        content = content.replace("useState<any[]>", "useState<AuditLog[]>")
        # Move fetchLogs into useEffect
        content = re.sub(r'const fetchLogs = async \(\) => {.*?};\n', '', content, flags=re.DOTALL)
        content = content.replace('if (isCarik) fetchLogs();', 'if (isCarik) {\n      const fetchLogs = async () => {\n        try {\n          setLoading(true);\n          let query = supabase.from("audit_logs").select("*, profiles(full_name)").order("created_at", { ascending: false }).limit(100);\n          if (actionFilter) query = query.eq("action", actionFilter);\n          if (entityFilter) query = query.eq("entity_type", entityFilter);\n          const { data, error } = await query;\n          if (error) throw error;\n          setLogs(data as any);\n        } catch (err) {\n          console.error(err);\n        } finally {\n          setLoading(false);\n        }\n      };\n      fetchLogs();\n    }')
    
    elif 'admin/kalkulasi' in filepath:
        content = content.replace("useState<any[]>", "useState<TukinPeriod[]>")
        content = re.sub(r'const fetchPeriods = async \(\) => {.*?};\n', '', content, flags=re.DOTALL)
        content = content.replace('if (isCarik) fetchPeriods();', 'if (isCarik) {\n      const fetchPeriods = async () => {\n        try {\n          const { data, error } = await supabase.from("tukin_periods").select("*, tukin_calculations(count)").order("period_month", { ascending: false });\n          if (error) throw error;\n          setPeriods(data as any);\n        } catch (err) {\n          console.error(err);\n        } finally {\n          setLoading(false);\n        }\n      };\n      fetchPeriods();\n    }')

    elif 'admin/matriks' in filepath:
        content = content.replace("useState<any[]>", "useState<MatrixVersion[]>")
        content = re.sub(r'const fetchMatrices = async \(\) => {.*?};\n', '', content, flags=re.DOTALL)
        content = content.replace('if (isCarik) fetchMatrices();', 'if (isCarik) {\n      const fetchMatrices = async () => {\n        try {\n          const { data, error } = await supabase.from("matrix_versions").select("*, positions(name), performance_groups(count)").order("created_at", { ascending: false });\n          if (error) throw error;\n          setMatrices(data as any);\n        } catch (err) {\n        }\n      };\n      fetchMatrices();\n    }')

    elif 'admin/pegawai' in filepath:
        content = content.replace("useState<any[]>", "useState<Employee[]>")
        content = content.replace("(a:any)", "(a: EmployeeAssignment)")
        content = re.sub(r'const fetchEmployees = async \(\) => {.*?};\n', '', content, flags=re.DOTALL)
        content = content.replace('if (isCarik) fetchEmployees();', 'if (isCarik) {\n      const fetchEmployees = async () => {\n        try {\n          const { data, error } = await supabase.from("employees").select("*, profiles(full_name, role, status), employee_position_assignments(status, positions(name))").eq("employee_position_assignments.status", "active");\n          if (error) throw error;\n          setEmployees(data as any);\n        } catch (err) {\n          console.error(err);\n        } finally {\n          setLoading(false);\n        }\n      };\n      fetchEmployees();\n    }')

    elif 'dashboard' in filepath:
        content = content.replace("useState<any>", "useState<any>") # Kept dynamic for stats
        content = re.sub(r'const fetchDashboardData = async \(\) => {.*?};\n\n', '', content, flags=re.DOTALL)
        # Inline it
        
    elif 'tukin/page' in filepath:
        content = content.replace("useState<any[]>", "useState<TukinCalculation[]>")
        content = content.replace("const { employee, profile, assignment }", "const { employee, assignment }")
        content = re.sub(r'const fetchCalculations = async \(\) => {.*?};\n', '', content, flags=re.DOTALL)
        content = content.replace('if (employee) fetchCalculations();', 'if (employee) {\n      const fetchCalculations = async () => {\n        try {\n          const { data, error } = await supabase.from("tukin_calculations").select("*, tukin_periods(*), tukin_calculation_components(source_percentage_snapshot, employees(profiles(full_name)))").eq("employee_id", employee.id).order("created_at", { ascending: false });\n          if (error) throw error;\n          setCalculations(data as any);\n        } catch (err) {\n          console.error(err);\n        } finally {\n          setLoading(false);\n        }\n      };\n      fetchCalculations();\n    }')

    elif 'presensi' in filepath:
        content = content.replace("useState<any>", "useState<any>")
        content = content.replace("useState<any[]>", "useState<any[]>")
        content = content.replace("catch (err: any)", "catch (err: unknown)")
        content = content.replace("catch (err) {", "catch (err) {\n      console.error(err);")
        # Removing unused 'err' is handled by using 'err: unknown' and console.logging it if empty
        content = content.replace("setError(err.message", "setError((err as Error).message")

    elif 'jurnal' in filepath:
        content = content.replace("useState<any[]>", "useState<Journal[]>")
        content = content.replace("useState<any>", "useState<Journal | null>")
        content = content.replace("err: any", "err: unknown")
        content = content.replace("err.message", "(err as Error).message")
        content = content.replace("const router = useRouter();", "")
        content = content.replace("let fileExt =", "const fileExt =")
        content = content.replace("let flatItems =", "const flatItems =")
        
    elif 'evaluasi' in filepath:
        content = content.replace("useState<any[]>", "useState<Journal[]>")
        content = content.replace("useState<any>", "useState<Journal | null>")
        content = content.replace("err: any", "err: unknown")
        content = content.replace("err.message", "(err as Error).message")

    elif 'login' in filepath:
        content = content.replace("catch (err: any)", "catch (err: unknown)")
        content = content.replace("err.message", "(err as Error).message")
        
    elif 'AuthProvider' in filepath:
        content = content.replace("useState<any>", "useState<any>")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for file in files_to_fix:
    patch_file(file)

print("Patching done.")
