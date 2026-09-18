import re
import os

def fix_file(path, func):
    with open(path, 'r', encoding='utf-8') as f: c = f.read()
    c = func(c)
    with open(path, 'w', encoding='utf-8') as f: f.write(c)

def f_eval_id(c):
    c = re.sub(r'import \{ useRouter \} from \'next/navigation\';\nexport default function Page\(\) \{\n  const router = useRouter\(\);\n  // ', '', c)
    c = c.replace('data as unknown as never', 'data as unknown as Journal')
    c = c.replace('as any /* eslint-disable-line @typescript-eslint/no-explicit-any */', 'as unknown')
    return c

def f_jurnal_id(c):
    c = re.sub(r'import \{ useRouter \} from \'next/navigation\';\nexport default function Page\(\) \{\n  const router = useRouter\(\);\n  // ', '', c)
    c = c.replace('data as unknown as never', 'data as unknown as Journal')
    c = c.replace('as any /* eslint-disable-line @typescript-eslint/no-explicit-any */', 'as unknown')
    return c

def f_jurnal_create(c):
    c = re.sub(r'import \{ useRouter \} from \'next/navigation\';\nexport default function Page\(\) \{\n  const router = useRouter\(\);\n  // ', '', c)
    c = c.replace('data as unknown as never', 'data as unknown as MatrixVersion')
    c = c.replace('let flatItems =', 'const flatItems =')
    c = c.replace('acc: unknown[]', 'acc: PerformanceItem[]')
    c = c.replace('group: unknown', 'group: PerformanceGroup')
    c = c.replace('as any /* eslint-disable-line @typescript-eslint/no-explicit-any */', 'as unknown')
    # fix fetchMatrix exhaustive deps
    c = c.replace('}, []);\n\n  const handleSubmit', '}, [fetchMatrix]);\n\n  const handleSubmit')
    return c

def f_login(c):
    c = re.sub(r'import \{ useRouter \} from \'next/navigation\';\nexport default function Page\(\) \{\n  const router = useRouter\(\);\n  // ', '', c)
    c = c.replace('}, [router]);', '}, []);')
    return c

def f_dashboard(c):
    c = c.replace('const [stats, setStats]', 'const [stats]')
    c = c.replace('const [loading, setLoading]', 'const [loading]')
    c = re.sub(r'import \{ supabase \} from \'@/lib/supabase\';\n?', '', c)
    return c

def f_auth_prov(c):
    c = c.replace('{ user: any, profile: any, employee: any, assignment: any, loading: boolean, signOut: () => void }', '{ user: unknown, profile: unknown, employee: unknown, assignment: unknown, loading: boolean, signOut: () => void }')
    return c

fix_file('src/app/evaluasi/[id]/page.tsx', f_eval_id)
fix_file('src/app/jurnal/[id]/page.tsx', f_jurnal_id)
fix_file('src/app/jurnal/create/page.tsx', f_jurnal_create)
fix_file('src/app/login/page.tsx', f_login)
fix_file('src/app/dashboard/page.tsx', f_dashboard)
fix_file('src/components/AuthProvider.tsx', f_auth_prov)

print("Targeted ESLint fixes applied.")
