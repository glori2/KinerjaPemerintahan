-- Migration: Tukin Pagus Table

CREATE TABLE IF NOT EXISTS tukin_pagus (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    position_id UUID NOT NULL REFERENCES positions(id) ON DELETE CASCADE,
    amount NUMERIC(15, 2) NOT NULL,
    effective_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TRIGGER update_tukin_pagus_updated_at BEFORE UPDATE ON tukin_pagus FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
ALTER TABLE tukin_pagus ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Pagus: Anyone can view" ON tukin_pagus FOR SELECT USING (true);
CREATE POLICY "Pagus: Admin can manage" ON tukin_pagus FOR ALL USING (is_admin());


-- SEED DATA KALURAHAN KALIDENGEN

INSERT INTO village_settings (id, setting_key, setting_value) VALUES 
(uuid_generate_v4(), 'kalurahan_name', '"Kalurahan Kalidengen"'),
(uuid_generate_v4(), 'kapanewon_name', '"Kapanewon Temon"'),
(uuid_generate_v4(), 'kabupaten_name', '"Kabupaten Kulon Progo"'),
(uuid_generate_v4(), 'provinsi_name', '"DI Yogyakarta"');

INSERT INTO positions (id, name, min_ckb_target) VALUES ('11111111-1111-1111-1111-111111111111', 'Lurah', 0);
INSERT INTO tukin_pagus (id, position_id, amount, effective_date) VALUES (uuid_generate_v4(), '11111111-1111-1111-1111-111111111111', 1561000, '2026-01-01');
INSERT INTO positions (id, name, min_ckb_target) VALUES ('22222222-2222-2222-2222-222222222222', 'Carik', 40);
INSERT INTO tukin_pagus (id, position_id, amount, effective_date) VALUES (uuid_generate_v4(), '22222222-2222-2222-2222-222222222222', 1384950, '2026-01-01');
INSERT INTO positions (id, name, min_ckb_target) VALUES ('33333333-3333-3333-3333-333333333333', 'Danarta', 39);
INSERT INTO tukin_pagus (id, position_id, amount, effective_date) VALUES (uuid_generate_v4(), '33333333-3333-3333-3333-333333333333', 1223600, '2026-01-01');
INSERT INTO positions (id, name, min_ckb_target) VALUES ('44444444-4444-4444-4444-444444444444', 'Panata Laksana Sarta Pangripta', 39);
INSERT INTO tukin_pagus (id, position_id, amount, effective_date) VALUES (uuid_generate_v4(), '44444444-4444-4444-4444-444444444444', 1223600, '2026-01-01');
INSERT INTO positions (id, name, min_ckb_target) VALUES ('55555555-5555-5555-5555-555555555555', 'Jagabaya', 39);
INSERT INTO tukin_pagus (id, position_id, amount, effective_date) VALUES (uuid_generate_v4(), '55555555-5555-5555-5555-555555555555', 1223600, '2026-01-01');
INSERT INTO positions (id, name, min_ckb_target) VALUES ('66666666-6666-6666-6666-666666666666', 'Ulu-Ulu', 39);
INSERT INTO tukin_pagus (id, position_id, amount, effective_date) VALUES (uuid_generate_v4(), '66666666-6666-6666-6666-666666666666', 1223600, '2026-01-01');
INSERT INTO positions (id, name, min_ckb_target) VALUES ('77777777-7777-7777-7777-777777777777', 'Kamituwa', 39);
INSERT INTO tukin_pagus (id, position_id, amount, effective_date) VALUES (uuid_generate_v4(), '77777777-7777-7777-7777-777777777777', 1223600, '2026-01-01');
INSERT INTO positions (id, name, min_ckb_target) VALUES ('88888888-8888-8888-8888-888888888888', 'Dukuh Kalidengen I', 38);
INSERT INTO tukin_pagus (id, position_id, amount, effective_date) VALUES (uuid_generate_v4(), '88888888-8888-8888-8888-888888888888', 1140300, '2026-01-01');
INSERT INTO positions (id, name, min_ckb_target) VALUES ('99999999-9999-9999-9999-999999999999', 'Dukuh Kalidengen II', 38);
INSERT INTO tukin_pagus (id, position_id, amount, effective_date) VALUES (uuid_generate_v4(), '99999999-9999-9999-9999-999999999999', 1140300, '2026-01-01');
INSERT INTO positions (id, name, min_ckb_target) VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Dukuh Sidatan', 38);
INSERT INTO tukin_pagus (id, position_id, amount, effective_date) VALUES (uuid_generate_v4(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1140300, '2026-01-01');
INSERT INTO positions (id, name, min_ckb_target) VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Staf', 0);

INSERT INTO profiles (id, role, full_name) VALUES ('00000000-0000-0000-0000-000000000001', 'user', 'Sunardi');
INSERT INTO employees (id, profile_id, position_id, status) VALUES (uuid_generate_v4(), '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'active');
INSERT INTO profiles (id, role, full_name) VALUES ('00000000-0000-0000-0000-000000000002', 'admin', 'Muh. Masruri Mustofa');
INSERT INTO employees (id, profile_id, position_id, status) VALUES (uuid_generate_v4(), '00000000-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'active');
INSERT INTO profiles (id, role, full_name) VALUES ('00000000-0000-0000-0000-000000000003', 'user', 'Viki Wulandari');
INSERT INTO employees (id, profile_id, position_id, status) VALUES (uuid_generate_v4(), '00000000-0000-0000-0000-000000000003', '33333333-3333-3333-3333-333333333333', 'active');
INSERT INTO profiles (id, role, full_name) VALUES ('00000000-0000-0000-0000-000000000004', 'user', 'Agus Endarto');
INSERT INTO employees (id, profile_id, position_id, status) VALUES (uuid_generate_v4(), '00000000-0000-0000-0000-000000000004', '44444444-4444-4444-4444-444444444444', 'active');
INSERT INTO profiles (id, role, full_name) VALUES ('00000000-0000-0000-0000-000000000005', 'user', 'Subarno');
INSERT INTO employees (id, profile_id, position_id, status) VALUES (uuid_generate_v4(), '00000000-0000-0000-0000-000000000005', '55555555-5555-5555-5555-555555555555', 'active');
INSERT INTO profiles (id, role, full_name) VALUES ('00000000-0000-0000-0000-000000000006', 'user', 'Saridi');
INSERT INTO employees (id, profile_id, position_id, status) VALUES (uuid_generate_v4(), '00000000-0000-0000-0000-000000000006', '66666666-6666-6666-6666-666666666666', 'active');
INSERT INTO profiles (id, role, full_name) VALUES ('00000000-0000-0000-0000-000000000007', 'user', 'Sumardi');
INSERT INTO employees (id, profile_id, position_id, status) VALUES (uuid_generate_v4(), '00000000-0000-0000-0000-000000000007', '77777777-7777-7777-7777-777777777777', 'active');
INSERT INTO profiles (id, role, full_name) VALUES ('00000000-0000-0000-0000-000000000008', 'user', 'Widi Hartono');
INSERT INTO employees (id, profile_id, position_id, status) VALUES (uuid_generate_v4(), '00000000-0000-0000-0000-000000000008', '88888888-8888-8888-8888-888888888888', 'active');
INSERT INTO profiles (id, role, full_name) VALUES ('00000000-0000-0000-0000-000000000009', 'user', 'Rendi Ardiyanto');
INSERT INTO employees (id, profile_id, position_id, status) VALUES (uuid_generate_v4(), '00000000-0000-0000-0000-000000000009', '99999999-9999-9999-9999-999999999999', 'active');
INSERT INTO profiles (id, role, full_name) VALUES ('00000000-0000-0000-0000-000000000010', 'user', 'Edi Supriyanto');
INSERT INTO employees (id, profile_id, position_id, status) VALUES (uuid_generate_v4(), '00000000-0000-0000-0000-000000000010', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'active');

INSERT INTO matrix_versions (id, position_id, version_number, status, effective_date) VALUES ('m2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 1, 'published', '2026-01-01');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_2ww792cp9', 'm2222222-2222-2222-2222-222222222222', 'Pengoordinasian administrasi Pemerintahan
Kalurahan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2ww792cp9', 'Terlaksananya pencermatan tata naskah surat sebelum dibubuhkan paraf dan/atau tanda tangan (contoh: pencermatan Surat Keputusan sebelum diparaf/tanda tangan).', 'Surat/dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 16, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2ww792cp9', 'Terlaksananya koordinasi dalam rangka inventarisasi arsip, surat, dan lain-lain. (contoh: koordinasi penyimpanan arsip kepada pamong kalurahan)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2ww792cp9', 'Terlaksananya koordinasi dalam penataan administrasi pamong kalurahan (contoh: koordinasi kepada pamong terkait dengan pengisian laporan kinerja, penyusunan dokumen-dokumen kelengkapan BLT DD, dll)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 8, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2ww792cp9', 'Terlaksanannya koordinasi dalam rangka penyedian sarana dan prasarana kalurahan (contoh: koordinasi kepada kaur panata laksana sarta pangripta untuk membeli sapu, merencanakan di kegiatan APBDES untuk dianggarakan belanja seragam)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2ww792cp9', 'Terlaksananya koordinasi pelaksanaan Musyawarah, Pertemuan, Rapat, dll. (contoh: Koordinasi Pelaksaan Muskal, Musrenbang, Rakor, dll)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 24, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2ww792cp9', 'Terlaksananya koordinasi pelaksanaan inventarisasi aset kalurahan (contoh: koordinasi kepada Palapa untuk melaksanakan kegiatan inventarisasi aset Kalurahan Janten)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2ww792cp9', 'Terlaksana koordinasi fasilitasi pelayanan umum (contoh: Koordinasi kepada Kaur Palapa untuk melaksanakan pelayanan menggunakan SID)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2ww792cp9', 'Terlaksananya pembubuhan paraf dalam SPJ dan/atau SPP kegiatan dan memberikan koreksi apabila ditemukan ketidaksesuaian. (contoh: paraf pada SPP siltap Pamong)', 'dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 32, 3 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2ww792cp9', 'Terlaksananya koordinasi penganggaran dari berbagai sumber dan kegiatan kasi dan/atau kaur. (contoh: menghitung prosentase prioritas wajib yang harus dipenuhi pada tiap penganggaran dan kegiatan-kegiatan lainnya)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 8, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2ww792cp9', 'Terlaksanannya koordinasi pelaksanaan pembuatan proposal usulan Dana Keistimewaan dan Musyawarah/pertemuan lain terkait dengan Usulan Dana Keistimewaan. (contoh: koordinasi pembuatan proposa papan nama)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_qrsn91qoo', 'm2222222-2222-2222-2222-222222222222', 'Koordinasi, pengendalian dan evaluasi terhadap perencanaan dan pelaksanaan kegiatan Pemerintah Kalurahan.');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_qrsn91qoo', 'Terlaksananya koordinasi pengendalian dan evaluasi kegiatan Kasi dan/atau kaur. (contoh: koordinasi kegiatan siltap segera dibuat kelengkapan supaya dapat segera cair, kegiatan musyawarah kalurahan supaya sesuai dengan agenda waktu dalam perundang-undangan yang berlaku)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 16, 2 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_b6xby3ro6', 'm2222222-2222-2222-2222-222222222222', 'Pelaksanaan pengelolaan keuangan.');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_b6xby3ro6', 'Terlaksananya koordinasi penyusunan dan pelaksanaan kebijakan anggaran pendapatan dan belanja kalurahan (Koordinasi pelaksanaan kegiatan sinkronisasi dengan sumber dana)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_b6xby3ro6', 'Terlaksananya koordinasi penyusunan Peraturan Lurah Penjabaran APB Kalurahan dan/atau perubahan Penjabaran APB Kalurahan, dalam rangka singkronisasi antara kebutuhan dan anggaran. (contoh: koordinasi terkait dengan perubahan kegiatan dan sumber dana perubahan tersebut berasal dari kegiatan apa)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 3, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_b6xby3ro6', 'Terlaksananya koordinasi penyusunan Pertanggungjawaban pelaksanaan anggaran pendapatan dan belanja kalurahan. (contoh: koordinasi kegiatan penyusunan laporan laporan akhir tahun, LPPD, dan LKPD)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_b6xby3ro6', 'Terlaksananya Tugas Pamong Kalurahan Lain yang menjalankan tugas Pelaksana Pengelolaan Keuangan Kalurahan (PPKK) (contoh: koordinasi agenda kegiatan masing-masing kasi dan/atau kaur sesuai dengan RAB)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_b6xby3ro6', 'Terlaksananya verifikasi terhadap Dokumen Pelaksanaan Anggaran (DPA), Dokumen Pelaksanaan Perubahan Anggaran (DPPA), Dokumen Pelaksanaan Anggaran Lanjutan (DPAL), Rencana Anggaran Kas Kalurahan (RAK Kalurahan), Surat Perintah Pembayaran (SPP) dan bukti penerimaan dan pengeluaran anggaran pendapatan dan belanja kalurahan.', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 24, 2 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_s8wnvxi0l', 'm2222222-2222-2222-2222-222222222222', 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_s8wnvxi0l', 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 8, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_ri2g2b8b8', 'm2222222-2222-2222-2222-222222222222', 'Pelaksanaan tugas lain yang diberikan oleh Lurah');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ri2g2b8b8', 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 8, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ri2g2b8b8', 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Penyusun RKP Kalurahan) ', 'tim') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ri2g2b8b8', 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ri2g2b8b8', 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ri2g2b8b8', 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 8, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ri2g2b8b8', 'Mengikuti Musyawarah Padukuhan (Musduk)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 0, 0 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ri2g2b8b8', 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 0, 0 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ri2g2b8b8', 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 0, 0 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ri2g2b8b8', 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini dan melaporakan hasil pelaksanaannya kepada lurah.', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ri2g2b8b8', 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_dra0n8p92', 'm2222222-2222-2222-2222-222222222222', '');

INSERT INTO matrix_versions (id, position_id, version_number, status, effective_date) VALUES ('m7777777-7777-7777-7777-777777777777', '77777777-7777-7777-7777-777777777777', 1, 'published', '2026-01-01');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_mii8jivp6', 'm7777777-7777-7777-7777-777777777777', 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan kegiatan sosial kemasyarakatan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mii8jivp6', 'Terlaksananya penyuluhan dan motivasi di dalam forum pertemuan terhadap pelaksanaan hak dan kewajiban masyarakat. (contoh: penyampaian informasi tentang gaya hidup sehat, pelayanan di kalurahan, pajak, gotong royong dll)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mii8jivp6', 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 8, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mii8jivp6', 'Kehadiran di kegiatan latihan, pementasan atau kegiatan latihan serta memberikan motivasi maupun informasi berkaitan dengan kegiatan kebudayaan kepada kelompok tersebut. (contoh: menghadiri kegiatan latihan Sholawat, Ketoprak, hadroh, dll kemudian memberikan informasi mengenai informasi/regulasi terbaru tentang prosedur pengajuan proposal dalam rangka pengembangan kegiatan tersebut', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 8, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_qybmg3n44', 'm7777777-7777-7777-7777-777777777777', 'Penyuluhan dan motivasi di bidang keagamaan, ketenagakerjaan, pemberdayaan perempuan, perlindungan anak, keluarga berencana, pendidikan, kesehatan, pemuda, olahraga, karang taruna dan penanggulangan kemiskinan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_qybmg3n44', 'Terlaksananya penyampaian Informasi ke Masyarakat dalam sebuah forum pertemuan terkait dengan bidang keagamaan, ketenagakerjaan, pemberdayaan perempuan, perlindungan anak, keluarga berencana, Pendidikan, kesehatan, pemuda, olahraga, karangtaruna dan penanggulangan kemiskinan. (contoh: Menghadiri pertemuan Kegiatan Posyandu, Kader, IP3M/PAUD, dll., kemudian menyampaikan informasi terkait tata cara/prosedur pengajuan BPJS PBI', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 8, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_k1csjf7ul', 'm7777777-7777-7777-7777-777777777777', 'Kegiatan urusan keistimewaan bidang kebudayaan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_k1csjf7ul', 'Terlaksananya pendampingan terkait pelaksanaan kegiatan kebudayaan yang ada di kalurahan (contoh: Menghadiri latihan kegiatan Merti Padukuhan, Wiwitan, Puputan, Tingkepan, dll., sehingga mengetahui terkait dengan eksistensi kegiatan tersebut yang dapat digunakan sebagai dasar perencanaan kegiatan di APBKAL maupun kegiatan dari dinas terkait)', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_y44jc7njv', 'm7777777-7777-7777-7777-777777777777', 'Pelaksanaan Kegiatan Anggaran');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_y44jc7njv', 'Terlaksananya Penyelenggaraan PAUD/TK/TPA/TKA/TPQ/Madrasah Non-Formal Milik Kalurahan Janten*', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_y44jc7njv', 'Terlaksananya Penyelenggaraan Posyandu*', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 12, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_y44jc7njv', 'Terlaksananya Penyuluhan dan Pelatihan Bidang Kesehatan*', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_y44jc7njv', 'Menghadiri pertemuan Rutin PKK', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_y44jc7njv', 'Menghadiri pertemuan Rutin Karangtaruna', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_y44jc7njv', 'Menghadiri pertemuan Kader Posyandu', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_y44jc7njv', 'Terlaksananya Penyaluran Honor Rois', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_y44jc7njv', 'Terlaksananya Program Beasiswa', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_y44jc7njv', 'Monev Beasiswa', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_y44jc7njv', 'Terlaksananya Keadaan Mendesak (Penyaluran BLT)*', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_tnp781jkq', 'm7777777-7777-7777-7777-777777777777', 'Pelayanan sesuai bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_tnp781jkq', 'Terlaksananya pelayanan kepada warga masyarakat terkait dengan pernikahan. (contoh: Melayani konsultasi warga tentang tata cara/prosedur persyaratan-persyaratan pernikahan, izin melaksanakan Pengajian  lainnya)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 8, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_tnp781jkq', 'Terlaksananya pelayanan warga masyarakat terkait dengan bidang keagamaan, budaya, olahraga, karangtaruna, social, keluarga, pendidikan, pemberdayaan perempuan, perlindungan anak, dll. (contoh: Melayani konsultasi kelompok-kelompok budaya, olahraga, keagamaan, dll terkait tata cara/prosedur izin kegiatan, pengajuan proposal, dll)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_ienryfskk', 'm7777777-7777-7777-7777-777777777777', 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ienryfskk', 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Mencari salinan landasan hukum tentang Posyandu, PAUD dll)', 'dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ienryfskk', 'Tersusunnya dan terarsipkannya himpunan informasi mengenai Kepemilikan Jaminan kesehatan masyarakat', 'Bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_upl7z9n37', 'm7777777-7777-7777-7777-777777777777', 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_upl7z9n37', 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya (contoh: Menyampaikan laporan secara lisan tertulis kepada Lurah tentang sosial kemasyarakatan, keagaman, kesehatan dan kebudayaan misalnya pelaksanaan PMT, Tracing kesehatan , pemantuan jentik dll)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_wofjk88rd', 'm7777777-7777-7777-7777-777777777777', 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_wofjk88rd', 'Terlaksananya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil (contoh: Memberikan saran dan pertimbangan mengenai kebijakan pelaksanaan merti kalurahan, hari jadi kalurahan, kegiatan peringatan HUT RI, dll)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_luxp7w5yp', 'm7777777-7777-7777-7777-777777777777', 'Melaksanakan Tugas lain yang diberikan oleh Lurah');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Kegiatan Posyandu)', 'tim') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'SPP') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 30, 3 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Mengikuti pertemuan di Padukuhan dan atau Musduk', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Terlaksananya sambutan wakil keluarga atau sebutan lain dalam upacara pernikahan, lamaran, lelayu, dll . (contoh: sambutan wakil keluarga upacara pemberangkatan jenazah)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini.', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_luxp7w5yp', 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya. ', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_yzs2kcauf', 'm7777777-7777-7777-7777-777777777777', '');

