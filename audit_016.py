import re

with open('016_workflow_reconciliation.sql', 'r') as f:
    sql = f.read()

print("Static SQL Audit:")
print("approve_journal status check:", re.search(r"IF v_status <> '([^']+)'", sql).group(1))
print("return_journal status check:", re.search(r"IF v_status = '([^']+)'", sql).group(1))
print("verify_journal revoked:", "REVOKE EXECUTE ON FUNCTION public.verify_journal" in sql)
