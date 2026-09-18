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

-- 4. AUTH USERS
-- Auth accounts MUST be created by Supabase Auth/Admin API before this migration runs.
-- This migration deliberately does NOT INSERT directly into auth.users.
-- The provisioning block below resolves users by email and then calls the trusted
-- provision_employee_identity() RPC to create/update application identity.

-- 5. TRUSTED PROVISIONING (Idempotent)
-- Requires the ten Auth accounts below to already exist in Supabase Auth.
DO $$
DECLARE
    r RECORD;
    v_user_id UUID;
    v_emp_id UUID;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('sunardi@kalidengen.desa.id', 'user'::public.app_profile_role, 'Sunardi', '197001012000011001', 'b0000000-0000-0000-0000-000000000001'::uuid),
            ('carik@kalidengen.desa.id', 'admin'::public.app_profile_role, 'Muh. Masruri Mustofa', '197502022005011002', 'b0000000-0000-0000-0000-000000000002'::uuid),
            ('viki@kalidengen.desa.id', 'user'::public.app_profile_role, 'Viki Wulandari', '198003032010012003', 'b0000000-0000-0000-0000-000000000003'::uuid),
            ('agus@kalidengen.desa.id', 'user'::public.app_profile_role, 'Agus Endarto', '198504042015011004', 'b0000000-0000-0000-0000-000000000004'::uuid),
            ('subarno@kalidengen.desa.id', 'user'::public.app_profile_role, 'Subarno', '199005052020011005', 'b0000000-0000-0000-0000-000000000005'::uuid),
            ('saridi@kalidengen.desa.id', 'user'::public.app_profile_role, 'Saridi', '198806062021011006', 'b0000000-0000-0000-0000-000000000006'::uuid),
            ('sumardi@kalidengen.desa.id', 'user'::public.app_profile_role, 'Sumardi', '198907072022011007', 'b0000000-0000-0000-0000-000000000007'::uuid),
            ('widi@kalidengen.desa.id', 'user'::public.app_profile_role, 'Widi Hartono', '199108082023011008', 'b0000000-0000-0000-0000-000000000008'::uuid),
            ('rendi@kalidengen.desa.id', 'user'::public.app_profile_role, 'Rendi Ardiyanto', '199509092024011009', 'b0000000-0000-0000-0000-000000000008'::uuid),
            ('edi@kalidengen.desa.id', 'user'::public.app_profile_role, 'Edi Supriyanto', '199210102025011010', 'b0000000-0000-0000-0000-000000000008'::uuid)
        ) AS x(email, app_role, full_name, nip_nipt, position_id)
    LOOP
        SELECT id INTO v_user_id
        FROM auth.users
        WHERE lower(email) = lower(r.email)
        LIMIT 1;

        IF v_user_id IS NULL THEN
            RAISE EXCEPTION 'Required Supabase Auth user % does not exist. Create the Auth account first, then rerun migration 015.', r.email
                USING ERRCODE = 'P0001';
        END IF;

        SELECT id INTO v_emp_id
        FROM public.employees
        WHERE profile_id = v_user_id;

        IF v_emp_id IS NULL THEN
            PERFORM public.provision_employee_identity(
                v_user_id, r.app_role, r.full_name, r.nip_nipt, r.position_id, '2027-01-01'::DATE
            );
        END IF;

        -- Validate the resulting active assignment.
        IF NOT EXISTS (
            SELECT 1
            FROM public.employees e
            JOIN public.employee_position_assignments a ON a.employee_id = e.id
            WHERE e.profile_id = v_user_id
              AND a.position_id = r.position_id
              AND a.status = 'active'
              AND a.effective_from = '2027-01-01'::DATE
        ) THEN
            RAISE EXCEPTION 'Identity % is not provisioned with the expected active position.', r.email
                USING ERRCODE = '23514';
        END IF;
    END LOOP;
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
        INSERT INTO public.matrix_versions (position_id, version_number, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000002', COALESCE((SELECT MAX(version_number) + 1 FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000002'), 1), 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pengoordinasian administrasi Pemerintahan