INSERT INTO matrix_versions (id, position_id, version_number, status, effective_date) VALUES ('m3333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333', 1, 'published', '2026-01-01');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_pyb5h7y4i', 'm3333333-3333-3333-3333-333333333333', 'b');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_ls9zyznjq', 'm3333333-3333-3333-3333-333333333333', 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan urusan keuangan.');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Membuat Buku Kas Umum', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Membuat Buku Kas Tunai', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Membuat Buku bantu Bank', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Membuat Buku bantu Pajak', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Membuat Buku bantu Kegiatan', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Membuat Buku Penutupan Kas', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Berkoordinasi bersama carik dan pamong melakukan Penyusunan Dokumen Keuangan Kalurahan (misal: memberi masukan terkait laporan keuangan sehingga menjadi dasar penyusunan APB Kalurahan/APB Kalurahan Perubahan/LPJ APB Kalurahan, dll)*', 'Dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Tersalurnya Siltap tujangan Pamong dan BPK', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Melakukan Pemotongan Pajak, input biling, menyetorkan dan mencatatkan pada aplikasi siskeudes  Paling lambat 5 hari bulan berikutnya', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 15, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Mengajukan permohonan pencairan Alokasi Dana desa (ADD)', 'Bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ls9zyznjq', 'Membuat rencana pencairan, melakukan transaksi dan membukukan pada aplikasi siskeudes', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 32, 3 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_p828njcb9', 'm3333333-3333-3333-3333-333333333333', 'Menyusun laporan pertanggungjawaban realisasi pelaksanaan anggaran pendapatan dan belanja kalurahan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_p828njcb9', 'Membuat laporan realisasi bulanan', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_p828njcb9', 'Membuat laporan realisasi semester II', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_p828njcb9', 'Membuat Laporan realisasi akhir tahun', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_hewrmxbai', 'm3333333-3333-3333-3333-333333333333', 'Melakukan penatausahaan keuangan yang meliputi menerima menyimpan, menyetorkan/membayar, menatausahakan dan mempertanggungjawabkan penerimaan pendapatan Kalurahan dan pengeluaran dalam rangka pelaksanaan anggaran pendapatan dan belanja kalurahan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hewrmxbai', 'Menerima, Menyetorkan  dan melakukakan pencatatan pendapatan kalurahan pada aplikasi siskeudes', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_fi526hhks', 'm3333333-3333-3333-3333-333333333333', 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_fi526hhks', 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Pencarian Permendesa tentang Prioritas Penggunaan Dana Desa dll  kemudian mererapkan  sekaligus mengarsipkannya dengan tertib)', 'arsip') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 6, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_o27gwqeaz', 'm3333333-3333-3333-3333-333333333333', 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_o27gwqeaz', 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (contoh: Menyampaikan laporan terkait dengan hasil presentasi/desk rancangan APBKAL, perubahan, dll)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_c8m1daw6c', 'm3333333-3333-3333-3333-333333333333', 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_c8m1daw6c', 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 6, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_rysp3ygp5', 'm3333333-3333-3333-3333-333333333333', 'Melaksanakan Tugas lain yang diberikan oleh Lurah');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_rysp3ygp5', 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_rysp3ygp5', 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam Tim Penyusunan Rencana Kerja Pemerintah Kalurahan) ', 'tim') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_rysp3ygp5', 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_rysp3ygp5', 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_rysp3ygp5', 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_rysp3ygp5', 'Mengikuti Musyawarah Padukuhan dan atau pertemuan lainnya di tigka padukuhan (Musduk)', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_rysp3ygp5', 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_rysp3ygp5', 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_rysp3ygp5', 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini.', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 3, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_rysp3ygp5', 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_0i7g4lo4k', 'm3333333-3333-3333-3333-333333333333', '');

