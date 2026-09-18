# AUDIT IMPLEMENTATION PLAN V1 — REVISION 2

## 1. Executive Summary
Laporan audit ini merupakan revisi dari audit sebelumnya guna menyelaraskan arsitektur teknis dengan prinsip kepatuhan regulasi secara ketat. Berdasarkan telaah ulang, masih terdapat beberapa celah arsitektur terkait penanganan waktu (timezone), *historical immutability* yang belum paripurna, serta asumsi-asumsi matematis/populasi yang berpotensi menyimpang dari regulasi. Proses pengembangan (coding) masih berstatus **BLOCKED** hingga seluruh `BUSINESS DECISION REQUIRED` mendapatkan putusan final dari owner.

## 2. Findings yang tetap valid
- **Historical Immutability (Delete Cascade)**: Master data tidak boleh menggunakan `ON DELETE CASCADE`. Matriks yang sudah dipakai dilarang keras untuk dihapus demi menjaga konsistensi histori jurnal.
- **Attendance Duplicate**: Diperlukan constraint mutlak di level database `UNIQUE(employee_id, attendance_date)` untuk mencegah presensi ganda.
- **Security & RLS**: Keamanan data tetap dijalankan murni dari sisi database via *Row Level Security* (RLS) di mana User hanya bisa mengakses data pribadinya dan Admin (Carik) mengelola master.
- **Keharusan Capping & Definisi Capaian**: Ambigu pada definisi 1 Capaian CK.B dan aturan limitasi Kinerja (KB) tetap valid sebagai *Blocked Issue* yang butuh keputusan.

## 3. Findings yang harus dikoreksi
- **Koreksi Journal Overlap**: Rekomendasi constraint *GiST* sebelumnya keliru karena hanya menggunakan range jam (tanpa tanggal). Harus dikoreksi dengan menggabungkan `activity_date` dan `time` menjadi `timestamp`.
- **Koreksi Timezone**: Solusi timezone tidak sebatas memasukkan `NOW()` di DB, melainkan wajib menggunakan `timestamptz`. Waktu bisnis (hari kerja, jam kerja, pergantian tanggal) mutlak diproses dengan konteks `Asia/Jakarta`.
- **Koreksi Asumsi Populasi Lurah**: Asumsi sebelumnya yang secara otomatis mendiskualifikasi "Staf" dari rata-rata Tukin Lurah adalah keliru. Populasi mutlak bergantung pada definisi hukum "Pamong" yang aktif pada bulan perhitungan.
- **Koreksi Asumsi Gap NPK**: Asumsi sebelumnya terkait adanya celah (gap) antar desimal NPK (misal 90.01 - 90.99) dikoreksi. Interval regulasi dapat diinterpretasikan secara matematis kontinu (misal: `81 <= NPK < 91`). Keputusan pembulatan/desimal harus ditentukan regulasi.
- **Koreksi Alur Capaian (Capaian Value)**: Kolom `capaian_value` tidak boleh diinput atau dimanipulasi oleh user. User murni hanya menginput `realisasi` (kuantitas), kemudian *Business Logic* yang bertugas mengonversinya menjadi *Capaian CK.B*.

## 4. Database Architecture
| ID | AREA | FINDING | EVIDENCE | RISK | SEVERITY | RECOMMENDATION | STATUS |
|----|------|---------|----------|------|----------|----------------|--------|
| DB-01 | Constraint | Skema awal menggunakan `CASCADE` pada `performance_items`. | Skema DDL V1. | Histori jurnal dan kalkulasi Tukin hilang jika matriks dihapus. | CRITICAL | Ubah `CASCADE` menjadi `RESTRICT`. Gunakan mekanisme *Soft Delete* untuk master data (matriks). | BLOCKED |
| DB-02 | Field Types | Tanggal dan waktu tidak tersimpan dengan offset timezone yang eksplisit. | Tipe data `TIME` di jurnal. | Validasi *overlap* dan jam kerja bisa tembus jika beda zona waktu. | HIGH | Gunakan `timestamptz` atau kombinasikan date+time ke bentuk *timezone-aware* sebelum validasi. | READY |

## 5. Security/RLS
| ID | AREA | FINDING | EVIDENCE | RISK | SEVERITY | RECOMMENDATION | STATUS |
|----|------|---------|----------|------|----------|----------------|--------|
| SEC-01 | RLS Escalation | Role `admin` (Carik) berpotensi memanipulasi persetujuan yang bukan wewenangnya jika tak dicegah. | Rancangan role otorisasi. | Pelanggaran wewenang (Lurah vs Carik). | HIGH | Pisahkan validasi *role* secara fungsional. Admin untuk teknis/master, otorisator/approval sesuai keputusan bisnis. | BLOCKED |

