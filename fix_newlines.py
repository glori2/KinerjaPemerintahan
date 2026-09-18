import os

src_dir = 'src/app/jurnal'
for root, _, files in os.walk(src_dir):
    for file in files:
        if file.endswith('.tsx'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            content = content.replace('\\n', '\n')
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
print("Fixed newlines")
