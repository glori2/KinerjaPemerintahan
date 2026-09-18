import os

dirs = ['src/app/admin/pegawai', 'src/app/admin/matriks', 'src/app/admin/audit']
for d in dirs:
    for root, _, files in os.walk(d):
        for file in files:
            if file.endswith('.tsx'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                content = content.replace('\\n', '\n')
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
print("Fixed newlines for Phase 3E")
