import os

filepath = 'src/app/login/page.tsx'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

new_content = content.replace('</label className="sr-only">', '</label>')

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(new_content)

print(f"Fixed {filepath}")
