import os

def fix_literals():
    for root, _, files in os.walk('src'):
        for file in files:
            if file.endswith('.tsx'):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace literal backslash-n with a real newline
                new_content = content.replace('\\n', '\n')
                
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)

fix_literals()
print("Safely fixed literal backslash-n")