INSERT INTO matrix_versions (id, position_id, version_number, status, effective_date) VALUES ('m6666666-6666-6666-6666-666666666666', '66666666-6666-6666-6666-666666666666', 1, 'published', '2026-01-01');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_s7iutwpov', 'm6666666-6666-6666-6666-666666666666', 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan kegiatan pembangunan dan kemakmuran');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_s7iutwpov', 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'Dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 12, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_s7iutwpov', 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan ', 'Dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 25, 3 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_s7iutwpov', 'Pemantauan terhadap Pemanfaatan  Lumbung pangan Kalurahan dan melaporkan kepada lurah baik lisan maupun tertulis', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_s7iutwpov', 'Terlaksananya Monitoring dan Evaluasi terhadap Bantuan dan atau pembanguan yang telah dilaksanakan (Misal Perbaikan Atap TKK PKK, Perkerasan Jalan, Bantuan alat-alat pembuatan pupuk dsb ) dan melaporkan kepada lurah baik lisan maupun tertulis', 'Kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_s7iutwpov', 'Terlaksananya sosialisasi, motivasi dan peningkatan kapasitas masyarakat di bidang ekonomi dan lingkungan hidup. (contoh: penyampaian informasi di dalam forum pertemuan tentang program pembanguanan di desa)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_s7iutwpov', 'Terlaksananya pendataan dan pengelolaan profil kalurahan di Web/Aplikasi Prodeskel, sinkal dan IDM(Profil Desa/Kelurahan)', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 3, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_s7iutwpov', 'menginisiasi, mengkoordinasi dan atau menghadiri pertemuan lembaga (misal P3A Kelompok Tani, Gapoktan, KWT dll)', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_s7iutwpov', 'Terlaksananya penyebarluasan informasi rencana tata ruang pada satuan ruang strategis (contoh: menyampaikan di forum pertemuan terkait dengan informasi Tanah Keprabon dan/atau bukan Keprabon di daerah kulon progo sesuai dengan ketentuan yang berlaku)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_s7iutwpov', 'Mengkoordinasi, memantau, memastikan dan atau ikut serta dalam penyusunan Rencana Definitif Kebutuhan Kelompok (RDKK)', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_1wqtn3rnc', 'm6666666-6666-6666-6666-666666666666', 'Pelaksanaan Kegiatan Anggaran');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_1wqtn3rnc', 'Terlaksananya Informasi Publik Desa baik melalui media online maupun offline (Misal Banner APKal, Realisasi APBkal dll)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 3, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_1wqtn3rnc', 'Terlaksananya Pembangunan/Rehabilitasi/Peningkatan Perkerasan Jalan Desa', 'Bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_1wqtn3rnc', 'Terlaksananya Pembangunan Jaringan Pengairan ', 'Bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_1wqtn3rnc', 'Terlaksanaya Pengisian Direktur Bumkal', 'Bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_1wqtn3rnc', 'Terlaksanaya Bimtek/Pelatihan  Pengelolaan Bumkal', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_y4pz3mhdt', 'm6666666-6666-6666-6666-666666666666', 'Pelayanan Sesuai bidang Tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_y4pz3mhdt', 'Terlaksananya pelayanan kepada warga masyarakat terkait dengan bidang tugasnya. (contoh: Melayani konsultasi warga tentang tata cara/prosedur persyaratan-persyaratan pengajuan IMB, SKU dll)', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_r4qtsapwl', 'm6666666-6666-6666-6666-666666666666', 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_r4qtsapwl', 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Mencari salinan Perbup Nomor 16 Tahun 2020 tentang Tata Cara Pelaksanaan Kegiatan Pengadaan Barang/Jasa di Kalurahan, kemudian mempelajari, menerapkan dan mengarsipkannya dengan tertib sehingga siap disajikan apabila sewaktu-waktu dibutuhkan)', 'produk') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_x92oyzidc', 'm6666666-6666-6666-6666-666666666666', 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x92oyzidc', 'Membuat, mengisi dan mengarsipkan Buku administrasi Pemangunan (Buku Rencana Pembangunan, Buku Kegiatan Pembangunan, Buku Inventaris dan Buku Kader Pembangunan )', 'Buku') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 3, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x92oyzidc', 'Tersusunnya Laporan Kepada lurah tentang kegiatan yang diikuti (Misal : Hasil rapat, kelompoktani, gapotan, musyawarah musim tanam kemudian mempublikasikan kepada masayarakat baik secara tertulis maupun melalui forum pertemuan', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_xuj4qf95e', 'm6666666-6666-6666-6666-666666666666', 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_xuj4qf95e', 'Terlaksananya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_4rjwt837i', 'm6666666-6666-6666-6666-666666666666', 'Melaksanakan Tugas lain yang diberikan oleh Lurah');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4rjwt837i', 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4rjwt837i', 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam Tim Penyusun RKP Kalurahan) ', 'tim') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4rjwt837i', 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah. ', 'dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4rjwt837i', 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4rjwt837i', 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'spp') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_dyixhu23p', 'm6666666-6666-6666-6666-666666666666', '');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_dyixhu23p', 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_dyixhu23p', 'Mengikuti Pertemuan Tingkat Padukuhan dan atau Musyawarah Padukuhan (Musduk)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_dyixhu23p', 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_dyixhu23p', 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang) baik tingkat Kalurahan maupun Kapanewon ', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_dyixhu23p', 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_dyixhu23p', 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_dyixhu23p', 'Penulisan Informasi/berita/artikel tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya.', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_g2auk2i76', 'm6666666-6666-6666-6666-666666666666', '');

