import re

with open('015_seed_kalidengen_fixed.sql', 'r', encoding='utf-8') as f:
    sql = f.read()

# Audit counts
positions = len(re.findall(r"INSERT INTO public\.positions.*?VALUES\s*\((.*?)\)", sql, re.IGNORECASE | re.DOTALL)[0].split('),')) if re.search(r"INSERT INTO public\.positions", sql) else 0

employees = len(re.findall(r"SELECT \* FROM \(VALUES\s*(.*?)\)\s*AS x\(email", sql, re.IGNORECASE | re.DOTALL)[0].split('),')) if re.search(r"SELECT \* FROM \(VALUES", sql) else 0

active_assignments = employees # Since each provision block gives 1 active assignment
published_matrices = len(re.findall(r"INSERT INTO public\.matrix_versions", sql, re.IGNORECASE))
dukuh_matrices = len(re.findall(r"INSERT INTO public\.matrix_versions.*?b0000000-0000-0000-0000-000000000008", sql, re.IGNORECASE))
staf_matrices = len(re.findall(r"INSERT INTO public\.matrix_versions.*?b0000000-0000-0000-0000-000000000009", sql, re.IGNORECASE))
bamuskal = len(re.findall(r"Bamuskal", sql, re.IGNORECASE)) - len(re.findall(r"tidak ada Bamuskal", sql, re.IGNORECASE)) # Roughly checking if Bamuskal is inserted
if bamuskal < 0: bamuskal = 0

# Check empty or 'b' groups
empty_groups = len(re.findall(r"INSERT INTO public\.performance_groups.*?VALUES \([^,]+,\s*'([^']*)'", sql))
empty_group_matches = re.findall(r"(INSERT INTO public\.performance_groups.*?VALUES \([^,]+,\s*'([^']*)'.*?;)", sql)

items_without_targets = 0
role_mismatches = 0

# Print audit BEFORE fix
print("=== MIGRATION 015 AUDIT BEFORE FIX ===")
print(f"positions: {positions}")
print(f"employees: {employees}")
print(f"published matrices: {published_matrices}")
print(f"dukuh matrices: {dukuh_matrices}")
print(f"staf matrices: {staf_matrices}")
print("empty/b groups:", [m[1] for m in empty_group_matches if m[1].strip().lower() in ['', 'b']])

# FIXING
lines = sql.split('\n')
new_lines = []
for line in lines:
    if "INSERT INTO public.performance_groups" in line:
        # Check if name is '' or 'b'
        match = re.search(r"VALUES \([^,]+,\s*'([^']*)'", line)
        if match:
            gname = match.group(1).strip()
            if gname == '' or gname.lower() == 'b':
                continue # Skip this artifact group
    
    # Also remove any direct insert into auth.users just in case it exists, but the user said they placed 015_seed_kalidengen_fixed.sql and looking at it, it already uses DO block without inserting to auth.users.
    if "INSERT INTO auth.users" in line:
        continue # Remove if it exists

    new_lines.append(line)

fixed_sql = '\n'.join(new_lines)
with open('015_seed_kalidengen_fixed.sql', 'w', encoding='utf-8') as f:
    f.write(fixed_sql)

print("\nFix applied.")
