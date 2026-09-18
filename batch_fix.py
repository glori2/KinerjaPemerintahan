import os
import re

def fix(filepath, rules):
    with open(filepath, 'r', encoding='utf-8') as f: content = f.read()
    for o, n in rules: content = content.replace(o, n)
    with open(filepath, 'w', encoding='utf-8') as f: f.write(content)

# 1. Dashboard (setStats unused) -> actually it's unused because of previous script breaking it. Let's fix Dashboard logic completely.
dash_patch = [
    ('const [stats, setStats] = useState<Record<string, unknown>>({}); /* eslint-disable-line @typescript-eslint/no-unused-vars, @typescript-eslint/no-explicit-any */', 'const [stats, setStats] = useState<Record<string, unknown>>({});'),
    ('const [loading, setLoading] = useState(true); /* eslint-disable-line @typescript-eslint/no-unused-vars */', 'const [loading, setLoading] = useState(true);'),
    ('/* eslint-disable-next-line @typescript-eslint/no-unused-vars */\nimport { supabase } from', 'import { supabase } from')
]
fix('src/app/dashboard/page.tsx', dash_patch)

# 2. Evaluasi [id]
fix('src/app/evaluasi/[id]/page.tsx', [
    ('data as unknown as Journal /* eslint-disable-line @typescript-eslint/no-explicit-any */', 'data as unknown as Journal')
])

# 3. Jurnal Create
fix('src/app/jurnal/create/page.tsx', [
    ('}, [fetchMatrix]);', '}, []);'), # exhaustive-deps warns about fetchMatrix missing
    ('const fetchMatrix', 'const fetchMatrix = useCallback'), # We should probably just move fetchMatrix inside useEffect
    ('data as unknown as MatrixVersion /* eslint-disable-line @typescript-eslint/no-explicit-any */', 'data as unknown as MatrixVersion'),
    ('const flatItems =', 'let flatItems ='), # Wait, the error is 'flatItems is never reassigned. Use const'. I'll just leave it as const.
])
with open('src/app/jurnal/create/page.tsx', 'r') as f: c = f.read()
c = c.replace("let flatItems =", "const flatItems =")
c = re.sub(r'const fetchMatrix = async \(\) => {.*?};\n', '', c, flags=re.DOTALL)
c = c.replace("if (isCarik) fetchMatrix();", "if (isCarik) {\n      const fetchMatrix = async () => {\n        try {\n          const { data, error } = await supabase.from('matrix_versions').select('*, performance_groups(*, performance_items(*))').eq('status', 'Published').limit(1).single();\n          if (error) throw error;\n          setMatrix(data as unknown as MatrixVersion);\n        } catch (err: unknown) {\n          console.error(err);\n        } finally {\n          setLoading(false);\n        }\n      };\n      fetchMatrix();\n    }")
with open('src/app/jurnal/create/page.tsx', 'w') as f: f.write(c)


# 4. Jurnal [id]
fix('src/app/jurnal/[id]/page.tsx', [
    ('data as unknown as Journal /* eslint-disable-line @typescript-eslint/no-explicit-any */', 'data as unknown as Journal'),
    ('const fetchJournal = async () => {', 'const fetchJournal = async () => {'), # ensure no redecl
])

# 5. Login
fix('src/app/login/page.tsx', [
    ('}, [router]);', '}, []);'),
    ('import { useRouter } from', 'import { useRouter } from'),
    ('const router = useRouter();', 'const router = useRouter();')
])

# 6. AuthProvider
fix('src/components/AuthProvider.tsx', [
    ('export const useAuth = () => useContext(AuthContext) as { user: unknown, profile: unknown, employee: unknown, assignment: unknown, loading: boolean, signOut: () => void };', 
     'export const useAuth = () => useContext(AuthContext) as { user: any, profile: any, employee: any, assignment: any, loading: boolean, signOut: () => void };'),
    ('import { useRouter } from', 'import { useRouter } from')
])
# Need to add useRouter back to Login, Jurnal Create, Jurnal [id], Evaluasi [id] because they use it!
for p in ['src/app/jurnal/create/page.tsx', 'src/app/jurnal/[id]/page.tsx', 'src/app/login/page.tsx', 'src/app/evaluasi/[id]/page.tsx']:
    with open(p, 'r') as f:
        cc = f.read()
    if 'useRouter' not in cc:
        cc = "import { useRouter } from 'next/navigation';\n" + cc
        cc = cc.replace("export default function", "export default function Page() {\n  const router = useRouter();\n  // ")
    with open(p, 'w') as f: f.write(cc)
    
print("First batch of fixes applied")
