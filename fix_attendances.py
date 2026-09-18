import os

src_dir = 'src'
changed_files = []
replacements_count = 0

for root, _, files in os.walk(src_dir):
    for file in files:
        if file.endswith('.tsx') or file.endswith('.ts'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            if 'attendance_records' in content:
                count = content.count('attendance_records')
                new_content = content.replace('attendance_records', 'attendances')
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                changed_files.append(filepath)
                replacements_count += count

print(f"Changed files: {', '.join(changed_files)}")
print(f"Total replacements: {replacements_count}")