Kalurahan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pencermatan tata naskah surat sebelum dibubuhkan paraf dan/atau tanda tangan (contoh: pencermatan Surat Keputusan sebelum diparaf/tanda tangan).', 'Surat/dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 16, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya koordinasi dalam rangka inventarisasi arsip, surat, dan lain-lain. (contoh: koordinasi penyimpanan arsip kepada pamong kalurahan)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya koordinasi dalam penataan administrasi pamong kalurahan (contoh: koordinasi kepada pamong terkait dengan pengisian laporan kinerja, penyusunan dokumen-dokumen kelengkapan BLT DD, dll)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya koordinasi dalam rangka penyedian sarana dan prasarana kalurahan (contoh: koordinasi kepada kaur panata laksana sarta pangripta untuk membeli sapu, merencanakan di kegiatan APBDES untuk dianggarakan belanja seragam)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya koordinasi pelaksanaan Musyawarah, Pertemuan, Rapat, dll. (contoh: Koordinasi Pelaksaan Muskal, Musrenbang, Rakor, dll)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 24, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya koordinasi pelaksanaan inventarisasi aset kalurahan (contoh: koordinasi kepada Palapa untuk melaksanakan kegiatan inventarisasi aset Kalurahan Janten)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksana koordinasi fasilitasi pelayanan umum (contoh: Koordinasi kepada Kaur Palapa untuk melaksanakan pelayanan menggunakan SID)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pembubuhan paraf dalam SPJ dan/atau SPP kegiatan dan memberikan koreksi apabila ditemukan ketidaksesuaian. (contoh: paraf pada SPP siltap Pamong)', 'dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 32, 3);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya koordinasi penganggaran dari berbagai sumber dan kegiatan kasi dan/atau kaur. (contoh: menghitung prosentase prioritas wajib yang harus dipenuhi pada tiap penganggaran dan kegiatan-kegiatan lainnya)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya koordinasi pelaksanaan pembuatan proposal usulan Dana Keistimewaan dan Musyawarah/pertemuan lain terkait dengan Usulan Dana Keistimewaan. (contoh: koordinasi pembuatan proposa papan nama)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Koordinasi, pengendalian dan evaluasi terhadap perencanaan dan pelaksanaan kegiatan Pemerintah Kalurahan.', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya koordinasi pengendalian dan evaluasi kegiatan Kasi dan/atau kaur. (contoh: koordinasi kegiatan siltap segera dibuat kelengkapan supaya dapat segera cair, kegiatan musyawarah kalurahan supaya sesuai dengan agenda waktu dalam perundang-undangan yang berlaku)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 16, 2);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pelaksanaan pengelolaan keuangan.', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya koordinasi penyusunan dan pelaksanaan kebijakan anggaran pendapatan dan belanja kalurahan (Koordinasi pelaksanaan kegiatan sinkronisasi dengan sumber dana)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya koordinasi penyusunan Peraturan Lurah Penjabaran APB Kalurahan dan/atau perubahan Penjabaran APB Kalurahan, dalam rangka singkronisasi antara kebutuhan dan anggaran. (contoh: koordinasi terkait dengan perubahan kegiatan dan sumber dana perubahan tersebut berasal dari kegiatan apa)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya koordinasi penyusunan Pertanggungjawaban pelaksanaan anggaran pendapatan dan belanja kalurahan. (contoh: koordinasi kegiatan penyusunan laporan laporan akhir tahun, LPPD, dan LKPD)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Tugas Pamong Kalurahan Lain yang menjalankan tugas Pelaksana Pengelolaan Keuangan Kalurahan (PPKK) (contoh: koordinasi agenda kegiatan masing-masing kasi dan/atau kaur sesuai dengan RAB)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya verifikasi terhadap Dokumen Pelaksanaan Anggaran (DPA), Dokumen Pelaksanaan Perubahan Anggaran (DPPA), Dokumen Pelaksanaan Anggaran Lanjutan (DPAL), Rencana Anggaran Kas Kalurahan (RAK Kalurahan), Surat Perintah Pembayaran (SPP) dan bukti penerimaan dan pengeluaran anggaran pendapatan dan belanja kalurahan.', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 24, 2);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pelaksanaan tugas lain yang diberikan oleh Lurah', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Penyusun RKP Kalurahan) ', 'tim', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Padukuhan (Musduk)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 0, 0);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 0, 0);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 0, 0);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini dan melaporakan hasil pelaksanaannya kepada lurah.', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000007' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, version_number, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000007', COALESCE((SELECT MAX(version_number) + 1 FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000007'), 1), 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan kegiatan sosial kemasyarakatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyuluhan dan motivasi di dalam forum pertemuan terhadap pelaksanaan hak dan kewajiban masyarakat. (contoh: penyampaian informasi tentang gaya hidup sehat, pelayanan di kalurahan, pajak, gotong royong dll)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Kehadiran di kegiatan latihan, pementasan atau kegiatan latihan serta memberikan motivasi maupun informasi berkaitan dengan kegiatan kebudayaan kepada kelompok tersebut. (contoh: menghadiri kegiatan latihan Sholawat, Ketoprak, hadroh, dll kemudian memberikan informasi mengenai informasi/regulasi terbaru tentang prosedur pengajuan proposal dalam rangka pengembangan kegiatan tersebut', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Penyuluhan dan motivasi di bidang keagamaan, ketenagakerjaan, pemberdayaan perempuan, perlindungan anak, keluarga berencana, pendidikan, kesehatan, pemuda, olahraga, karang taruna dan penanggulangan kemiskinan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyampaian Informasi ke Masyarakat dalam sebuah forum pertemuan terkait dengan bidang keagamaan, ketenagakerjaan, pemberdayaan perempuan, perlindungan anak, keluarga berencana, Pendidikan, kesehatan, pemuda, olahraga, karangtaruna dan penanggulangan kemiskinan. (contoh: Menghadiri pertemuan Kegiatan Posyandu, Kader, IP3M/PAUD, dll., kemudian menyampaikan informasi terkait tata cara/prosedur pengajuan BPJS PBI', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Kegiatan urusan keistimewaan bidang kebudayaan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pendampingan terkait pelaksanaan kegiatan kebudayaan yang ada di kalurahan (contoh: Menghadiri latihan kegiatan Merti Padukuhan, Wiwitan, Puputan, Tingkepan, dll., sehingga mengetahui terkait dengan eksistensi kegiatan tersebut yang dapat digunakan sebagai dasar perencanaan kegiatan di APBKAL maupun kegiatan dari dinas terkait)', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pelaksanaan Kegiatan Anggaran', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Penyelenggaraan PAUD/TK/TPA/TKA/TPQ/Madrasah Non-Formal Milik Kalurahan Janten*', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Penyelenggaraan Posyandu*', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 12, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Penyuluhan dan Pelatihan Bidang Kesehatan*', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Menghadiri pertemuan Rutin PKK', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Menghadiri pertemuan Rutin Karangtaruna', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Menghadiri pertemuan Kader Posyandu', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Penyaluran Honor Rois', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Program Beasiswa', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Monev Beasiswa', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Keadaan Mendesak (Penyaluran BLT)*', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pelayanan sesuai bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pelayanan kepada warga masyarakat terkait dengan pernikahan. (contoh: Melayani konsultasi warga tentang tata cara/prosedur persyaratan-persyaratan pernikahan, izin melaksanakan Pengajian  lainnya)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 8, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pelayanan warga masyarakat terkait dengan bidang keagamaan, budaya, olahraga, karangtaruna, social, keluarga, pendidikan, pemberdayaan perempuan, perlindungan anak, dll. (contoh: Melayani konsultasi kelompok-kelompok budaya, olahraga, keagamaan, dll terkait tata cara/prosedur izin kegiatan, pengajuan proposal, dll)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Mencari salinan landasan hukum tentang Posyandu, PAUD dll)', 'dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai Kepemilikan Jaminan kesehatan masyarakat', 'Bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya (contoh: Menyampaikan laporan secara lisan tertulis kepada Lurah tentang sosial kemasyarakatan, keagaman, kesehatan dan kebudayaan misalnya pelaksanaan PMT, Tracing kesehatan , pemantuan jentik dll)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil (contoh: Memberikan saran dan pertimbangan mengenai kebijakan pelaksanaan merti kalurahan, hari jadi kalurahan, kegiatan peringatan HUT RI, dll)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Melaksanakan Tugas lain yang diberikan oleh Lurah', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Kegiatan Posyandu)', 'tim', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'SPP', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 30, 3);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti pertemuan di Padukuhan dan atau Musduk', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya sambutan wakil keluarga atau sebutan lain dalam upacara pernikahan, lamaran, lelayu, dll . (contoh: sambutan wakil keluarga upacara pemberangkatan jenazah)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini.', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya. ', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000003' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, version_number, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000003', COALESCE((SELECT MAX(version_number) + 1 FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000003'), 1), 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan urusan keuangan.', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Membuat Buku Kas Umum', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Membuat Buku Kas Tunai', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Membuat Buku bantu Bank', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Membuat Buku bantu Pajak', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Membuat Buku bantu Kegiatan', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Membuat Buku Penutupan Kas', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Berkoordinasi bersama carik dan pamong melakukan Penyusunan Dokumen Keuangan Kalurahan (misal: memberi masukan terkait laporan keuangan sehingga menjadi dasar penyusunan APB Kalurahan/APB Kalurahan Perubahan/LPJ APB Kalurahan, dll)*', 'Dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersalurnya Siltap tujangan Pamong dan BPK', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Melakukan Pemotongan Pajak, input biling, menyetorkan dan mencatatkan pada aplikasi siskeudes  Paling lambat 5 hari bulan berikutnya', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 15, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengajukan permohonan pencairan Alokasi Dana desa (ADD)', 'Bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Membuat rencana pencairan, melakukan transaksi dan membukukan pada aplikasi siskeudes', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 32, 3);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Menyusun laporan pertanggungjawaban realisasi pelaksanaan anggaran pendapatan dan belanja kalurahan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Membuat laporan realisasi bulanan', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Membuat laporan realisasi semester II', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Membuat Laporan realisasi akhir tahun', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Melakukan penatausahaan keuangan yang meliputi menerima menyimpan, menyetorkan/membayar, menatausahakan dan mempertanggungjawabkan penerimaan pendapatan Kalurahan dan pengeluaran dalam rangka pelaksanaan anggaran pendapatan dan belanja kalurahan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Menerima, Menyetorkan  dan melakukakan pencatatan pendapatan kalurahan pada aplikasi siskeudes', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Pencarian Permendesa tentang Prioritas Penggunaan Dana Desa dll  kemudian mererapkan  sekaligus mengarsipkannya dengan tertib)', 'arsip', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 6, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (contoh: Menyampaikan laporan terkait dengan hasil presentasi/desk rancangan APBKAL, perubahan, dll)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 6, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Melaksanakan Tugas lain yang diberikan oleh Lurah', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam Tim Penyusunan Rencana Kerja Pemerintah Kalurahan) ', 'tim', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Padukuhan dan atau pertemuan lainnya di tigka padukuhan (Musduk)', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini.', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000006' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, version_number, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000006', COALESCE((SELECT MAX(version_number) + 1 FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000006'), 1), 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan kegiatan pembangunan dan kemakmuran', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'Dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 12, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan ', 'Dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 25, 3);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Pemantauan terhadap Pemanfaatan  Lumbung pangan Kalurahan dan melaporkan kepada lurah baik lisan maupun tertulis', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Monitoring dan Evaluasi terhadap Bantuan dan atau pembanguan yang telah dilaksanakan (Misal Perbaikan Atap TKK PKK, Perkerasan Jalan, Bantuan alat-alat pembuatan pupuk dsb ) dan melaporkan kepada lurah baik lisan maupun tertulis', 'Kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya sosialisasi, motivasi dan peningkatan kapasitas masyarakat di bidang ekonomi dan lingkungan hidup. (contoh: penyampaian informasi di dalam forum pertemuan tentang program pembanguanan di desa)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pendataan dan pengelolaan profil kalurahan di Web/Aplikasi Prodeskel, sinkal dan IDM(Profil Desa/Kelurahan)', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'menginisiasi, mengkoordinasi dan atau menghadiri pertemuan lembaga (misal P3A Kelompok Tani, Gapoktan, KWT dll)', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyebarluasan informasi rencana tata ruang pada satuan ruang strategis (contoh: menyampaikan di forum pertemuan terkait dengan informasi Tanah Keprabon dan/atau bukan Keprabon di daerah kulon progo sesuai dengan ketentuan yang berlaku)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengkoordinasi, memantau, memastikan dan atau ikut serta dalam penyusunan Rencana Definitif Kebutuhan Kelompok (RDKK)', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pelaksanaan Kegiatan Anggaran', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Informasi Publik Desa baik melalui media online maupun offline (Misal Banner APKal, Realisasi APBkal dll)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Pembangunan/Rehabilitasi/Peningkatan Perkerasan Jalan Desa', 'Bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Pembangunan Jaringan Pengairan ', 'Bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanaya Pengisian Direktur Bumkal', 'Bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanaya Bimtek/Pelatihan  Pengelolaan Bumkal', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pelayanan Sesuai bidang Tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pelayanan kepada warga masyarakat terkait dengan bidang tugasnya. (contoh: Melayani konsultasi warga tentang tata cara/prosedur persyaratan-persyaratan pengajuan IMB, SKU dll)', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Mencari salinan Perbup Nomor 16 Tahun 2020 tentang Tata Cara Pelaksanaan Kegiatan Pengadaan Barang/Jasa di Kalurahan, kemudian mempelajari, menerapkan dan mengarsipkannya dengan tertib sehingga siap disajikan apabila sewaktu-waktu dibutuhkan)', 'produk', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Membuat, mengisi dan mengarsipkan Buku administrasi Pemangunan (Buku Rencana Pembangunan, Buku Kegiatan Pembangunan, Buku Inventaris dan Buku Kader Pembangunan )', 'Buku', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya Laporan Kepada lurah tentang kegiatan yang diikuti (Misal : Hasil rapat, kelompoktani, gapotan, musyawarah musim tanam kemudian mempublikasikan kepada masayarakat baik secara tertulis maupun melalui forum pertemuan', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Melaksanakan Tugas lain yang diberikan oleh Lurah', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam Tim Penyusun RKP Kalurahan) ', 'tim', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah. ', 'dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'spp', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000005' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, version_number, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000005', COALESCE((SELECT MAX(version_number) + 1 FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000005'), 1), 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan kegiatan pemerintahan dan keamanan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya evaluasi manajemen tata praja pemerintahan (evaluasi terhadap pelayanan dan kearsipan)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyusun rancangan produk regulasi. (contoh: Menyusun rancangan Peraturan Kaluran, Peraturan Lurah, Surat Keputusan, dll kemudian di sampaikan kepada carik untuk diverifikasi)', 'produk', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pengendalian dan evaluasi kegiatan pembinaan ketentraman dan ketertiban dan melaporkannya kepada lurah. (contoh: Ikut dalam kegiatan penyelesaian permasalahan sosial di masyarakat)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Kegiatan Pembinaan terhadap Linmas, Forum Jagawarga', '', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya kegiatan Upaya Perlindungan Masyarakat (Misal kegiatan yang dilakukakan linmas, Forum jaga warga. ikut dalam pengamanan terhadap kegiatan keramaian di desa', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Monitoring kegiatan siskamling', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya koordinasi Pencegahan dan atau penanggulangan bencana. (contoh: Hadir dan aktif berkoordinasi dengan pihak terkait saat terjadi bencana banjir, kebakaran, pohon tumbang)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 9, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Updating data kependudukan', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pengarsipan peta kalurahan yang ada dengan tertib.(Baik Hardcopy maupun Aplikasi/Digital)', 'Peta', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Kegiatan urusan Keistimewaan bidang pertanahan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya update pencatatan dan Inventaris terkait dengan Pemanfaatan dan Pengelolaan Tanah Kalurahan sebagai Dasar dalam Penyusunan Peraturan Kalurahan tentang Pengelolaan Kekayaan Kalurahan. (contoh: daftar tanah kalurahan beserta  pemanfaatannya)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pengadministrasian tanah kalurahan dan pemanfaatannya serta penyusunan Peraturan Kalurahan terkait dengan tanah kalurahan termasuk fasilitasi permohonan izin gubernur.', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pelaksanaan kegiatan anggaran', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terpenuhinya Kebutuhan Operasional Kantor BPK', 'Kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksannya kegiatan RT RW', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2); -- [INKONSISTENSI SPREADSHEET] Jumlah bulan = 19, Annual = 20
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya kegiatan Updating Aplikasi Prodeskel, IDM dan Sinkal', 'Kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya Perjanjian Kinerja Lurah, Laporan Kinarja dan Survei Kepuasan Masyarakat', 'Dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunya Laporan Penyelenggaraan Pemerintah Kalurahan (LPPK)', 'Dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pengembangan Sistem Informasi Kalurahan', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya Pelatihan/Sosialisasi Penanggulangan Bencana', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pelayanan sesuai bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pelayanan bidang Kependudukan, dan ijin keramaian dll)', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 16, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya fasilitasi Pelaksanaan Klarifikasi Pertanahan dan urusan pertanahan lainnya. (contoh: turun waris, hibah, konsolidasi tanah, dll)', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Pelayanan lain sesuai bidang tugasnya selain yang sudah tercantum dalam output kegiatan di atas.', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib.(contoh: Pencarian Pergub Nomor 34 Tahun 2017  kemudian mererapkan dalam pengelolaan dan pemanfaatan tanah kalurahan sekaligus mengarsip)', 'produk', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (contoh: Menyampaikan laporan baik secara tertulis maupun lisan kepada Lurah setelah melaksanakan penyelesaian permasalahan social yang terjadi di masyarakat)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pelaksanaan tugas lain yang diberikan oleh Lurah', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Kegiatan Sistem Informasi Kalurahan) ', 'tim', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 9, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'SPP', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Padukuhan dan atau pertemuan lainnya tingkat padukuhan (Musduk)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini dan melaporakan hasil pelaksanaannya kepada lurah.', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya. ', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'terlaksananya rapat koordinasi dan atau evaluasi PBB dan melaporkan hasilnya kepada lurah', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000004' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, version_number, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000004', COALESCE((SELECT MAX(version_number) + 1 FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000004'), 1), 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan urusan ketatausahaan, umum dan perencanaan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pencermatan dan pembuatan surat sesuai tata naskah yang berlaku baik manual maupun melalui aplikasi persyuratan (contoh: membuat surat undangan, surat pengantar pengiriman Peraturan Kalurahan kepada Panewu Pengasih)', 'surat/dok.', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya register surat masuk, baik secara langsung/offline maupun melalui SID/suratku/elektronik), menyampiakan kepada lurah dan atau lainnya serta menyampaikan disposisi surat ', 'surat/dok.', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya registrasi surat keluar baik secara langsung/offline maupun melalui SID/suratku/elektronik) dan mengkoordinasi pendistribusianya (contoh: Penulisan nomor pada buku agenda surat keluar kepada Dinas PMD Dalduk dan KB ', 'surat/dok.', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksana register ekspedisi (contoh: Penulisan di buku ekspedisi Surat Dinas kepada Kapanewon Pengasih)', 'register', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penulisan agenda kegiatan di papan jadwal agenda kegiatan dalam aplikasi online maupan media offline', 'agenda', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyiapan rapat (contoh: berkoordinasi dengan staf dan pamong lain yang sekiranya bisa membantu dalam menyiapkan tempat, sarana prasarana, konsumsi, MC, dirijen lagu pada kegiatan musyawarah kalurahan)', 'rapat', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 15, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pencatatan dan inventarisasi aset kalurahan (contoh: menempel stiker nomor di kursi/meja/computer, dll dan dicatatkan di dalam buku aset)', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya fasilitasi koordinasi pelayanan umum (contoh: menyampaikan kepada staf dan/atau pamong lain terkait update aturan pelayanan persuratan, update SOP pelayanan, dll)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya kegiatan tata usaha, umum dan perencanaan terkait dengan keistimewaan (contoh: Pembuatan proposal usulan terkait Dana Keisimewaaan, pelaksanaan Musyawarah Kalurahan usulan kegiatan yang di danai Dana Keistimewaan)', '', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Berkoordinasi dengan Pamong lainnya dan memastikan dokumen administrasi Pamong Kalurahan dilaksanakan sebagaimana peraturan yang berlaku (misal berkoordinasi dengan Ulu-ulu terkait Buku administrasi  Pembangunan, berkoordinasi dengan carik terkait buku agenda perkal berkoordinasi dengan Jagabay terkait administrasi pertanahan dll). ', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyediaan prasarana kantor kalurahan (contoh: Pemenuhan kebutuhan lampu, kipas angin, cat tembok, dll)', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyediaan prasarana pamong kalurahan (contoh: ATK, alat kebersihan dan alat listrikl)', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya input data pamong di aplikasi dan manual (update) (contoh: Mencatat dan melakukan update berkala di buku pamong kalurahan/aparatur pamong kalurahan dan input/update berkala di aplikasi SID maupun SIAPDES maupun aplikasi lainnya yang relevan)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pembuatan bagan susunan organisasi tata kerja pemerintah kalurahan (update) dan atau Lembaga lainnya', 'bagan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pemenuhan kebutuhan kerumahtanggaan pemerintah kalurahan (contoh: koordinasi terkait teknis dalam pemenuhan kebutuhan gula, gas, teh, sabun, dll)', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pelaporan aset semester I dan semester II', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Melaksanaan kegiatan anggaran', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Penyaluran siltap dan Jaminan Sosial bagi Lurah dan Pamong*', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Penyediaan Operasional Pemerintah Kalurahan*', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Penyediaan Operasional Pemerintah Kalurahan yang bersumber dari Dana Desa*', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Pembangunan/Rehabilitasi/Peningkatan Gedung/Prasarana Kantor Kalurahan*', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Penyelenggaraan Musyawarah Perencanaan Kalurahan/Pembahasan APBKal Kalurahan*', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Penyelenggaraan Musyawarah Kalurahan Lainnya (Musduk, rembug warga dan lain-lain yang bersifat non-reguler)*', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Penyusunan Dokumen Perencaan Kalurahan (RPJM Kal./RKP Kal., dll)*', 'Dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Pengelolaan/Administrasi/Inventarisasi/Penilaian Aset Kalurahan*', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Melaksanakan perekapan presensi pamong setiap bulan dan melaporkannya', 'bulan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 4, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'perjanjian kerja sama dengan penyedia atas pengadaan barang/jasa ( perjanjiann konsultan pembanguan, berkoordinasi dengan ulu-ulu terkait pengadaan meterial pembangunan kantor)', 'Dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Pencarian Peraturan Bupati Kulon Progo Nomor 67 Tahun 2019 tentang Pedoman Tata Naskah Dinas Pemerintah Kalurahan kemudian diterapkan dalam pembuatan surat dinas sekaligus mengarsipkannya dengan tertib)', 'produk', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (laporan pelaksanaan pembangunan kantor)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Melaksanaan tugas lain yang diberikan oleh Lurah', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam Tim Penyusunan RKP Kalurahan) ', 'tim', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 3, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip/dok.', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'surat/dok.', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'SPP', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Padukuhan (Musduk)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini.', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya. ', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000008' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, version_number, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000008', COALESCE((SELECT MAX(version_number) + 1 FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000008'), 1), 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Membantu pelaksanaan tugas Lurah di wilayah Padukuhan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Pembinaan Ketentraman dan Ketertiban, mobilitas penduduk, penataan administratif (misal Koordinasi, ikut serta, atau monitoring kegiatan siskamling. Mencatat dan membukukan mobilisasi penduduk)', 'Kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Perencanaan, pelaksanaan dan evaluasi pembangunan di wilayahnya ( Misal Koordinasi dengan RT, RW, KKLKMK atau lainnya..)', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya dan/atau menghadiri kegiatan kerja bakti, dan/atau kegiatan lain terkait dengan upaya menjaga kebersihan dan kesehatan lingkungan di tingkat padukuhan maupun RT.', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya dan/atau menghadiri kegiatan persiapan pelaksanaan hajatan di masyarakat. (contoh: pernikahan, lamaran, pengajian, lelayu/pemberangkatan jenazah dan kegiatan masyarakat lainnya)', 'kegiatan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pemantauan dan melaporkan kepada lurah terkait dengan penggunaan dan pemanfaatan tanah kalurahan di wilayah masing-masing (contoh: Pemantauan terhadap tanah Kalurahan yang diapaki Fasum/Fasus dan membukukan dalam dalam buku khusus sehingga dapt dibukukan jika terdapat perubahan penggunan', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib.(misal Mengarsip Perkal, Perbup dan atau mambuat database kependudukan diwilayahnya)', 'produk', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Membantu pelayanan umum di kantor kalurahan;', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya terkait dengan pelayanan di kalurahan (contoh: surat keterangan usaha, surat keterangan domisili, surat keterangan tidak mampu, pengantar pernikahan, dan pelayanan lainnya yang dilayani oleh pemerintah kalurahan)', 'surat', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (contoh: Menyampaikan laporan baik secara tertulis  kepada Lurah setelah melaksanakan penyelesaian permasalahan social yang terjadi di masyarakat, atau kegiatan lainnya baik yaang dianggarak APBKal maupun tidak dianggarkan)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Melaksanakan Tugas lain yang diberikan oleh Lurah', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. (termasuk Undangan Kalurahan atau kapanewon)', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Kegiatan Posyandu, dll) ', 'tim', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pengantaran dan/atau pengambilan surat/dokumen terkait dengan tugas kedinasan.  ', 'dokumen', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melakukan evaluasi terhadap kegiatan yang dilakukakan di wilayahnua dan Melaporkan kepada lurah, termasuk permasalahan, hambatan, serta solusinya)', 'laporan', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengadakan Musyawarah Padukuhan (Musduk) dan atau pertemuan lainnya', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 2, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya sambutan atau sebutan lainnya di acara hajatan di masyarakat (contoh: pernikahan, lamaran, pengajian, lelayu/pemberangkatan jenazah dan kegiatan masyarakat lainnya)', 'acara', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksanannya pengkondisian permasalahan dan/atau bencana yang terjadi di wilayahnya selanjutnya melaporkan kepada lurah (contoh: banjir, tanah longsor, masalah sosial kemasyarakatan, dll)', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 5, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pendampingan pengantaran ODGJ, Donor darah atau Pengobatan', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 1, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini dan melaporakan hasil pelaksanaannya kepada lurah.', 'kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 20, 2);
        INSERT INTO public.performance_items (group_id, name, unit, order_number) VALUES (v_grp_id, 'Tercapainya Pembayaran PBB-P2 (non-Tanah Desa) di Padukuhan dalam 
(5 SPPT=1 poin).', 'poin', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_items WHERE group_id = v_grp_id), 1)) RETURNING id INTO v_item_id;
        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, 10, 1); -- [INKONSISTENSI SPREADSHEET] Jumlah bulan = 9, Annual = 10
    END IF;

    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000009' AND effective_from = '2027-01-01'::DATE;
    IF v_mat_id IS NULL THEN
        INSERT INTO public.matrix_versions (position_id, version_number, status, effective_from) VALUES ('b0000000-0000-0000-0000-000000000009', COALESCE((SELECT MAX(version_number) + 1 FROM public.matrix_versions WHERE position_id = 'b0000000-0000-0000-0000-000000000009'), 1), 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Kedisiplinan Pelaksanaan Tugas', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pelayanan Prima (Keterangan: Pelayanan Selesai dalam waktu maksimal 10 menit)', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
        INSERT INTO public.performance_groups (matrix_version_id, name, order_number) VALUES (v_mat_id, 'Pelaksanaan Tugas Pembantuan kepada Lurah dan Pamong', COALESCE((SELECT MAX(order_number) + 1 FROM public.performance_groups WHERE matrix_version_id = v_mat_id), 1)) RETURNING id INTO v_grp_id;
    END IF;

END $$;

-- 7. FINAL SEED VALIDATION
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    -- 1. Exact 9 positions
    SELECT COUNT(*) INTO v_count FROM public.positions;
    IF v_count <> 9 THEN
        RAISE EXCEPTION 'Seed validation failed: expected exactly 9 positions, found %.', v_count;
    END IF;

    -- Active assignments count
    SELECT COUNT(*) INTO v_count
    FROM public.employees e
    JOIN public.employee_position_assignments a ON a.employee_id = e.id
    WHERE a.status = 'active'
      AND a.effective_from = '2027-01-01'::DATE;
    IF v_count <> 10 THEN
        RAISE EXCEPTION 'Seed validation failed: expected 10 active employee assignments for 2027-01-01, found %.', v_count;
    END IF;

    -- Published matrices count
    SELECT COUNT(*) INTO v_count
    FROM public.matrix_versions
    WHERE effective_from = '2027-01-01'::DATE
      AND status = 'Published'::public.matrix_version_status;
    IF v_count <> 8 THEN
        RAISE EXCEPTION 'Seed validation failed: expected 8 published matrix versions for 2027-01-01, found %.', v_count;
    END IF;

    -- Empty group checks
    IF EXISTS (SELECT 1 FROM public.performance_groups WHERE btrim(name) = '') THEN
        RAISE EXCEPTION 'Seed validation failed: empty performance group remains.';
    END IF;
    IF EXISTS (SELECT 1 FROM public.performance_groups WHERE btrim(name) = 'b') THEN
        RAISE EXCEPTION 'Seed validation failed: artifact performance group ''b'' remains.';
    END IF;

    -- 2. Bamuskal Check
    SELECT COUNT(*) INTO v_count FROM public.positions WHERE name ILIKE '%Bamuskal%';
    IF v_count > 0 THEN
        RAISE EXCEPTION 'Validation failed: Bamuskal position found.';
    END IF;
    SELECT COUNT(*) INTO v_count FROM public.employee_position_assignments a JOIN public.positions p ON a.position_id = p.id WHERE p.name ILIKE '%Bamuskal%';
    IF v_count > 0 THEN
        RAISE EXCEPTION 'Validation failed: Bamuskal assignment found.';
    END IF;

    -- 3. Role-Position Validation
    IF EXISTS (
        SELECT 1 FROM public.employees e
        JOIN public.profiles pr ON pr.id = e.profile_id
        JOIN public.employee_position_assignments a ON a.employee_id = e.id
        JOIN public.positions p ON p.id = a.position_id
        WHERE a.status = 'active'
          AND (
              (p.name = 'Carik' AND pr.role <> 'admin'::public.app_profile_role)
              OR (p.name <> 'Carik' AND pr.role = 'admin'::public.app_profile_role)
              OR (p.name = 'Lurah' AND pr.role <> 'user'::public.app_profile_role)
          )
    ) THEN
        RAISE EXCEPTION 'Role validation failed: mismatched admin/user roles.';
    END IF;

    -- 4. Item tanpa target
    IF EXISTS (
        SELECT 1 FROM public.performance_items pi
        LEFT JOIN public.performance_targets pt ON pt.item_id = pi.id
        WHERE pt.id IS NULL
    ) THEN
        RAISE EXCEPTION 'Validation failed: found item without target.';
    END IF;

    -- 5. Active assignment overlap / duplicate
    IF EXISTS (
        SELECT employee_id
        FROM public.employee_position_assignments
        WHERE status = 'active' AND effective_from = '2027-01-01'::DATE
        GROUP BY employee_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Validation failed: duplicate active assignments found for an employee.';
    END IF;

    -- 6. Dukuh matrix count
    SELECT COUNT(*) INTO v_count
    FROM public.matrix_versions mv
    JOIN public.positions p ON mv.position_id = p.id
    WHERE p.name = 'Dukuh' AND mv.effective_from = '2027-01-01'::DATE AND mv.status = 'Published'::public.matrix_version_status;
    IF v_count <> 1 THEN
        RAISE EXCEPTION 'Validation failed: Expected 1 Dukuh matrix, found %', v_count;
    END IF;

    -- 7. Staf active employee check
    SELECT COUNT(*) INTO v_count
    FROM public.employees e
    JOIN public.employee_position_assignments a ON a.employee_id = e.id
    JOIN public.positions p ON p.id = a.position_id
    WHERE p.name = 'Staf' AND a.status = 'active';
    IF v_count <> 0 THEN
        RAISE EXCEPTION 'Validation failed: found active Staf employee.';
    END IF;

    -- 8. Duplicate Published matrix check
    IF EXISTS (
        SELECT position_id
        FROM public.matrix_versions
        WHERE status = 'Published'::public.matrix_version_status AND effective_from = '2027-01-01'::DATE
        GROUP BY position_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Validation failed: duplicate published matrices for the same position.';
    END IF;

END $$;

COMMIT;