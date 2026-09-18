# AUDIT IMPLEMENTATION PLAN V1

## 1. Executive Summary
Status: **NOT READY** (Membutuhkan beberapa keputusan bisnis fundamental dan perbaikan skema *database* terkait *historical immutability* dan proteksi *overlap* sebelum *coding* dimulai).

Sistem secara garis besar sudah menangkap alur Tukin, namun masih memiliki celah pada konsistensi histori data, validasi *overlap* waktu jurnal, dan ambiguitas pada definisi matematis "Capaian" serta "Capping" yang berisiko memunculkan *bug* perhitungan finansial.

## 2. Critical Findings

| ID | Area | Temuan | Risiko | Severity | Rekomendasi |
|----|------|--------|--------|----------|-------------|
| 01 | Database (FK Cascade) | Penggunaan `ON DELETE CASCADE` pada hierarki matriks (groups, items). Jika admin menghapus matriks lama, seluruh histori jurnal pegawai akan ikut terhapus (*data loss*). | Hilangnya histori jurnal dan perhitungan Tukin bulan lalu. | **CRITICAL** | Ubah menjadi `RESTRICT` pada relasi historis. Gunakan *Soft Delete* (kolom `is_deleted`) untuk master data. |
| 02 | Database (Overlap) | Belum ada proteksi tingkat *database* untuk *overlap* waktu Jurnal maupun duplikasi Presensi. | Pegawai bisa klaim 2 jurnal di rentang waktu yang sama atau presensi ganda. | **HIGH** | Gunakan `EXCLUDE USING gist (tsrange)` untuk jurnal dan `UNIQUE(employee_id, date)` untuk presensi. |
| 03 | Logika Bisnis (Capaian) | Definisi "1 Capaian CK.B" belum memiliki rumusan teknis yang disetujui. | Perhitungan CK.B bisa salah sasaran (terlalu kecil/terlalu besar). | **CRITICAL** | Eskalasi ke Owner (BUSINESS DECISION REQUIRED #1). |
| 04 | Logika Bisnis (Capping) | Tidak ada aturan eksplisit jika KB (Kinerja Bulanan) melebihi 100%. | Nilai NPK dan pemetaan persentase Tukin akan jebol (melebihi 100%). | **HIGH** | Eskalasi ke Owner (BUSINESS DECISION REQUIRED #2). |
| 05 | Logika Bisnis (Interval NPK) | Batas *boundary* interval NPK memiliki celah nilai desimal (misal 90.01 s/d 90.99 tidak masuk kategori 81-90 atau 91-100). | NPK desimal tidak mendapatkan persentase Tukin (jatuh ke 0 atau error). | **HIGH** | Tentukan aturan pembulatan (*rounding*) NPK (BUSINESS DECISION REQUIRED #4). |
| 06 | Keamanan (Timezone) | Waktu check-in/out sangat rentan dimanipulasi jika menggunakan *browser time* (client-side). | Pegawai bisa memalsukan jam check-in agar tidak telat. | **CRITICAL** | `check_in` dan `check_out` wajib menggunakan `NOW()` di *Server/Database* dengan zona waktu Asia/Jakarta. |

## 3. Database Audit
- **Pemisahan Entitas**: Skema `auth.users` → `profiles` → `employees` → `positions` sudah memenuhi kaidah pemisahan identitas dengan peran historis. Pergantian akun tidak merusak data.
- **Foreign Keys**: Terdapat kelemahan `CASCADE` pada `performance_items` dan `matrix_versions`. Harus diganti `RESTRICT` agar matriks yang sudah dipakai jurnal tidak bisa dihapus.
- **Data Historis (Calculation)**: Tabel `tukin_calculations` saat ini hanya menyimpan `tukin_amount`. Seharusnya ikut melakukan *snapshot* nilai `pagu_tukin_snapshot` dan `sanksi_snapshot` pada saat kalkulasi dilakukan, sehingga jika pagu master berubah, histori slip Tukin tidak berubah.
- **Duplicate Data**: 
  - *Attendance*: Perlu `UNIQUE (employee_id, attendance_date)`.
  - *Journal Overlap*: Perlu proteksi GiST constraint di PostgreSQL: `EXCLUDE USING gist (employee_id WITH =, tsrange(start_time, end_time) WITH &&)`.

## 4. Business Logic Audit
- **Tukin Lurah**: Formula `Rata-rata Tukin Pamong × Pagu Lurah` sudah dipahami. Populasi Pamong: Semua `employees` aktif dengan role User, kecuali Lurah dan Staf (serta Bamuskal yang memang *out of scope*).
- **Disciplinary Actions**: Tabel `disciplinary_actions` harus memisahkan "Keterlambatan", "Tidak Hadir", "Potongan Laporan" agar tidak tercampur dalam satu persentase kasar.

## 5. Security/RLS Audit
- RLS secara prinsipil sudah dirancang (User akses milik sendiri, Carik akses semua).
- **Privilege Escalation**: Harus dipastikan fungsi *Approve/Review* tidak tereksekusi oleh role `user` yang bukan Carik/Lurah melalui celah API (IDOR).
- **Timezone Tampering**: Seluruh pencatatan waktu harus di sisi DB/Server menggunakan zona waktu `Asia/Jakarta`. Waktu lokal perangkat tidak boleh dipercaya.

## 6. Matrix Audit
- **Versioning**: Aturan Draft → Review → Published → Locked sudah terkonsep.
- **Mutabilitas**: Harus ada *Trigger* / RLS yang menolak `UPDATE` pada `matrix_versions` jika statusnya `Published`/`Locked`.
- **Dukuh**: Satu matriks untuk 3 Dukuh sudah dipenuhi.
- **Staf**: Status *template* tanpa diikutkan kalkulasi sudah dipenuhi.

## 7. Journal Audit
- Snapshot target dan satuan sudah ada di struktur `target_snapshot`, `unit_snapshot`.
- Harus ada kolom `capaian_value` yang bersifat statis setelah di-*submit*, agar tidak terpengaruh perubahan interpretasi formula di masa depan.
- Aturan V1: *Overlap* waktu dilarang keras.

## 8. Attendance Audit
- Parameter Jam Kerja (Senin-Kamis 07:30-15:45, Jumat 07:30-15:30) harus berada di tabel `village_settings` dan diaplikasikan via kalkulator presensi di server.
- Belum ada status khusus untuk `tugas_luar` vs `hadir_kantor` secara bersamaan di tabel *attendance*. Sebaiknya *official_duties* disinkronisasi ke presensi secara harian.

## 9. Tukin Calculation Audit
- Rumus PB dan KB sejauh ini sesuai standar regulasi. 
- *Boundary Conditions* NPK sangat rentan jika angka hasil perhitungan desimal (misal 90.4). Harus ada kejelasan pembulatan.

## 10. Historical Data Integrity Audit
- **Calculation Table** kurang lengkap. Harus menambah field:
  - `pagu_snapshot`
  - `min_ckb_snapshot`
  - `disciplinary_deduction_amount`
  - Agar perhitungan final `tukin_amount` dapat direproduksi murni dari tabel `tukin_calculations` saja tanpa melihat tabel master yang mungkin sudah berubah.

## 11. UX Audit
- Tampilan harus *Fail-Closed*. Tidak ada tombol "Edit Matriks" bagi user biasa.
- Jurnal lama tidak boleh muncul sebagai "Sedang [Aktivitas]" di Homepage. Validasi waktu hanya berlaku untuk hari `CURRENT_DATE`.

## 12. Testing Gap
- 37 Skenario *Test Case* wajib dibuat sebelum UAT (sebagaimana didaftarkan di poin X).

## 13. BUSINESS DECISION REQUIRED

Berikut adalah keputusan teknokratis/bisnis yang **WAJIB** diputuskan oleh Owner sebelum penulisan baris kode dimulai:

1. **BUSINESS DECISION #1: Definisi Teknis "1 Capaian CK.B"**
   *Situasi*: Jurnal meminta isian *Realisasi* (Kuantitas output).
   *Pertanyaan*: Jika seorang pamong mengisi 1 jurnal aktivitas menyusun dokumen, dan *realisasi* = 5 dokumen. Apakah ini dihitung **1 Capaian** (karena 1 aktivitas jurnal), ATAU **5 Capaian** (berdasarkan volume realisasi)?

2. **BUSINESS DECISION #2: Capping (Batas Maksimal) KB > 100%**
   *Situasi*: Target 40, Tercapai 50. Maka KB = 125%.
   *Pertanyaan*: Apakah dalam perhitungan NPK, nilai KB dibiarkan 125%, atau dipotong/dimaksimalisasi (*capping*) menjadi 100%?

3. **BUSINESS DECISION #3: Wewenang Approval Matriks (Review → Published)**
   *Pertanyaan*: Secara regulasi aplikasi, siapakah yang berwenang mengeklik tombol "Setujui Matriks" bagi para Pamong? Apakah Carik (selaku Admin) atau Lurah?

4. **BUSINESS DECISION #4: Pembulatan Desimal NPK (Rounding Rule)**
   *Situasi*: Interval NPK regulasi melompat (misal 80, lalu 81). 
   *Pertanyaan*: Jika nilai perhitungan NPK = 80.6, apakah dibulatkan ke bawah (80 -> 70% Tukin), dibulatkan ke atas (81 -> 90% Tukin), atau menggunakan logika lain?

## 14. Proposed Corrected Architecture
- **Penambahan Constraint DB**: 
  - `ALTER TABLE performance_journals ADD CONSTRAINT no_overlap EXCLUDE USING gist(employee_id WITH =, tsrange(start_time, end_time) WITH &&)`.
  - `ALTER TABLE attendances ADD CONSTRAINT unique_attendance UNIQUE(employee_id, attendance_date)`.
- **Penyesuaian Calculation Engine**:
  - Kolom `tukin_calculations` diperkaya dengan `pagu_snapshot` dan `disciplinary_deduction`.
- **Pengamanan DDL**: Mengubah `ON DELETE CASCADE` menjadi `ON DELETE RESTRICT` pada tabel referensi historis, dan menerapkan *Soft Delete* (`is_deleted` boolean) di posisi dan matriks.

## 15. Final Gate

**BLOCKED (DO NOT IMPLEMENT YET):**
- Logika Kalkulasi Capaian CK.B (Menunggu BD #1).
- Logika Perhitungan Akhir KB dan NPK (Menunggu BD #2 dan BD #4).
- Pembuatan fitur *Approval* Matriks (Menunggu BD #3).
- Implementasi Skema SQL (Menunggu penyempurnaan rancangan *constraint* dan *soft delete*).

**READY:**
- Infrastruktur dasar Next.js (Sudah siap).
- Pemetaan data master Kalidengen (Identitas, Jabatan, Pagu, Pamong) -> Siap *seeding*.
- Struktur Otorisasi / RLS tingkat *database* dasar (Sudah tervalidasi).

---
*Proses dihentikan di fase Audit. Tidak ada modifikasi kode yang dilakukan.*