INSERT INTO matrix_versions (id, position_id, version_number, status, effective_date) VALUES ('m5555555-5555-5555-5555-555555555555', '55555555-5555-5555-5555-555555555555', 1, 'published', '2026-01-01');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_mx85lh28v', 'm5555555-5555-5555-5555-555555555555', 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan kegiatan pemerintahan dan keamanan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mx85lh28v', 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mx85lh28v', 'Terlaksananya evaluasi manajemen tata praja pemerintahan (evaluasi terhadap pelayanan dan kearsipan)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mx85lh28v', 'Terlaksananya penyusun rancangan produk regulasi. (contoh: Menyusun rancangan Peraturan Kaluran, Peraturan Lurah, Surat Keputusan, dll kemudian di sampaikan kepada carik untuk diverifikasi)', 'produk') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mx85lh28v', 'Terlaksanannya pengendalian dan evaluasi kegiatan pembinaan ketentraman dan ketertiban dan melaporkannya kepada lurah. (contoh: Ikut dalam kegiatan penyelesaian permasalahan sosial di masyarakat)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mx85lh28v', 'Terlaksananya Kegiatan Pembinaan terhadap Linmas, Forum Jagawarga', '') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mx85lh28v', 'Terlaksananya kegiatan Upaya Perlindungan Masyarakat (Misal kegiatan yang dilakukakan linmas, Forum jaga warga. ikut dalam pengamanan terhadap kegiatan keramaian di desa', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mx85lh28v', 'Terlaksananya Monitoring kegiatan siskamling', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mx85lh28v', 'Terlaksanannya koordinasi Pencegahan dan atau penanggulangan bencana. (contoh: Hadir dan aktif berkoordinasi dengan pihak terkait saat terjadi bencana banjir, kebakaran, pohon tumbang)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 9, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mx85lh28v', 'Updating data kependudukan', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mx85lh28v', 'Terlaksananya pengarsipan peta kalurahan yang ada dengan tertib.(Baik Hardcopy maupun Aplikasi/Digital)', 'Peta') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_wy4l8qiw1', 'm5555555-5555-5555-5555-555555555555', 'Kegiatan urusan Keistimewaan bidang pertanahan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_wy4l8qiw1', 'Terlaksanannya update pencatatan dan Inventaris terkait dengan Pemanfaatan dan Pengelolaan Tanah Kalurahan sebagai Dasar dalam Penyusunan Peraturan Kalurahan tentang Pengelolaan Kekayaan Kalurahan. (contoh: daftar tanah kalurahan beserta  pemanfaatannya)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_wy4l8qiw1', 'Terlaksanannya pengadministrasian tanah kalurahan dan pemanfaatannya serta penyusunan Peraturan Kalurahan terkait dengan tanah kalurahan termasuk fasilitasi permohonan izin gubernur.', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_3iv53s0x2', 'm5555555-5555-5555-5555-555555555555', 'Pelaksanaan kegiatan anggaran');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_3iv53s0x2', 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_3iv53s0x2', 'Terpenuhinya Kebutuhan Operasional Kantor BPK', 'Kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_3iv53s0x2', 'Terlaksannya kegiatan RT RW', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item; -- [INKONSISTENSI] Jumlah bulanan (19) tidak cocok dengan target tahunan (20)
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_3iv53s0x2', 'Terlaksananya kegiatan Updating Aplikasi Prodeskel, IDM dan Sinkal', 'Kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 3, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_3iv53s0x2', 'Tersusunnya Perjanjian Kinerja Lurah, Laporan Kinarja dan Survei Kepuasan Masyarakat', 'Dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 3, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_3iv53s0x2', 'Tersusunya Laporan Penyelenggaraan Pemerintah Kalurahan (LPPK)', 'Dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_3iv53s0x2', 'Terlaksananya pengembangan Sistem Informasi Kalurahan', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_3iv53s0x2', 'Terlaksananya Pelatihan/Sosialisasi Penanggulangan Bencana', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_qgyg0xumc', 'm5555555-5555-5555-5555-555555555555', 'Pelayanan sesuai bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_qgyg0xumc', 'Terlaksanannya pelayanan bidang Kependudukan, dan ijin keramaian dll)', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 16, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_qgyg0xumc', 'Terlaksananya fasilitasi Pelaksanaan Klarifikasi Pertanahan dan urusan pertanahan lainnya. (contoh: turun waris, hibah, konsolidasi tanah, dll)', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_qgyg0xumc', 'Pelayanan lain sesuai bidang tugasnya selain yang sudah tercantum dalam output kegiatan di atas.', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_wjuxsideu', 'm5555555-5555-5555-5555-555555555555', 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_wjuxsideu', 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib.(contoh: Pencarian Pergub Nomor 34 Tahun 2017  kemudian mererapkan dalam pengelolaan dan pemanfaatan tanah kalurahan sekaligus mengarsip)', 'produk') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_vqiw7gbkt', 'm5555555-5555-5555-5555-555555555555', 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_vqiw7gbkt', 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (contoh: Menyampaikan laporan baik secara tertulis maupun lisan kepada Lurah setelah melaksanakan penyelesaian permasalahan social yang terjadi di masyarakat)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_25efqvvdq', 'm5555555-5555-5555-5555-555555555555', 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_25efqvvdq', 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_39ju80zjk', 'm5555555-5555-5555-5555-555555555555', 'Pelaksanaan tugas lain yang diberikan oleh Lurah');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Kegiatan Sistem Informasi Kalurahan) ', 'tim') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 9, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'SPP') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Mengikuti Musyawarah Padukuhan dan atau pertemuan lainnya tingkat padukuhan (Musduk)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini dan melaporakan hasil pelaksanaannya kepada lurah.', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya. ', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'terlaksananya rapat koordinasi dan atau evaluasi PBB dan melaporkan hasilnya kepada lurah', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_39ju80zjk', 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_6jacd9f81', 'm5555555-5555-5555-5555-555555555555', '');

