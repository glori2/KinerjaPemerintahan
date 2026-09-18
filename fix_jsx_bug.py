import os

path = 'src/app/login/page.tsx'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('</label className="sr-only">', '</label>')

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed JSX error in login")
