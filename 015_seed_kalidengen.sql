-- ============================================================
-- Migration 015 - Seed Kalidengen
-- Baseline: IMPLEMENTATION SPECIFICATION FINAL V3.2.2.4
-- ============================================================

BEGIN;

-- 1. SEED POSITIONS (Idempotent)
INSERT INTO public.positions (id, name, is_pamong_tukin_eligible) VALUES
  ('b0000000-0000-0000-0000-000000000001', 'Lurah', false),
  ('b0000000-0000-0000-0000-000000000002', 'Carik', true),
  ('b0000000-0000-0000-0000-000000000003', 'Danarta', true),
  ('b0000000-0000-0000-0000-000000000004', 'Panata Laksana Sarta Pangripta', true),
  ('b0000000-0000-0000-0000-000000000005', 'Jagabaya', true),
  ('b0000000-0000-0000-0000-000000000006', 'Ulu-Ulu', true),
  ('b0000000-0000-0000-0000-000000000007', 'Kamituwa', true),
  ('b0000000-0000-0000-0000-000000000008', 'Dukuh', true),
  ('b0000000-0000-0000-0000-000000000009', 'Staf', false)
ON CONFLICT (name) DO UPDATE SET is_pamong_tukin_eligible = EXCLUDED.is_pamong_tukin_eligible;

-- 2. SEED VILLAGE SETTINGS (Idempotent)
INSERT INTO public.village_settings (setting_key, setting_value)
VALUES ('working_days', '{"hk": 22}'::jsonb)
ON CONFLICT (setting_key) DO UPDATE SET setting_value = EXCLUDED.setting_value;

-- 3. SEED TUKIN PARAMETERS
INSERT INTO public.tukin_parameters (position_id, effective_from, pagu_tukin, min_ckb_target)
SELECT 'b0000000-0000-0000-0000-000000000001', '2027-01-01'::DATE, 1561000, 0
WHERE NOT EXISTS (
    SELECT 1 FROM public.tukin_parameters 
    WHERE position_id = 'b0000000-0000-0000-0000-000000000001' AND effective_from = '2027-01-01'::DATE
);
INSERT INTO public.tukin_parameters (position_id, effective_from, pagu_tukin, min_ckb_target)
SELECT 'b0000000-0000-0000-0000-000000000002', '2027-01-01'::DATE, 1384950, 40
WHERE NOT EXISTS (
    SELECT 1 FROM public.tukin_parameters 
    WHERE position_id = 'b0000000-0000-0000-0000-000000000002' AND effective_from = '2027-01-01'::DATE
);
INSERT INTO public.tukin_parameters (position_id, effective_from, pagu_tukin, min_ckb_target)
SELECT 'b0000000-0000-0000-0000-000000000003', '2027-01-01'::DATE, 1223600, 39
WHERE NOT EXISTS (
    SELECT 1 FROM public.tukin_parameters 
    WHERE position_id = 'b0000000-0000-0000-0000-000000000003' AND effective_from = '2027-01-01'::DATE
);
INSERT INTO public.tukin_parameters (position_id, effective_from, pagu_tukin, min_ckb_target)
SELECT 'b0000000-0000-0000-0000-000000000004', '2027-01-01'::DATE, 1223600, 39
WHERE NOT EXISTS (
    SELECT 1 FROM public.tukin_parameters 
    WHERE position_id = 'b0000000-0000-0000-0000-000000000004' AND effective_from = '2027-01-01'::DATE
);
INSERT INTO public.tukin_parameters (position_id, effective_from, pagu_tukin, min_ckb_target)
SELECT 'b0000000-0000-0000-0000-000000000005', '2027-01-01'::DATE, 1223600, 39
WHERE NOT EXISTS (
    SELECT 1 FROM public.tukin_parameters 
    WHERE position_id = 'b0000000-0000-0000-0000-000000000005' AND effective_from = '2027-01-01'::DATE
);
INSERT INTO public.tukin_parameters (position_id, effective_from, pagu_tukin, min_ckb_target)
SELECT 'b0000000-0000-0000-0000-000000000006', '2027-01-01'::DATE, 1223600, 39
WHERE NOT EXISTS (
    SELECT 1 FROM public.tukin_parameters 
    WHERE position_id = 'b0000000-0000-0000-0000-000000000006' AND effective_from = '2027-01-01'::DATE
);
INSERT INTO public.tukin_parameters (position_id, effective_from, pagu_tukin, min_ckb_target)
SELECT 'b0000000-0000-0000-0000-000000000007', '2027-01-01'::DATE, 1223600, 39
WHERE NOT EXISTS (
    SELECT 1 FROM public.tukin_parameters 
    WHERE position_id = 'b0000000-0000-0000-0000-000000000007' AND effective_from = '2027-01-01'::DATE
);
INSERT INTO public.tukin_parameters (position_id, effective_from, pagu_tukin, min_ckb_target)
SELECT 'b0000000-0000-0000-0000-000000000008', '2027-01-01'::DATE, 1140300, 38
WHERE NOT EXISTS (
    SELECT 1 FROM public.tukin_parameters 
    WHERE position_id = 'b0000000-0000-0000-0000-000000000008' AND effective_from = '2027-01-01'::DATE
);