INSERT INTO matrix_versions (id, position_id, version_number, status, effective_date) VALUES ('m4444444-4444-4444-4444-444444444444', '44444444-4444-4444-4444-444444444444', 1, 'published', '2026-01-01');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_tpr7obein', 'm4444444-4444-4444-4444-444444444444', 'b');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_ttp6otdh5', 'm4444444-4444-4444-4444-444444444444', 'Perencanaan, pelaksanaan, pengendalian dan evaluasi pelaksanaan urusan ketatausahaan, umum dan perencanaan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksanannya pencermatan dan pembuatan surat sesuai tata naskah yang berlaku baik manual maupun melalui aplikasi persyuratan (contoh: membuat surat undangan, surat pengantar pengiriman Peraturan Kalurahan kepada Panewu Pengasih)', 'surat/dok.') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya register surat masuk, baik secara langsung/offline maupun melalui SID/suratku/elektronik), menyampiakan kepada lurah dan atau lainnya serta menyampaikan disposisi surat ', 'surat/dok.') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya registrasi surat keluar baik secara langsung/offline maupun melalui SID/suratku/elektronik) dan mengkoordinasi pendistribusianya (contoh: Penulisan nomor pada buku agenda surat keluar kepada Dinas PMD Dalduk dan KB ', 'surat/dok.') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksana register ekspedisi (contoh: Penulisan di buku ekspedisi Surat Dinas kepada Kapanewon Pengasih)', 'register') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya penulisan agenda kegiatan di papan jadwal agenda kegiatan dalam aplikasi online maupan media offline', 'agenda') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya penyiapan rapat (contoh: berkoordinasi dengan staf dan pamong lain yang sekiranya bisa membantu dalam menyiapkan tempat, sarana prasarana, konsumsi, MC, dirijen lagu pada kegiatan musyawarah kalurahan)', 'rapat') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 15, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya pencatatan dan inventarisasi aset kalurahan (contoh: menempel stiker nomor di kursi/meja/computer, dll dan dicatatkan di dalam buku aset)', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya fasilitasi koordinasi pelayanan umum (contoh: menyampaikan kepada staf dan/atau pamong lain terkait update aturan pelayanan persuratan, update SOP pelayanan, dll)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya kegiatan tata usaha, umum dan perencanaan terkait dengan keistimewaan (contoh: Pembuatan proposal usulan terkait Dana Keisimewaaan, pelaksanaan Musyawarah Kalurahan usulan kegiatan yang di danai Dana Keistimewaan)', '') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Berkoordinasi dengan Pamong lainnya dan memastikan dokumen administrasi Pamong Kalurahan dilaksanakan sebagaimana peraturan yang berlaku (misal berkoordinasi dengan Ulu-ulu terkait Buku administrasi  Pembangunan, berkoordinasi dengan carik terkait buku agenda perkal berkoordinasi dengan Jagabay terkait administrasi pertanahan dll). ', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya penyediaan prasarana kantor kalurahan (contoh: Pemenuhan kebutuhan lampu, kipas angin, cat tembok, dll)', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya penyediaan prasarana pamong kalurahan (contoh: ATK, alat kebersihan dan alat listrikl)', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya input data pamong di aplikasi dan manual (update) (contoh: Mencatat dan melakukan update berkala di buku pamong kalurahan/aparatur pamong kalurahan dan input/update berkala di aplikasi SID maupun SIAPDES maupun aplikasi lainnya yang relevan)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya pembuatan bagan susunan organisasi tata kerja pemerintah kalurahan (update) dan atau Lembaga lainnya', 'bagan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksanannya pemenuhan kebutuhan kerumahtanggaan pemerintah kalurahan (contoh: koordinasi terkait teknis dalam pemenuhan kebutuhan gula, gas, teh, sabun, dll)', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Terlaksananya pelaporan aset semester I dan semester II', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ttp6otdh5', 'Tersusunnya Rencana Anggaran Biaya (RAB) dalam perencanaan kegiatan tahun berikutnya maupun Perubahan APBKAL di tahun berjalan.', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_x2xk7cmge', 'm4444444-4444-4444-4444-444444444444', 'Melaksanaan kegiatan anggaran');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x2xk7cmge', 'Penyaluran siltap dan Jaminan Sosial bagi Lurah dan Pamong*', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x2xk7cmge', 'Penyediaan Operasional Pemerintah Kalurahan*', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x2xk7cmge', 'Penyediaan Operasional Pemerintah Kalurahan yang bersumber dari Dana Desa*', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x2xk7cmge', 'Pembangunan/Rehabilitasi/Peningkatan Gedung/Prasarana Kantor Kalurahan*', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 3, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x2xk7cmge', 'Penyelenggaraan Musyawarah Perencanaan Kalurahan/Pembahasan APBKal Kalurahan*', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x2xk7cmge', 'Penyelenggaraan Musyawarah Kalurahan Lainnya (Musduk, rembug warga dan lain-lain yang bersifat non-reguler)*', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x2xk7cmge', 'Penyusunan Dokumen Perencaan Kalurahan (RPJM Kal./RKP Kal., dll)*', 'Dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x2xk7cmge', 'Pengelolaan/Administrasi/Inventarisasi/Penilaian Aset Kalurahan*', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x2xk7cmge', 'Melaksanakan perekapan presensi pamong setiap bulan dan melaporkannya', 'bulan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 4, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_x2xk7cmge', 'perjanjian kerja sama dengan penyedia atas pengadaan barang/jasa ( perjanjiann konsultan pembanguan, berkoordinasi dengan ulu-ulu terkait pengadaan meterial pembangunan kantor)', 'Dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_zjwam51x1', 'm4444444-4444-4444-4444-444444444444', 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_zjwam51x1', 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib. (contoh: Pencarian Peraturan Bupati Kulon Progo Nomor 67 Tahun 2019 tentang Pedoman Tata Naskah Dinas Pemerintah Kalurahan kemudian diterapkan dalam pembuatan surat dinas sekaligus mengarsipkannya dengan tertib)', 'produk') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_9jy4mh3ah', 'm4444444-4444-4444-4444-444444444444', 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_9jy4mh3ah', 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (laporan pelaksanaan pembangunan kantor)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_zwu9mrel4', 'm4444444-4444-4444-4444-444444444444', 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_zwu9mrel4', 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_2kxos7c7d', 'm4444444-4444-4444-4444-444444444444', 'Melaksanaan tugas lain yang diberikan oleh Lurah');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. ', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam Tim Penyusunan RKP Kalurahan) ', 'tim') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 3, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip/dok.') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Terlaksanannya pengantaran surat/dokumen berdasarkan tugas yang diberikan oleh Lurah.  ', 'surat/dok.') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Terlaksananya penyusunan laporan pelaksanaan kegiatan sesuai bidang tugasnya setiap semester dan untuk pertanggungjawaban pelaksanaan APBKAL selama 1 tahun anggaran . (contoh: laporan penggunaan anggaran kegiatan dan sisa anggaran kegiatan, beserta alasannya apabila ada sisa anggaran)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Terlaksananya penyusunan dan mengajukan SPP dan SPJ kegiatan kepada bendahara maksimal 5 hari kerja setelah kegiatan selesai dilaksanakan.', 'SPP') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melaporkan kepada lurah pelaksanaan program kegiatannya, termasuk permasalahan, hambatan, serta solusinya)', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Mengikuti Musyawarah Padukuhan (Musduk)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini.', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2kxos7c7d', 'Penulisan Informasi/berita tentang kegiatan, potensi atau prestasi sesuai bidang tugasnya. ', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_99aoq31x0', 'm4444444-4444-4444-4444-444444444444', '');

