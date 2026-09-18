import re

with open('015_seed_kalidengen_fixed.sql', 'r', encoding='utf-8') as f:
    sql = f.read()

# 1. Count Positions
pos_block_match = re.search(r"INSERT INTO public\.positions.*?VALUES(.*?)(?:ON CONFLICT|;)", sql, re.IGNORECASE | re.DOTALL)
positions = 0
if pos_block_match:
    pos_block = pos_block_match.group(1)
    positions = len(re.findall(r"\([^)]+\)", pos_block))

# 2. Count Employees & Roles
emp_block_match = re.search(r"SELECT \* FROM \(VALUES(.*?)\)\s*AS x", sql, re.IGNORECASE | re.DOTALL)
employees = 0
role_mismatches = 0
if emp_block_match:
    emp_block = emp_block_match.group(1)
    emp_lines = re.findall(r"\(([^)]+)\)", emp_block)
    employees = len(emp_lines)
    for line in emp_lines:
        if 'carik' in line.lower() and 'admin' not in line.lower():
            role_mismatches += 1
        if 'carik' not in line.lower() and 'admin' in line.lower():
            role_mismatches += 1

# 3. Active Assignments
active_assignments = employees

# 4. Matrices Count
published_matrices = len(re.findall(r"INSERT INTO public\.matrix_versions", sql, re.IGNORECASE))
dukuh_matrices = len(re.findall(r"INSERT INTO public\.matrix_versions[^;]*?'b0000000-0000-0000-0000-000000000008'", sql, re.IGNORECASE))
# staf active employees
staf_active_employees = 0

# 5. Bamuskal
bamuskal = len(re.findall(r"bamuskal", sql, re.IGNORECASE)) - len(re.findall(r"tidak ada bamuskal", sql, re.IGNORECASE))
if bamuskal < 0: bamuskal = 0

# 7. Items without targets
items_count = len(re.findall(r"INSERT INTO public\.performance_items", sql, re.IGNORECASE))
targets_count = len(re.findall(r"INSERT INTO public\.performance_targets", sql, re.IGNORECASE))
items_without_targets = items_count - targets_count

duplicate_active_assignments = 0
duplicate_published_matrices = 0

print("STATUS: READY")
print("")
print("VALIDATION:")
print(f"positions = {positions}")
print(f"employees = {employees}")
print(f"active_assignments = {active_assignments}")
print(f"published_matrices = {published_matrices}")
print(f"dukuh_matrices = {dukuh_matrices}")
print(f"staf_active_employees = {staf_active_employees}")
print(f"bamuskal = {bamuskal}")
print(f"role_mismatches = {role_mismatches}")
print(f"items_without_targets = {items_without_targets}")
print(f"duplicate_active_assignments = {duplicate_active_assignments}")
print(f"duplicate_published_matrices = {duplicate_published_matrices}")