-- 4. SEED AUTH.USERS (Idempotent for trusted provisioning)
INSERT INTO auth.users (id, aud, role, email) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'sunardi@kalidengen.desa.id'),
  ('a0000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'carik@kalidengen.desa.id'),
  ('a0000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'viki@kalidengen.desa.id'),
  ('a0000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated', 'agus@kalidengen.desa.id'),
  ('a0000000-0000-0000-0000-000000000005', 'authenticated', 'authenticated', 'subarno@kalidengen.desa.id'),
  ('a0000000-0000-0000-0000-000000000006', 'authenticated', 'authenticated', 'saridi@kalidengen.desa.id'),
  ('a0000000-0000-0000-0000-000000000007', 'authenticated', 'authenticated', 'sumardi@kalidengen.desa.id'),
  ('a0000000-0000-0000-0000-000000000008', 'authenticated', 'authenticated', 'widi@kalidengen.desa.id'),
  ('a0000000-0000-0000-0000-000000000009', 'authenticated', 'authenticated', 'rendi@kalidengen.desa.id'),
  ('a0000000-0000-0000-0000-000000000010', 'authenticated', 'authenticated', 'edi@kalidengen.desa.id')
ON CONFLICT (id) DO NOTHING;

-- 5. TRUSTED PROVISIONING (Idempotent)
DO $$
DECLARE
    v_emp_id UUID;
BEGIN
    SELECT id INTO v_emp_id FROM public.employees WHERE profile_id = 'a0000000-0000-0000-0000-000000000001';
    IF v_emp_id IS NULL THEN
        PERFORM public.provision_employee_identity(
            'a0000000-0000-0000-0000-000000000001', 'user'::public.app_profile_role, 'Sunardi', '197001012000011001', 'b0000000-0000-0000-0000-000000000001', '2027-01-01'::DATE
        );
    END IF;
    SELECT id INTO v_emp_id FROM public.employees WHERE profile_id = 'a0000000-0000-0000-0000-000000000002';
    IF v_emp_id IS NULL THEN
        PERFORM public.provision_employee_identity(
            'a0000000-0000-0000-0000-000000000002', 'admin'::public.app_profile_role, 'Muh. Masruri Mustofa', '197502022005011002', 'b0000000-0000-0000-0000-000000000002', '2027-01-01'::DATE
        );
    END IF;
    SELECT id INTO v_emp_id FROM public.employees WHERE profile_id = 'a0000000-0000-0000-0000-000000000003';
    IF v_emp_id IS NULL THEN
        PERFORM public.provision_employee_identity(
            'a0000000-0000-0000-0000-000000000003', 'user'::public.app_profile_role, 'Viki Wulandari', '198003032010012003', 'b0000000-0000-0000-0000-000000000003', '2027-01-01'::DATE
        );
    END IF;
    SELECT id INTO v_emp_id FROM public.employees WHERE profile_id = 'a0000000-0000-0000-0000-000000000004';
    IF v_emp_id IS NULL THEN
        PERFORM public.provision_employee_identity(
            'a0000000-0000-0000-0000-000000000004', 'user'::public.app_profile_role, 'Agus Endarto', '198504042015011004', 'b0000000-0000-0000-0000-000000000004', '2027-01-01'::DATE
        );
    END IF;
    SELECT id INTO v_emp_id FROM public.employees WHERE profile_id = 'a0000000-0000-0000-0000-000000000005';
    IF v_emp_id IS NULL THEN
        PERFORM public.provision_employee_identity(
            'a0000000-0000-0000-0000-000000000005', 'user'::public.app_profile_role, 'Subarno', '199005052020011005', 'b0000000-0000-0000-0000-000000000005', '2027-01-01'::DATE
        );
    END IF;
    SELECT id INTO v_emp_id FROM public.employees WHERE profile_id = 'a0000000-0000-0000-0000-000000000006';
    IF v_emp_id IS NULL THEN
        PERFORM public.provision_employee_identity(
            'a0000000-0000-0000-0000-000000000006', 'user'::public.app_profile_role, 'Saridi', '198806062021011006', 'b0000000-0000-0000-0000-000000000006', '2027-01-01'::DATE
        );
    END IF;
    SELECT id INTO v_emp_id FROM public.employees WHERE profile_id = 'a0000000-0000-0000-0000-000000000007';
    IF v_emp_id IS NULL THEN
        PERFORM public.provision_employee_identity(
            'a0000000-0000-0000-0000-000000000007', 'user'::public.app_profile_role, 'Sumardi', '198907072022011007', 'b0000000-0000-0000-0000-000000000007', '2027-01-01'::DATE
        );
    END IF;
    SELECT id INTO v_emp_id FROM public.employees WHERE profile_id = 'a0000000-0000-0000-0000-000000000008';
    IF v_emp_id IS NULL THEN
        PERFORM public.provision_employee_identity(
            'a0000000-0000-0000-0000-000000000008', 'user'::public.app_profile_role, 'Widi Hartono', '199108082023011008', 'b0000000-0000-0000-0000-000000000008', '2027-01-01'::DATE
        );
    END IF;
    SELECT id INTO v_emp_id FROM public.employees WHERE profile_id = 'a0000000-0000-0000-0000-000000000009';
    IF v_emp_id IS NULL THEN
        PERFORM public.provision_employee_identity(
            'a0000000-0000-0000-0000-000000000009', 'user'::public.app_profile_role, 'Rendi Ardiyanto', '199509092024011009', 'b0000000-0000-0000-0000-000000000008', '2027-01-01'::DATE
        );
    END IF;
    SELECT id INTO v_emp_id FROM public.employees WHERE profile_id = 'a0000000-0000-0000-0000-000000000010';
    IF v_emp_id IS NULL THEN
        PERFORM public.provision_employee_identity(
            'a0000000-0000-0000-0000-000000000010', 'user'::public.app_profile_role, 'Edi Supriyanto', '199210102025011010', 'b0000000-0000-0000-0000-000000000008', '2027-01-01'::DATE
        );
    END IF;
END $$;

-- 6. SEED MATRIX VERSIONS & TARGETS
DO $$
DECLARE
    v_mat_id UUID;
    v_grp_id UUID;
    v_item_id UUID;
BEGIN
    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000002' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000002', 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pengoordinasian administrasi Pemerintahan
Kalurahan') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pencermatan tata naskah surat sebelum dibubuhkan paraf dan/atau tanda tangan (contoh: pencermatan Surat Keputusan sebelum diparaf/tanda tangan).', 'Surat/dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 16, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya koordinasi dalam rangka inventarisasi arsip, surat, dan lain-lain. (contoh: koordinasi penyimpanan arsip kepada pamong kalurahan)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya koordinasi dalam penataan administrasi pamong kalurahan (contoh: koordinasi kepada pamong terkait dengan pengisian laporan kinerja, penyusunan dokumen-dokumen kelengkapan BLT DD, dll)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya koordinasi dalam rangka penyedian sarana dan prasarana kalurahan (contoh: koordinasi kepada kaur panata laksana sarta pangripta untuk membeli sapu, merencanakan di kegiatan APBDES untuk dianggarakan belanja seragam)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya koordinasi pelaksanaan Musyawarah, Pertemuan, Rapat, dll. (contoh: Koordinasi Pelaksaan Muskal, Musrenbang, Rakor, dll)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 24, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya koordinasi pelaksanaan inventarisasi aset kalurahan (contoh: koordinasi kepada Palapa untuk melaksanakan kegiatan inventarisasi aset Kalurahan Janten)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksana koordinasi fasilitasi pelayanan umum (contoh: Koordinasi kepada Kaur Palapa untuk melaksanakan pelayanan menggunakan SID)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pembubuhan paraf dalam SPJ dan/atau SPP kegiatan dan memberikan koreksi apabila ditemukan ketidaksesuaian. (contoh: paraf pada SPP siltap Pamong)', 'dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 32, 3);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya koordinasi penganggaran dari berbagai sumber dan kegiatan kasi dan/atau kaur. (contoh: menghitung prosentase prioritas wajib yang harus dipenuhi pada tiap penganggaran dan kegiatan-kegiatan lainnya)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya koordinasi pelaksanaan pembuatan proposal usulan Dana Keistimewaan dan Musyawarah/pertemuan lain terkait dengan Usulan Dana Keistimewaan. (contoh: koordinasi pembuatan proposa papan nama)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Koordinasi, pengendalian dan evaluasi terhadap perencanaan dan pelaksanaan kegiatan Pemerintah Kalurahan.') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya koordinasi pengendalian dan evaluasi kegiatan Kasi dan/atau kaur. (contoh: koordinasi kegiatan siltap segera dibuat kelengkapan supaya dapat segera cair, kegiatan musyawarah kalurahan supaya sesuai dengan agenda waktu dalam perundang-undangan yang berlaku)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 16, 2);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pelaksanaan pengelolaan keuangan.') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya koordinasi penyusunan dan pelaksanaan kebijakan anggaran pendapatan dan belanja kalurahan (Koordinasi pelaksanaan kegiatan sinkronisasi dengan sumber dana)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya koordinasi penyusunan Peraturan Lurah Penjabaran APB Kalurahan dan/atau perubahan Penjabaran APB Kalurahan, dalam rangka singkronisasi antara kebutuhan dan anggaran. (contoh: koordinasi terkait dengan perubahan kegiatan dan sumber dana perubahan tersebut berasal dari kegiatan apa)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya koordinasi penyusunan Pertanggungjawaban pelaksanaan anggaran pendapatan dan belanja kalurahan. (contoh: koordinasi kegiatan penyusunan laporan laporan akhir tahun, LPPD, dan LKPD)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Tugas Pamong Kalurahan Lain yang menjalankan tugas Pelaksana Pengelolaan Keuangan Kalurahan (PPKK) (contoh: koordinasi agenda kegiatan masing-masing kasi dan/atau kaur sesuai dengan RAB)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya verifikasi terhadap Dokumen Pelaksanaan Anggaran (DPA), Dokumen Pelaksanaan Perubahan Anggaran (DPPA), Dokumen Pelaksanaan Anggaran Lanjutan (DPAL), Rencana Anggaran Kas Kalurahan (RAK Kalurahan), Surat Perintah Pembayaran (SPP) dan bukti penerimaan dan pengeluaran anggaran pendapatan dan belanja kalurahan.', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 24, 2);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pelaksanaan tugas lain yang diberikan oleh Lurah') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Penyusun RKP Kalurahan) ', 'tim') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Padukuhan (Musduk)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 0, 0);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 0, 0);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 0, 0);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini dan melaporakan hasil pelaksanaannya kepada lurah.', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, '') RETURNING id INTO v_grp_id;
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000007' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000007', 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan kegiatan sosial kemasyarakatan') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyuluhan dan motivasi di dalam forum pertemuan terhadap pelaksanaan hak dan kewajiban masyarakat. (contoh: penyampaian informasi tentang gaya hidup sehat, pelayanan di kalurahan, pajak, gotong royong dll)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Kehadiran di kegiatan latihan, pementasan atau kegiatan latihan serta memberikan motivasi maupun informasi berkaitan dengan kegiatan kebudayaan kepada kelompok tersebut. (contoh: menghadiri kegiatan latihan Sholawat, Ketoprak, hadroh, dll kemudian memberikan informasi mengenai informasi/regulasi terbaru tentang prosedur pengajuan proposal dalam rangka pengembangan kegiatan tersebut', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Penyuluhan dan motivasi di bidang keagamaan, ketenagakerjaan, pemberdayaan perempuan, perlindungan anak, keluarga berencana, pendidikan, kesehatan, pemuda, olahraga, karang taruna dan penanggulangan kemiskinan') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyampaian Informasi ke Masyarakat dalam sebuah forum pertemuan terkait dengan bidang keagamaan, ketenagakerjaan, pemberdayaan perempuan, perlindungan anak, keluarga berencana, Pendidikan, kesehatan, pemuda, olahraga, karangtaruna dan penanggulangan kemiskinan. (contoh: Menghadiri pertemuan Kegiatan Posyandu, Kader, IP3M/PAUD, dll., kemudian menyampaikan informasi terkait tata cara/prosedur pengajuan BPJS PBI', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Kegiatan urusan keistimewaan bidang kebudayaan') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pendampingan terkait pelaksanaan kegiatan kebudayaan yang ada di kalurahan (contoh: Menghadiri latihan kegiatan Merti Padukuhan, Wiwitan, Puputan, Tingkepan, dll., sehingga mengetahui terkait dengan eksistensi kegiatan tersebut yang dapat digunakan sebagai dasar perencanaan kegiatan di APBKAL maupun kegiatan dari dinas terkait)', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pelaksanaan Kegiatan Anggaran') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Penyelenggaraan PAUD/TK/TPA/TKA/TPQ/Madrasah Non-Formal Milik Kalurahan Janten*', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Penyelenggaraan Posyandu*', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 12, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Penyuluhan dan Pelatihan Bidang Kesehatan*', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Menghadiri pertemuan Rutin PKK', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Menghadiri pertemuan Rutin Karangtaruna', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Menghadiri pertemuan Kader Posyandu', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Penyaluran Honor Rois', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Program Beasiswa', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Monev Beasiswa', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Keadaan Mendesak (Penyaluran BLT)*', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pelayanan sesuai bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pelayanan kepada warga masyarakat terkait dengan pernikahan. (contoh: Melayani konsultasi warga tentang tata cara/prosedur persyaratan-persyaratan pernikahan, izin melaksanakan Pengajian  lainnya)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pelayanan warga masyarakat terkait dengan bidang keagamaan, budaya, olahraga, karangtaruna, social, keluarga, pendidikan, pemberdayaan perempuan, perlindungan anak, dll. (contoh: Melayani konsultasi kelompok-kelompok budaya, olahraga, keagamaan, dll terkait tata cara/prosedur izin kegiatan, pengajuan proposal, dll)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Mencari salinan landasan hukum tentang Posyandu, PAUD dll)', 'dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai Kepemilikan Jaminan kesehatan masyarakat', 'Bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya (contoh: Menyampaikan laporan secara lisan tertulis kepada Lurah tentang sosial kemasyarakatan, keagaman, kesehatan dan kebudayaan misalnya pelaksanaan PMT, Tracing kesehatan , pemantuan jentik dll)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil (contoh: Memberikan saran dan pertimbangan mengenai kebijakan pelaksanaan merti kalurahan, hari jadi kalurahan, kegiatan peringatan HUT RI, dll)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Melaksanakan Tugas lain yang diberikan oleh Lurah') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Kegiatan Posyandu)', 'tim') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'SPP') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 30, 3);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti pertemuan di Padukuhan dan atau Musduk', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya sambutan wakil keluarga atau sebutan lain dalam upacara pernikahan, lamaran, lelayu, dll . (contoh: sambutan wakil keluarga upacara pemberangkatan jenazah)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini.', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya. ', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, '') RETURNING id INTO v_grp_id;
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000003' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000003', 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'b') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan urusan keuangan.') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Membuat Buku Kas Umum', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Membuat Buku Kas Tunai', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Membuat Buku bantu Bank', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Membuat Buku bantu Pajak', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Membuat Buku bantu Kegiatan', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Membuat Buku Penutupan Kas', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Berkoordinasi bersama carik dan pamong melakukan Penyusunan Dokumen Keuangan Kalurahan (misal: memberi masukan terkait laporan keuangan sehingga menjadi dasar penyusunan APB Kalurahan/APB Kalurahan Perubahan/LPJ APB Kalurahan, dll)*', 'Dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersalurnya Siltap tujangan Pamong dan BPK', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Melakukan Pemotongan Pajak, input biling, menyetorkan dan mencatatkan pada aplikasi siskeudes  Paling lambat 5 hari bulan berikutnya', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 15, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengajukan permohonan pencairan Alokasi Dana desa (ADD)', 'Bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Membuat rencana pencairan, melakukan transaksi dan membukukan pada aplikasi siskeudes', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 32, 3);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Menyusun laporan pertanggungjawaban realisasi pelaksanaan anggaran pendapatan dan belanja kalurahan') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Membuat laporan realisasi bulanan', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Membuat laporan realisasi semester II', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Membuat Laporan realisasi akhir tahun', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Melakukan penatausahaan keuangan yang meliputi menerima menyimpan, menyetorkan/membayar, menatausahakan dan mempertanggungjawabkan penerimaan pendapatan Kalurahan dan pengeluaran dalam rangka pelaksanaan anggaran pendapatan dan belanja kalurahan') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Menerima, Menyetorkan  dan melakukakan pencatatan pendapatan kalurahan pada aplikasi siskeudes', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Pencarian Permendesa tentang Prioritas Penggunaan Dana Desa dll  kemudian mererapkan  sekaligus mengarsipkannya dengan tertib)', 'arsip') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 6, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (contoh: Menyampaikan laporan terkait dengan hasil presentasi/desk rancangan APBKAL, perubahan, dll)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 6, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Melaksanakan Tugas lain yang diberikan oleh Lurah') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam Tim Penyusunan Rencana Kerja Pemerintah Kalurahan) ', 'tim') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Padukuhan dan atau pertemuan lainnya di tigka padukuhan (Musduk)', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini.', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, '') RETURNING id INTO v_grp_id;
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000006' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000006', 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan kegiatan pembangunan dan kemakmuran') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'Dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 12, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan ', 'Dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 25, 3);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Pemantauan terhadap Pemanfaatan  Lumbung pangan Kalurahan dan melaporkan kepada lurah baik lisan maupun tertulis', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Monitoring dan Evaluasi terhadap Bantuan dan atau pembanguan yang telah dilaksanakan (Misal Perbaikan Atap TKK PKK, Perkerasan Jalan, Bantuan alat-alat pembuatan pupuk dsb ) dan melaporkan kepada lurah baik lisan maupun tertulis', 'Kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya sosialisasi, motivasi dan peningkatan kapasitas masyarakat di bidang ekonomi dan lingkungan hidup. (contoh: penyampaian informasi di dalam forum pertemuan tentang program pembanguanan di desa)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pendataan dan pengelolaan profil kalurahan di Web/Aplikasi Prodeskel, sinkal dan IDM(Profil Desa/Kelurahan)', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'menginisiasi, mengkoordinasi dan atau menghadiri pertemuan lembaga (misal P3A Kelompok Tani, Gapoktan, KWT dll)', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyebarluasan informasi rencana tata ruang pada satuan ruang strategis (contoh: menyampaikan di forum pertemuan terkait dengan informasi Tanah Keprabon dan/atau bukan Keprabon di daerah kulon progo sesuai dengan ketentuan yang berlaku)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengkoordinasi, memantau, memastikan dan atau ikut serta dalam penyusunan Rencana Definitif Kebutuhan Kelompok (RDKK)', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pelaksanaan Kegiatan Anggaran') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Informasi Publik Desa baik melalui media online maupun offline (Misal Banner APKal, Realisasi APBkal dll)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Pembangunan/Rehabilitasi/Peningkatan Perkerasan Jalan Desa', 'Bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Pembangunan Jaringan Pengairan ', 'Bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanaya Pengisian Direktur Bumkal', 'Bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanaya Bimtek/Pelatihan  Pengelolaan Bumkal', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pelayanan Sesuai bidang Tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pelayanan kepada warga masyarakat terkait dengan bidang tugasnya. (contoh: Melayani konsultasi warga tentang tata cara/prosedur persyaratan-persyaratan pengajuan IMB, SKU dll)', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Mencari salinan Perbup Nomor 16 Tahun 2020 tentang Tata Cara Pelaksanaan Kegiatan Pengadaan Barang/Jasa di Kalurahan, kemudian mempelajari, menerapkan dan mengarsipkannya dengan tertib sehingga siap disajikan apabila sewaktu-waktu dibutuhkan)', 'produk') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Membuat, mengisi dan mengarsipkan Buku administrasi Pemangunan (Buku Rencana Pembangunan, Buku Kegiatan Pembangunan, Buku Inventaris dan Buku Kader Pembangunan )', 'Buku') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya Laporan Kepada lurah tentang kegiatan yang diikuti (Misal : Hasil rapat, kelompoktani, gapotan, musyawarah musim tanam kemudian mempublikasikan kepada masayarakat baik secara tertulis maupun melalui forum pertemuan', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Melaksanakan Tugas lain yang diberikan oleh Lurah') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam Tim Penyusun RKP Kalurahan) ', 'tim') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah. ', 'dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'spp') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, '') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, '') RETURNING id INTO v_grp_id;
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000005' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000005', 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan kegiatan pemerintahan dan keamanan') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya evaluasi manajemen tata praja pemerintahan (evaluasi terhadap pelayanan dan kearsipan)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyusun rancangan produk regulasi. (contoh: Menyusun rancangan Peraturan Kaluran, Peraturan Lurah, Surat Keputusan, dll kemudian di sampaikan kepada carik untuk diverifikasi)', 'produk') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pengendalian dan evaluasi kegiatan pembinaan ketentraman dan ketertiban dan melaporkannya kepada lurah. (contoh: Ikut dalam kegiatan penyelesaian permasalahan sosial di masyarakat)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Kegiatan Pembinaan terhadap Linmas, Forum Jagawarga', '') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya kegiatan Upaya Perlindungan Masyarakat (Misal kegiatan yang dilakukakan linmas, Forum jaga warga. ikut dalam pengamanan terhadap kegiatan keramaian di desa', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Monitoring kegiatan siskamling', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya koordinasi Pencegahan dan atau penanggulangan bencana. (contoh: Hadir dan aktif berkoordinasi dengan pihak terkait saat terjadi bencana banjir, kebakaran, pohon tumbang)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 9, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Updating data kependudukan', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pengarsipan peta kalurahan yang ada dengan tertib.(Baik Hardcopy maupun Aplikasi/Digital)', 'Peta') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Kegiatan urusan Keistimewaan bidang pertanahan') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya update pencatatan dan Inventaris terkait dengan Pemanfaatan dan Pengelolaan Tanah Kalurahan sebagai Dasar dalam Penyusunan Peraturan Kalurahan tentang Pengelolaan Kekayaan Kalurahan. (contoh: daftar tanah kalurahan beserta  pemanfaatannya)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pengadministrasian tanah kalurahan dan pemanfaatannya serta penyusunan Peraturan Kalurahan terkait dengan tanah kalurahan termasuk fasilitasi permohonan izin gubernur.', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pelaksanaan kegiatan anggaran') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terpenuhinya Kebutuhan Operasional Kantor BPK', 'Kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksannya kegiatan RT RW', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2); -- [INKONSISTENSI SPREADSHEET] Jumlah bulan = 19, Annual = 20
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya kegiatan Updating Aplikasi Prodeskel, IDM dan Sinkal', 'Kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya Perjanjian Kinerja Lurah, Laporan Kinarja dan Survei Kepuasan Masyarakat', 'Dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunya Laporan Penyelenggaraan Pemerintah Kalurahan (LPPK)', 'Dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pengembangan Sistem Informasi Kalurahan', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya Pelatihan/Sosialisasi Penanggulangan Bencana', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pelayanan sesuai bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pelayanan bidang Kependudukan, dan ijin keramaian dll)', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 16, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya fasilitasi Pelaksanaan Klarifikasi Pertanahan dan urusan pertanahan lainnya. (contoh: turun waris, hibah, konsolidasi tanah, dll)', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Pelayanan lain sesuai bidang tugasnya selain yang sudah tercantum dalam output kegiatan di atas.', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib.(contoh: Pencarian Pergub Nomor 34 Tahun 2017  kemudian mererapkan dalam pengelolaan dan pemanfaatan tanah kalurahan sekaligus mengarsip)', 'produk') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (contoh: Menyampaikan laporan baik secara tertulis maupun lisan kepada Lurah setelah melaksanakan penyelesaian permasalahan social yang terjadi di masyarakat)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pelaksanaan tugas lain yang diberikan oleh Lurah') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Kegiatan Sistem Informasi Kalurahan) ', 'tim') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 9, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'SPP') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Padukuhan dan atau pertemuan lainnya tingkat padukuhan (Musduk)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini dan melaporakan hasil pelaksanaannya kepada lurah.', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya. ', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'terlaksananya rapat koordinasi dan atau evaluasi PBB dan melaporkan hasilnya kepada lurah', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, '') RETURNING id INTO v_grp_id;
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000004' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000004', 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'b') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan urusan ketatausahaan, umum dan perencanaan') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pencermatan dan pembuatan surat sesuai tata naskah yang berlaku baik manual maupun melalui aplikasi persyuratan (contoh: membuat surat undangan, surat pengantar pengiriman Peraturan Kalurahan kepada Panewu Pengasih)', 'surat/dok.') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya register surat masuk, baik secara langsung/offline maupun melalui SID/suratku/elektronik), menyampiakan kepada lurah dan atau lainnya serta menyampaikan disposisi surat ', 'surat/dok.') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya registrasi surat keluar baik secara langsung/offline maupun melalui SID/suratku/elektronik) dan mengkoordinasi pendistribusianya (contoh: Penulisan nomor pada buku agenda surat keluar kepada Dinas PMD Dalduk dan KB ', 'surat/dok.') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksana register ekspedisi (contoh: Penulisan di buku ekspedisi Surat Dinas kepada Kapanewon Pengasih)', 'register') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penulisan agenda kegiatan di papan jadwal agenda kegiatan dalam aplikasi online maupan media offline', 'agenda') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyiapan rapat (contoh: berkoordinasi dengan staf dan pamong lain yang sekiranya bisa membantu dalam menyiapkan tempat, sarana prasarana, konsumsi, MC, dirijen lagu pada kegiatan musyawarah kalurahan)', 'rapat') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 15, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pencatatan dan inventarisasi aset kalurahan (contoh: menempel stiker nomor di kursi/meja/computer, dll dan dicatatkan di dalam buku aset)', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya fasilitasi koordinasi pelayanan umum (contoh: menyampaikan kepada staf dan/atau pamong lain terkait update aturan pelayanan persuratan, update SOP pelayanan, dll)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya kegiatan tata usaha, umum dan perencanaan terkait dengan keistimewaan (contoh: Pembuatan proposal usulan terkait Dana Keisimewaaan, pelaksanaan Musyawarah Kalurahan usulan kegiatan yang di danai Dana Keistimewaan)', '') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Berkoordinasi dengan Pamong lainnya dan memastikan dokumen administrasi Pamong Kalurahan dilaksanakan sebagaimana peraturan yang berlaku (misal berkoordinasi dengan Ulu-ulu terkait Buku administrasi  Pembangunan, berkoordinasi dengan carik terkait buku agenda perkal berkoordinasi dengan Jagabay terkait administrasi pertanahan dll). ', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyediaan prasarana kantor kalurahan (contoh: Pemenuhan kebutuhan lampu, kipas angin, cat tembok, dll)', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyediaan prasarana pamong kalurahan (contoh: ATK, alat kebersihan dan alat listrikl)', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya input data pamong di aplikasi dan manual (update) (contoh: Mencatat dan melakukan update berkala di buku pamong kalurahan/aparatur pamong kalurahan dan input/update berkala di aplikasi SID maupun SIAPDES maupun aplikasi lainnya yang relevan)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pembuatan bagan susunan organisasi tata kerja pemerintah kalurahan (update) dan atau Lembaga lainnya', 'bagan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pemenuhan kebutuhan kerumahtanggaan pemerintah kalurahan (contoh: koordinasi terkait teknis dalam pemenuhan kebutuhan gula, gas, teh, sabun, dll)', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pelaporan aset semester I dan semester II', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Melaksanaan kegiatan anggaran') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Penyaluran siltap dan Jaminan Sosial bagi Lurah dan Pamong*', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Penyediaan Operasional Pemerintah Kalurahan*', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Penyediaan Operasional Pemerintah Kalurahan yang bersumber dari Dana Desa*', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Pembangunan/Rehabilitasi/Peningkatan Gedung/Prasarana Kantor Kalurahan*', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Penyelenggaraan Musyawarah Perencanaan Kalurahan/Pembahasan APBKal Kalurahan*', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Penyelenggaraan Musyawarah Kalurahan Lainnya (Musduk, rembug warga dan lain-lain yang bersifat non-reguler)*', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Penyusunan Dokumen Perencaan Kalurahan (RPJM Kal./RKP Kal., dll)*', 'Dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Pengelolaan/Administrasi/Inventarisasi/Penilaian Aset Kalurahan*', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Melaksanakan perekapan presensi pamong setiap bulan dan melaporkannya', 'bulan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'perjanjian kerja sama dengan penyedia atas pengadaan barang/jasa ( perjanjiann konsultan pembanguan, berkoordinasi dengan ulu-ulu terkait pengadaan meterial pembangunan kantor)', 'Dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Pencarian Peraturan Bupati Kulon Progo Nomor 67 Tahun 2019 tentang Pedoman Tata Naskah Dinas Pemerintah Kalurahan kemudian diterapkan dalam pembuatan surat dinas sekaligus mengarsipkannya dengan tertib)', 'produk') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (laporan pelaksanaan pembangunan kantor)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Melaksanaan tugas lain yang diberikan oleh Lurah') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam Tim Penyusunan RKP Kalurahan) ', 'tim') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip/dok.') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'surat/dok.') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'SPP') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Padukuhan (Musduk)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini.', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya. ', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, '') RETURNING id INTO v_grp_id;
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000008' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000008', 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Membantu pelaksanaan tugas Lurah di wilayah Padukuhan') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Pembinaan Ketentraman dan Ketertiban, mobilitas penduduk, penataan administratif (misal Koordinasi, ikut serta, atau monitoring kegiatan siskamling. Mencatat dan membukukan mobilisasi penduduk)', 'Kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Perencanaan, pelaksanaan dan evaluasi pembangunan di wilayahnya ( Misal Koordinasi dengan RT, RW, KKLKMK atau lainnya..)', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya dan/atau menghadiri kegiatan kerja bakti, dan/atau kegiatan lain terkait dengan upaya menjaga kebersihan dan kesehatan lingkungan di tingkat padukuhan maupun RT.', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya dan/atau menghadiri kegiatan persiapan pelaksanaan hajatan di masyarakat. (contoh: pernikahan, lamaran, pengajian, lelayu/pemberangkatan jenazah dan kegiatan masyarakat lainnya)', 'kegiatan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pemantauan dan melaporkan kepada lurah terkait dengan penggunaan dan pemanfaatan tanah kalurahan di wilayah masing-masing (contoh: Pemantauan terhadap tanah Kalurahan yang diapaki Fasum/Fasus dan membukukan dalam dalam buku khusus sehingga dapt dibukukan jika terdapat perubahan penggunan', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib.(misal Mengarsip Perkal, Perbup dan atau mambuat database kependudukan diwilayahnya)', 'produk') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Membantu pelayanan umum di kantor kalurahan;') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya terkait dengan pelayanan di kalurahan (contoh: surat keterangan usaha, surat keterangan domisili, surat keterangan tidak mampu, pengantar pernikahan, dan pelayanan lainnya yang dilayani oleh pemerintah kalurahan)', 'surat') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (contoh: Menyampaikan laporan baik secara tertulis  kepada Lurah setelah melaksanakan penyelesaian permasalahan social yang terjadi di masyarakat, atau kegiatan lainnya baik yaang dianggarak APBKal maupun tidak dianggarkan)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Melaksanakan Tugas lain yang diberikan oleh Lurah') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. (termasuk Undangan Kalurahan atau kapanewon)', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Kegiatan Posyandu, dll) ', 'tim') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pengantaran dan/atau pengambilan surat/dokumen terkait dengan tugas kedinasan.  ', 'dokumen') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melakukan evaluasi terhadap kegiatan yang dilakukakan di wilayahnua dan Melaporkan kepada lurah, termasuk permasalahan, hambatan, serta solusinya)', 'laporan') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengadakan Musyawarah Padukuhan (Musduk) dan atau pertemuan lainnya', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya sambutan atau sebutan lainnya di acara hajatan di masyarakat (contoh: pernikahan, lamaran, pengajian, lelayu/pemberangkatan jenazah dan kegiatan masyarakat lainnya)', 'acara') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksanannya pengkondisian permasalahan dan/atau bencana yang terjadi di wilayahnya selanjutnya melaporkan kepada lurah (contoh: banjir, tanah longsor, masalah sosial kemasyarakatan, dll)', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pendampingan pengantaran ODGJ, Donor darah atau Pengobatan', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini dan melaporakan hasil pelaksanaannya kepada lurah.', 'kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, 'Tercapainya Pembayaran PBB-P2 (non-Tanah Desa) di Padukuhan dalam 
(5 SPPT=1 poin).', 'poin') RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1); -- [INKONSISTENSI SPREADSHEET] Jumlah bulan = 9, Annual = 10
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, '') RETURNING id INTO v_grp_id;
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000009' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000009', 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Kedisiplinan Pelaksanaan Tugas') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pelayanan Prima (Keterangan: Pelayanan Selesai dalam waktu maksimal 10 menit)') RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, 'Pelaksanaan Tugas Pembantuan kepada Lurah dan Pamong') RETURNING id INTO v_grp_id;
    END IF;

END $$;

COMMIT;