INSERT INTO matrix_versions (id, position_id, version_number, status, effective_date) VALUES ('m8888888-8888-8888-8888-888888888888', '88888888-8888-8888-8888-888888888888', 1, 'published', '2026-01-01');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_m5y6596up', 'm8888888-8888-8888-8888-888888888888', 'Membantu pelaksanaan tugas Lurah di wilayah Padukuhan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_m5y6596up', 'Pembinaan Ketentraman dan Ketertiban, mobilitas penduduk, penataan administratif (misal Koordinasi, ikut serta, atau monitoring kegiatan siskamling. Mencatat dan membukukan mobilisasi penduduk)', 'Kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_m5y6596up', 'Perencanaan, pelaksanaan dan evaluasi pembangunan di wilayahnya ( Misal Koordinasi dengan RT, RW, KKLKMK atau lainnya..)', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_m5y6596up', 'Terlaksananya dan/atau menghadiri kegiatan kerja bakti, dan/atau kegiatan lain terkait dengan upaya menjaga kebersihan dan kesehatan lingkungan di tingkat padukuhan maupun RT.', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_m5y6596up', 'Terlaksananya dan/atau menghadiri kegiatan persiapan pelaksanaan hajatan di masyarakat. (contoh: pernikahan, lamaran, pengajian, lelayu/pemberangkatan jenazah dan kegiatan masyarakat lainnya)', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_m5y6596up', 'Terlaksananya pemantauan dan melaporkan kepada lurah terkait dengan penggunaan dan pemanfaatan tanah kalurahan di wilayah masing-masing (contoh: Pemantauan terhadap tanah Kalurahan yang diapaki Fasum/Fasus dan membukukan dalam dalam buku khusus sehingga dapt dibukukan jika terdapat perubahan penggunan', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_kn2hmk5i3', 'm8888888-8888-8888-8888-888888888888', 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_kn2hmk5i3', 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib.(misal Mengarsip Perkal, Perbup dan atau mambuat database kependudukan diwilayahnya)', 'produk') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_a0g8jdcvn', 'm8888888-8888-8888-8888-888888888888', 'Membantu pelayanan umum di kantor kalurahan;');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_a0g8jdcvn', 'Terlaksanannya terkait dengan pelayanan di kalurahan (contoh: surat keterangan usaha, surat keterangan domisili, surat keterangan tidak mampu, pengantar pernikahan, dan pelayanan lainnya yang dilayani oleh pemerintah kalurahan)', 'surat') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_ampo59nlr', 'm8888888-8888-8888-8888-888888888888', 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ampo59nlr', 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (contoh: Menyampaikan laporan baik secara tertulis  kepada Lurah setelah melaksanakan penyelesaian permasalahan social yang terjadi di masyarakat, atau kegiatan lainnya baik yaang dianggarak APBKal maupun tidak dianggarkan)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_jwk2ww8xq', 'm8888888-8888-8888-8888-888888888888', 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_jwk2ww8xq', 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_hrfaeqev9', 'm8888888-8888-8888-8888-888888888888', 'Melaksanakan Tugas lain yang diberikan oleh Lurah');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. (termasuk Undangan Kalurahan atau kapanewon)', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Kegiatan Posyandu, dll) ', 'tim') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Terlaksanannya pengantaran dan/atau pengambilan surat/dokumen terkait dengan tugas kedinasan.  ', 'dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melakukan evaluasi terhadap kegiatan yang dilakukakan di wilayahnua dan Melaporkan kepada lurah, termasuk permasalahan, hambatan, serta solusinya)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Mengadakan Musyawarah Padukuhan (Musduk) dan atau pertemuan lainnya', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Terlaksanannya sambutan atau sebutan lainnya di acara hajatan di masyarakat (contoh: pernikahan, lamaran, pengajian, lelayu/pemberangkatan jenazah dan kegiatan masyarakat lainnya)', 'acara') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Terlaksanannya pengkondisian permasalahan dan/atau bencana yang terjadi di wilayahnya selanjutnya melaporkan kepada lurah (contoh: banjir, tanah longsor, masalah sosial kemasyarakatan, dll)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Terlaksananya pendampingan pengantaran ODGJ, Donor darah atau Pengobatan', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini dan melaporakan hasil pelaksanaannya kepada lurah.', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_hrfaeqev9', 'Tercapainya Pembayaran PBB-P2 (non-Tanah Desa) di Padukuhan dalam 
(5 SPPT=1 poin).', 'poin') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item; -- [INKONSISTENSI] Jumlah bulanan (9) tidak cocok dengan target tahunan (10)
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_a2idtznc0', 'm8888888-8888-8888-8888-888888888888', '');