## 6. Matrix
| ID | AREA | FINDING | EVIDENCE | RISK | SEVERITY | RECOMMENDATION | STATUS |
|----|------|---------|----------|------|----------|----------------|--------|
| MAT-01 | Workflow | Wewenang tombol *Approve* matriks (Review → Published) masih kosong. | Implementation Plan V1. | Matriks di-approve oleh pihak yang salah. | CRITICAL | Putuskan apakah Carik atau Lurah yang menyetujui. (BUSINESS DECISION REQUIRED). | BLOCKED |

## 7. Journal
| ID | AREA | FINDING | EVIDENCE | RISK | SEVERITY | RECOMMENDATION | STATUS |
|----|------|---------|----------|------|----------|----------------|--------|
| JRN-01 | Overlap Constraint | Tidak ada blokir waktu ganda yang komprehensif hari-per-hari. | Kebutuhan V1 tidak boleh overlap. | 1 Pegawai mengeklaim 2 kegiatan di jam yang sama. | HIGH | Gunakan `EXCLUDE USING gist (employee_id WITH =, tsrange((activity_date + start_time)::timestamp, (activity_date + end_time)::timestamp) WITH &&)`. | READY |
| JRN-02 | Integrity | User bisa memanipulasi nilai `capaian_value`. | Desain awal. | Inflasi nilai CK.B secara sepihak. | CRITICAL | User hanya memasukkan `realisasi`. `capaian` di-generate via *Server Action* / DB Trigger saat jurnal disetujui. | READY |

## 8. Attendance
| ID | AREA | FINDING | EVIDENCE | RISK | SEVERITY | RECOMMENDATION | STATUS |
|----|------|---------|----------|------|----------|----------------|--------|
| ATT-01 | Duplication | User bisa check-in dua kali di tanggal yang sama. | Desain awal tanpa constraint. | Kalkulasi hari kerja (HK / MK) ganda. | HIGH | Tetapkan `UNIQUE(employee_id, attendance_date)` di level database. | READY |
| ATT-02 | Timezone Trust | Server mengandalkan jam *client/browser*. | Rancangan umum. | Karyawan memanipulasi jam lokal agar tidak terlambat. | CRITICAL | Selalu ambil nilai default timestamp `NOW()` dengan paksaan zona waktu `Asia/Jakarta` dari sisi server. | READY |

## 9. CK.B / KB / NPK
| ID | AREA | FINDING | EVIDENCE | RISK | SEVERITY | RECOMMENDATION | STATUS |
|----|------|---------|----------|------|----------|----------------|--------|
| CKB-01 | Definisi CK.B | Rumus "1 Capaian" belum didefinisikan secara matematis. | Regulasi tidak mengatur teknis aplikasi. | Salah menerjemahkan *Realisasi* menjadi *Capaian*. | CRITICAL | Mintakan keputusan ke Owner (BUSINESS DECISION REQUIRED). | BLOCKED |
| CKB-02 | Capping KB | Eksekusi ketika nilai aktual Kinerja Bulanan (KB) melebihi 100%. | Simulasi matematika. | Inflasi NPK dan persen Tukin tembus limit wajar. | HIGH | Berikan ilustrasi matematis capping vs no-capping untuk diputuskan Owner. | BLOCKED |
| CKB-03 | Status Jurnal | Jurnal Draft/Rejected berisiko ikut tersedot engine kalkulasi. | Skema status. | Nilai CK.B tidak valid. | HIGH | Pastikan SQL `WHERE status IN ('Approved', 'Locked')` pada saat *Calculation Engine* beroperasi. | READY |
| CKB-04 | Interval NPK | Jeda desimal di antara batas (misal: `90.5`) belum terpetakan. | Regulasi batas nilai bulat (81-90, 91-100). | Angka desimal mengembalikan persen Tukin = 0 (Error/Undefined). | HIGH | Minta klarifikasi apakah digunakan *Floor*, *Ceil*, *Round*, atau batas kontinu `<= NPK <`. | BLOCKED |

## 10. Tukin Pamong
Tabel `tukin_calculations` wajib di-upgrade. Jika Tukin Pamong sudah selesai (status Locked), seluruh *Business Rule* yang terlibat hari itu (seperti Pagu Tukin, Posisi/Jabatan saat itu, target TK.B, nominal *disciplinary adjustment*, dan versi formula) wajib terekam (snapshot) secara utuh. Jika Master Pagu bulan depan diubah, histori Tukin Pamong ini tidak boleh berubah nilainya (*Immutable*).

