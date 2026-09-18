import re

def fix(filepath, replacements):
    with open(filepath, 'r', encoding='utf-8') as f: content = f.read()
    for o, n in replacements: content = content.replace(o, n)
    with open(filepath, 'w', encoding='utf-8') as f: f.write(content)

fix('src/app/dashboard/page.tsx', [
    ('useState<any>({})', 'useState<Record<string, unknown>>({})')
])

fix('src/app/evaluasi/[id]/page.tsx', [
    ('data as unknown as any /* eslint-disable-line @typescript-eslint/no-explicit-any */', 'data as unknown as Journal'),
    ('onChange={(e: any)', 'onChange={(e: React.ChangeEvent<HTMLInputElement>)'),
    ('onChange={(e: any)', 'onChange={(e: React.ChangeEvent<HTMLTextAreaElement>)')
])

fix('src/app/jurnal/create/page.tsx', [
    ('let flatItems =', 'const flatItems ='),
    ('data as unknown as any /* eslint-disable-line @typescript-eslint/no-explicit-any */', 'data as unknown as MatrixVersion'),
    ('const { data, error } = await supabase', 'const { data, error } = await supabase'),
    ('setMatrix(data as unknown as any', 'setMatrix(data as unknown as MatrixVersion'),
    ('onChange={(e: any)', 'onChange={(e: React.ChangeEvent<HTMLSelectElement>)'),
    ('onChange={(e: any)', 'onChange={(e: React.ChangeEvent<HTMLInputElement>)'),
    ('onChange={(e: any)', 'onChange={(e: React.ChangeEvent<HTMLTextAreaElement>)'),
    ('let flatItems = data.performance_groups.reduce((acc: any, group: any)', 'const flatItems = data.performance_groups.reduce((acc: unknown[], group: PerformanceGroup)'),
    ('}, []);\n\n  const handleSubmit', '}, [fetchMatrix]);\n\n  const handleSubmit')
])

fix('src/app/jurnal/[id]/page.tsx', [
    ('data as unknown as any /* eslint-disable-line @typescript-eslint/no-explicit-any */', 'data as unknown as Journal'),
    ('onChange={(e: any)', 'onChange={(e: React.ChangeEvent<HTMLInputElement>)'),
    ('onChange={(e: any)', 'onChange={(e: React.ChangeEvent<HTMLTextAreaElement>)')
])

fix('src/app/login/page.tsx', [
    ('}, [router]);', '}, []);')
])

print("Patched remaining few errors.")