INSERT INTO matrix_versions (id, position_id, version_number, status, effective_date) VALUES ('m9999999-9999-9999-9999-999999999999', '99999999-9999-9999-9999-999999999999', 1, 'published', '2026-01-01');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_2fsod6ut2', 'm9999999-9999-9999-9999-999999999999', 'Membantu pelaksanaan tugas Lurah di wilayah Padukuhan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2fsod6ut2', 'Pembinaan Ketentraman dan Ketertiban, mobilitas penduduk, penataan administratif (misal Koordinasi, ikut serta, atau monitoring kegiatan siskamling. Mencatat dan membukukan mobilisasi penduduk)', 'Kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2fsod6ut2', 'Perencanaan, pelaksanaan dan evaluasi pembangunan di wilayahnya ( Misal Koordinasi dengan RT, RW, KKLKMK atau lainnya..)', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2fsod6ut2', 'Terlaksananya dan/atau menghadiri kegiatan kerja bakti, dan/atau kegiatan lain terkait dengan upaya menjaga kebersihan dan kesehatan lingkungan di tingkat padukuhan maupun RT.', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2fsod6ut2', 'Terlaksananya dan/atau menghadiri kegiatan persiapan pelaksanaan hajatan di masyarakat. (contoh: pernikahan, lamaran, pengajian, lelayu/pemberangkatan jenazah dan kegiatan masyarakat lainnya)', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2fsod6ut2', 'Terlaksananya pemantauan dan melaporkan kepada lurah terkait dengan penggunaan dan pemanfaatan tanah kalurahan di wilayah masing-masing (contoh: Pemantauan terhadap tanah Kalurahan yang diapaki Fasum/Fasus dan membukukan dalam dalam buku khusus sehingga dapt dibukukan jika terdapat perubahan penggunan', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_5g6snua01', 'm9999999-9999-9999-9999-999999999999', 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_5g6snua01', 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib.(misal Mengarsip Perkal, Perbup dan atau mambuat database kependudukan diwilayahnya)', 'produk') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_9w8z10znf', 'm9999999-9999-9999-9999-999999999999', 'Membantu pelayanan umum di kantor kalurahan;');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_9w8z10znf', 'Terlaksanannya terkait dengan pelayanan di kalurahan (contoh: surat keterangan usaha, surat keterangan domisili, surat keterangan tidak mampu, pengantar pernikahan, dan pelayanan lainnya yang dilayani oleh pemerintah kalurahan)', 'surat') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_2y1lp67w4', 'm9999999-9999-9999-9999-999999999999', 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_2y1lp67w4', 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (contoh: Menyampaikan laporan baik secara tertulis  kepada Lurah setelah melaksanakan penyelesaian permasalahan social yang terjadi di masyarakat, atau kegiatan lainnya baik yaang dianggarak APBKal maupun tidak dianggarkan)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_9spn6r5zs', 'm9999999-9999-9999-9999-999999999999', 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_9spn6r5zs', 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_4xeqtauv1', 'm9999999-9999-9999-9999-999999999999', 'Melaksanakan Tugas lain yang diberikan oleh Lurah');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. (termasuk Undangan Kalurahan atau kapanewon)', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Kegiatan Posyandu, dll) ', 'tim') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Terlaksanannya pengantaran dan/atau pengambilan surat/dokumen terkait dengan tugas kedinasan.  ', 'dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melakukan evaluasi terhadap kegiatan yang dilakukakan di wilayahnua dan Melaporkan kepada lurah, termasuk permasalahan, hambatan, serta solusinya)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Mengadakan Musyawarah Padukuhan (Musduk) dan atau pertemuan lainnya', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Terlaksanannya sambutan atau sebutan lainnya di acara hajatan di masyarakat (contoh: pernikahan, lamaran, pengajian, lelayu/pemberangkatan jenazah dan kegiatan masyarakat lainnya)', 'acara') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Terlaksanannya pengkondisian permasalahan dan/atau bencana yang terjadi di wilayahnya selanjutnya melaporkan kepada lurah (contoh: banjir, tanah longsor, masalah sosial kemasyarakatan, dll)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Terlaksananya pendampingan pengantaran ODGJ, Donor darah atau Pengobatan', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini dan melaporakan hasil pelaksanaannya kepada lurah.', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_4xeqtauv1', 'Tercapainya Pembayaran PBB-P2 (non-Tanah Desa) di Padukuhan dalam 
(5 SPPT=1 poin).', 'poin') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item; -- [INKONSISTENSI] Jumlah bulanan (9) tidak cocok dengan target tahunan (10)
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_jw26mzl55', 'm9999999-9999-9999-9999-999999999999', '');