## 11. Tukin Lurah
| ID | AREA | FINDING | EVIDENCE | RISK | SEVERITY | RECOMMENDATION | STATUS |
|----|------|---------|----------|------|----------|----------------|--------|
| TKL-01 | Populasi Pamong | Asumsi mengeluarkan "Staf" dari pembagi (denominator) rata-rata Tukin Lurah. | Asumsi sebelumnya. | Salah menghitung rata-rata Tukin karena populasinya keliru. | HIGH | Jangan berasumsi. Tanyakan definisi "Seluruh Pamong" yang sah sesuai regulasi. (BUSINESS DECISION REQUIRED). | BLOCKED |

## 12. Historical Integrity
Snapshot Kalkulasi saat ini berstatus **INCOMPLETE**. Rekomendasi arsitektur tabel harus dimodifikasi untuk menampung:
1. `formula_version` / `rule_version` (Versi interval NPK).
2. `pagu_snapshot` (Nominal Master Pagu pada tanggal kalkulasi).
3. `target_snapshot` (Target CK.B Minimal).
4. `position_snapshot` (Posisi/Jabatan pegawai saat kalkulasi terjadi).
5. `disciplinary_deductions_detail` (JSON/Teks berisi besaran potongan jika ada sanksi, agar mudah direproduksi alasannya).

## 13. Testing
Daftar 37 Skenario *Test Case* pada Audit V1 tetap dipertahankan. Wajib dijalankan (UAT) kelak.

## 14. BUSINESS DECISION REQUIRED
Di bawah ini adalah pertanyaan-pertanyaan yang HARUS diputuskan terlebih dahulu sebelum implementasi kode.

1. **Definisi Teknis "1 Capaian CK.B"**:
   Jika dalam 1 Jurnal, pegawai memasukkan *Realisasi = 10 Dokumen*.
   Apakah sistem menghitungnya sebagai:
   - Opsi A: **1 Capaian** (karena dihitung per 1 kali aktivitas jurnal/kegiatan).
   - Opsi B: **10 Capaian** (karena jumlah realisasi kuantitatif menjadi poin mutlak capaian).
   - Opsi C: Mekanisme lain.

2. **Perlakuan Capping KB (>100%)**:
   Jika Kinerja (CK.B) 50 dari Target (TK.B) 40. Maka KB = 125%.
   - Konsekuensi Tanpa Capping: NPK bisa menembus di atas batas interval maksimum 100.
   - Konsekuensi Dengan Capping: Berapapun lebihnya, KB dikunci maksimal 100%.

3. **Wewenang Reviewer Matriks (Approval)**:
   Siapakah otoritas/jabatan yang sah memencet tombol *Setujui Matriks*? 
   (Meski Carik = Admin, apakah otorisasi matriks ini wewenang teknis Carik, atau wewenang substantif Lurah?).

4. **Wewenang Reviewer Jurnal**:
   Siapakah yang berhak memverifikasi (Verified/Approved) Jurnal Kinerja harian Pamong?

5. **Resolusi Interval / Desimal NPK**:
   Kategori Tukin berdasar regulasi: 81-90, lalu 91-100.
   Jika NPK yang didapat secara matematis adalah **`90.5`**. 
   - Pendekatan A (Rounding Standard): Menjadi 91 -> Kategori 91-100.
   - Pendekatan B (Floor): Menjadi 90 -> Kategori 81-90.
   - Pendekatan C (Batas Kontinu): `81 <= NPK < 91`.

6. **Definisi Populasi "Pamong" (Tukin Lurah)**:
   Perhitungan Tukin Lurah = Rata-rata Persentase Tukin seluruh Pamong.
   Apakah Staf yang berstatus aktif (jika ada di masa depan) masuk menjadi pembagi rata-rata ini?

## 15. BLOCKED
- Fitur Kalkulasi (Calculation Engine) CK.B, KB, NPK, Tukin.
- Fitur Approval (Matriks & Jurnal).
- Skema DDL/Migration (SQL) untuk Master Tabel (harus dirombak sesuai `RESTRICT` dan Snapshot historis penuh).

## 16. READY FOR IMPLEMENTATION
- Skema Validasi Server-side (Timezone Asia/Jakarta).
- Skema Anti-Duplikasi (Attendance UNIQUE, Journal EXCLUDE GiST tsrange).
- Security Basic RLS (Data Isolation).
- Struktur Modular Next.js.
