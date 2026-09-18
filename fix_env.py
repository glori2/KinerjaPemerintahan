import os

filepath = 'src/lib/supabase.ts'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("process.env.NEXT_PUBLIC_SUPABASE_URL || ''", "process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://dummy.supabase.co'")
content = content.replace("process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ''", "process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'dummy-key'")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed env vars")