INSERT INTO matrix_versions (id, position_id, version_number, status, effective_date) VALUES ('maaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, 'published', '2026-01-01');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_m15ytfdtm', 'maaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Membantu pelaksanaan tugas Lurah di wilayah Padukuhan');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_m15ytfdtm', 'Pembinaan Ketentraman dan Ketertiban, mobilitas penduduk, penataan administratif (misal Koordinasi, ikut serta, atau monitoring kegiatan siskamling. Mencatat dan membukukan mobilisasi penduduk)', 'Kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_m15ytfdtm', 'Perencanaan, pelaksanaan dan evaluasi pembangunan di wilayahnya ( Misal Koordinasi dengan RT, RW, KKLKMK atau lainnya..)', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_m15ytfdtm', 'Terlaksananya dan/atau menghadiri kegiatan kerja bakti, dan/atau kegiatan lain terkait dengan upaya menjaga kebersihan dan kesehatan lingkungan di tingkat padukuhan maupun RT.', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_m15ytfdtm', 'Terlaksananya dan/atau menghadiri kegiatan persiapan pelaksanaan hajatan di masyarakat. (contoh: pernikahan, lamaran, pengajian, lelayu/pemberangkatan jenazah dan kegiatan masyarakat lainnya)', 'kegiatan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_m15ytfdtm', 'Terlaksananya pemantauan dan melaporkan kepada lurah terkait dengan penggunaan dan pemanfaatan tanah kalurahan di wilayah masing-masing (contoh: Pemantauan terhadap tanah Kalurahan yang diapaki Fasum/Fasus dan membukukan dalam dalam buku khusus sehingga dapt dibukukan jika terdapat perubahan penggunan', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_mlp4jl0r8', 'maaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Mencari, mengumpulkan, menghimpun dan mengolah serta menyajikan data dan informasi yang berhubungan dengan bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_mlp4jl0r8', 'Tersusunnya dan terarsipkannya himpunan informasi mengenai regulasi, dan informasi terbaru sesuai bidang tugasnya, dan melaksanakan serta mengarsipkannya dengan tertib.(misal Mengarsip Perkal, Perbup dan atau mambuat database kependudukan diwilayahnya)', 'produk') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_s9gnufzwt', 'maaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Membantu pelayanan umum di kantor kalurahan;');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_s9gnufzwt', 'Terlaksanannya terkait dengan pelayanan di kalurahan (contoh: surat keterangan usaha, surat keterangan domisili, surat keterangan tidak mampu, pengantar pernikahan, dan pelayanan lainnya yang dilayani oleh pemerintah kalurahan)', 'surat') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_48a4hi6u5', 'maaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Membuat laporan pelaksanaan seluruh kegiatan sesuai bidang tugasnya');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_48a4hi6u5', 'Tersusunnya laporan pelaksanaan kegiatan kepada Lurah sesuai dengan bidang tugasnya. (contoh: Menyampaikan laporan baik secara tertulis  kepada Lurah setelah melaksanakan penyelesaian permasalahan social yang terjadi di masyarakat, atau kegiatan lainnya baik yaang dianggarak APBKal maupun tidak dianggarkan)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_jrre9sgdd', 'maaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Memberikan saran dan pertimbangan kepada Lurah mengenai kebijakan dan tindakan yang akan diambil');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_jrre9sgdd', 'Terlaksanannya penyampaian saran dan pertimbangan kepada Lurah mengenai kebijakan yang akan diambil', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_ul0t1zczp', 'maaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Melaksanakan Tugas lain yang diberikan oleh Lurah');
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Terlaksananya tugas disposisi surat, undangan dan/atau tugas lain dari Lurah dan melaporkan hasil pelaksanaannya kepada Lurah. (termasuk Undangan Kalurahan atau kapanewon)', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Terlaksananya tugas menjadi bagian dalam Tim Pelaksana Kegiatan (TPK), dan/atau Tim lainnya berdasarkan Surat Keputusan. (contoh: Masuk dalam TPK Kegiatan Posyandu, dll) ', 'tim') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Tersusunnya arsip setiap dokumen dan/atau berkas atas bidang tugasnya (contoh: Mengarsipkan dokumen SPP-SPJ, berita acara, perjanjian, dll pada semua kegiatan bidang tugasnya dengan tertib sehingga apabila dibutuhkan setiap waktu siap untuk disajikan) ', 'arsip') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Terlaksanannya pengantaran dan/atau pengambilan surat/dokumen terkait dengan tugas kedinasan.  ', 'dokumen') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Terlaksananya monitoring dan evaluasi program kegiatan sesuai bidang tugasnya dan melaporkannya kepada lurah setiap bulan. (contoh: Melakukan evaluasi terhadap kegiatan yang dilakukakan di wilayahnua dan Melaporkan kepada lurah, termasuk permasalahan, hambatan, serta solusinya)', 'laporan') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Mengadakan Musyawarah Padukuhan (Musduk) dan atau pertemuan lainnya', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 2, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Mengikuti Musyawarah Kalurahan (Muskal)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Mengikuti Musyawarah Rencana Pembangunan (Musrenbang)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Terlaksanannya sambutan atau sebutan lainnya di acara hajatan di masyarakat (contoh: pernikahan, lamaran, pengajian, lelayu/pemberangkatan jenazah dan kegiatan masyarakat lainnya)', 'acara') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Terlaksanannya pengkondisian permasalahan dan/atau bencana yang terjadi di wilayahnya selanjutnya melaporkan kepada lurah (contoh: banjir, tanah longsor, masalah sosial kemasyarakatan, dll)', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 5, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Terlaksananya pendampingan pengantaran ODGJ, Donor darah atau Pengobatan', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 1, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Terlaksananya pelaksanaan tugas lain yang diberikan oleh Lurah selain yang sudah tercantum dalam output kegiatan ini dan melaporakan hasil pelaksanaannya kepada lurah.', 'kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'mengikuti rapat koordinasi dan atau apel rutin', 'Kali') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 20, 2 FROM new_item;
WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), 'g_ul0t1zczp', 'Tercapainya Pembayaran PBB-P2 (non-Tanah Desa) di Padukuhan dalam 
(5 SPPT=1 poin).', 'poin') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, 10, 1 FROM new_item; -- [INKONSISTENSI] Jumlah bulanan (9) tidak cocok dengan target tahunan (10)
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_6sre1x5hd', 'maaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '');

INSERT INTO matrix_versions (id, position_id, version_number, status, effective_date) VALUES ('mbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 1, 'published', '2026-01-01');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_nmcf19ake', 'mbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Kedisiplinan Pelaksanaan Tugas');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_05rhjitxt', 'mbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Pelayanan Prima (Keterangan: Pelayanan Selesai dalam waktu maksimal 10 menit)');
INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('g_87xf37mt4', 'mbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Pelaksanaan Tugas Pembantuan kepada Lurah dan Pamong');

