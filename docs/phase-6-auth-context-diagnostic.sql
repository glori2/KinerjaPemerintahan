-- PHASE 6.4.2 DIAGNOSTIC: Caller Context Identification

-- 1. Check Function Owner and Security Definer configurations
SELECT 
    p.proname AS function_name,
    pg_get_userbyid(p.proowner) AS function_owner,
    p.prosecdef AS is_security_definer,
    p.proconfig AS search_path_config
FROM pg_proc p
WHERE p.proname = 'generate_calculations';

-- 2. Check current execution context (Run this in Supabase SQL Editor)
SELECT 
    current_user AS exec_current_user,
    session_user AS exec_session_user,
    current_setting('request.jwt.claims', true) AS native_jwt_claim,
    auth.uid() AS test_auth_uid,
    auth.role() AS test_auth_role,
    auth.jwt() AS test_auth_jwt;
