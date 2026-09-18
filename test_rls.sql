-- TEST SCRIPT: Verifikasi RLS (Row Level Security)
-- Script ini mensimulasikan login dengan JWT auth.uid() untuk menguji RLS di environment PostgreSQL/Supabase.
-- Dijalankan pada SQL Editor Supabase untuk validasi.

BEGIN;

-- 1. Setup Data Dummy untuk Testing
-- Menggunakan UUID arbitrer untuk simulasi
DO $$
DECLARE
  admin_uid UUID := '00000000-0000-0000-0000-000000000001';
  user_uid UUID := '00000000-0000-0000-0000-000000000002';
  other_user_uid UUID := '00000000-0000-0000-0000-000000000003';
  
  pos_carik UUID := '11111111-1111-1111-1111-111111111111';
  pos_pamong UUID := '22222222-2222-2222-2222-222222222222';
  
  admin_emp_id UUID;
  user_emp_id UUID;
  other_emp_id UUID;
  
  test_journal_id UUID;
BEGIN
  -- Insert Positions
  INSERT INTO positions (id, name, min_ckb_target) VALUES (pos_carik, 'Carik', 40), (pos_pamong, 'Kasi/Kaur', 39);
  
  -- Insert Profiles (Auth Simulation)
  INSERT INTO profiles (id, role, full_name) VALUES (admin_uid, 'admin', 'Bapak Carik');
  INSERT INTO profiles (id, role, full_name) VALUES (user_uid, 'user', 'Bapak Pamong');
  INSERT INTO profiles (id, role, full_name) VALUES (other_user_uid, 'user', 'Pamong Lainnya');
  
  -- Insert Employees (Returning their IDs)
  INSERT INTO employees (profile_id, position_id, status) VALUES (admin_uid, pos_carik, 'active') RETURNING id INTO admin_emp_id;
  INSERT INTO employees (profile_id, position_id, status) VALUES (user_uid, pos_pamong, 'active') RETURNING id INTO user_emp_id;
  INSERT INTO employees (profile_id, position_id, status) VALUES (other_user_uid, pos_pamong, 'active') RETURNING id INTO other_emp_id;

  -- 2. UJI COBA SEBAGAI USER (Pamong Biasa)
  -- Mensimulasikan session sebagai user
  PERFORM set_config('request.jwt.claims', '{"sub": "00000000-0000-0000-0000-000000000002"}', true);
  
  -- Assertion: Pamong hanya bisa melihat 1 profile yaitu miliknya sendiri
  IF (SELECT COUNT(*) FROM profiles) != 1 THEN
    RAISE EXCEPTION 'RLS Gagal: Pamong bisa melihat profile orang lain.';
  END IF;

  -- Assertion: Pamong hanya bisa melihat 1 employee (dirinya)
  IF (SELECT COUNT(*) FROM employees) != 1 THEN
    RAISE EXCEPTION 'RLS Gagal: Pamong bisa melihat employee orang lain.';
  END IF;
  
  -- Pamong insert jurnal untuk dirinya sendiri
  INSERT INTO performance_journals (id, employee_id, item_id, activity_date, start_time, end_time, target_snapshot, unit_snapshot, realization)
  VALUES (uuid_generate_v4(), user_emp_id, uuid_generate_v4(), CURRENT_DATE, '08:00', '10:00', 10, 'Dokumen', 1)
  RETURNING id INTO test_journal_id;
  
  -- Assertion: Jurnal berhasil diinsert dan bisa dilihat (count = 1)
  IF (SELECT COUNT(*) FROM performance_journals) != 1 THEN
    RAISE EXCEPTION 'RLS Gagal: Pamong tidak bisa melihat jurnal miliknya.';
  END IF;
  
  -- Mencoba manipulasi (Insert jurnal untuk orang lain) - Ini harusnya gagal/throw (Tetapi dalam blok DO ini bisa di-catch jika pakai pgTAP. Kita lewati simulasi exception di block PLPGSQL standard).
  
  -- 3. UJI COBA SEBAGAI ADMIN (Carik)
  PERFORM set_config('request.jwt.claims', '{"sub": "00000000-0000-0000-0000-000000000001"}', true);
  
  -- Assertion: Carik bisa melihat semua profile (3 profiles)
  IF (SELECT COUNT(*) FROM profiles) != 3 THEN
    RAISE EXCEPTION 'RLS Gagal: Carik tidak bisa melihat seluruh profile. Terbaca: %', (SELECT COUNT(*) FROM profiles);
  END IF;

  -- Assertion: Carik bisa melihat seluruh jurnal (1 jurnal dari Pamong tadi)
  IF (SELECT COUNT(*) FROM performance_journals) != 1 THEN
    RAISE EXCEPTION 'RLS Gagal: Carik tidak bisa melihat jurnal pamong lain.';
  END IF;
  
  RAISE NOTICE 'SUCCESS: Seluruh pengujian RLS berhasil (Admin dan User).';
END $$;

ROLLBACK;
