# Perencanaan Sistem Manajemen Kinerja & Presensi Pemerintah Kalurahan (Final V1)

Dokumen ini berisi analisis, desain arsitektur, ERD, dan peta jalan (roadmap) yang merujuk pada **BUSINESS RULES FINAL V1**.

## 1. Konsep Dasar & Sistem
- **Skala Aplikasi**: 1 aplikasi = 1 Kalurahan (Kalidengen). **Tidak multi-tenant**.
- **Configurability**: Source code dirancang agar data Kalurahan/Jabatan dapat diganti tanpa merubah logic inti. Bamuskal = OUT OF SCOPE.
- **Role & Kewenangan Substantif**: 
  - **Carik**: Satu-satunya Admin (Secara teknis mengelola data & memverifikasi).
  - **Lurah**: User biasa (Secara sistem), namun memiliki wewenang substantif sebagai evaluator yang menetapkan persetujuan (Matrix & Jurnal).
  - **Pamong**: User biasa.
  - *Role* murni untuk limitasi sistem, bukan pengganti/pencampur aduk Jabatan (*Position*).

## 2. Struktur Database & Histori
Desain menjaga agar histori pegawai (*Immutability*) tetap konsisten.

### A. Core & Authentication
- **profiles**: `id`, `role`, `full_name`.
- **positions**: `id`, `name`.
- **employees**: `id`, `profile_id`, `position_id`, `nip_nipt`, `status`.
- **village_settings**: `id`, `setting_key`, `setting_value`.

### B. Matriks Kinerja (Versioning)
- **matrix_versions**: `id`, `position_id`, `version_number`, `status` (Draft → Review → Published → Locked/Archived). *Matrix Published/Locked pantang diedit*.
- **performance_groups**: `id`, `matrix_version_id`, `name`.
- **performance_items**: `id`, `group_id`, `name`, `unit`.
- **performance_targets**: `id`, `item_id`, `annual_target`, `monthly_target`.

### C. Jurnal & Presensi (Anti-Overlap)
- **performance_journals**: `id`, `employee_id`, `item_id`, `activity_date`, `start_time`, `end_time`, `target_snapshot`, `unit_snapshot`, `realization` (input user), `capaian_value` (kalkulasi logic), `location`, `note`, `status` (Draft → Submitted → Verified → Approved → Locked).
  - *Constraint*: `EXCLUDE USING gist (employee_id WITH =, tsrange((activity_date + start_time)::timestamp, (activity_date + end_time)::timestamp) WITH &&)`.
- **journal_evidence**: `id`, `journal_id`, `file_url`.
- **attendances**: `id`, `employee_id`, `attendance_date`, `check_in`, `check_out` (`timestamptz`), `status`, `note`.
  - *Constraint*: `UNIQUE(employee_id, attendance_date)`.
- **permissions** / **official_duties**: Modul manajemen waktu.

### D. Calculation Engine & Parameter Historis
- **tukin_parameters**: `id`, `position_id`, `min_ckb_target`, `pagu_tukin`, `effective_date`.
- **tukin_calculations**: Menyimpan *FULL SNAPSHOT* untuk menjaga imutabilitas data masa lalu.
  - `employee_id`, `position_id_snapshot`, `pagu_snapshot`, `min_ckb_snapshot`, `formula_version`
  - `mk`, `hk`, `pb`, `ckb`, `tkb`, `actual_kb`, `kb` (used for NPK), `npk`, `tukin_percentage`, `disciplinary_adjustment`, `final_tukin`.

## 3. Business Rules Final V1

1. **Wewenang Evaluator (Lurah)**: Lurah bertindak sebagai pihak yang melakukan *review* substantif dan menetapkan matriks menjadi `Published`, serta mengevaluasi Jurnal Pamong menjadi `Approved`.
2. **Definisi 1 Capaian CK.B**: Berbasis capaian output, BUKAN sekadar kuantitas realisasi. (Contoh: Target 20, Realisasi 20 -> 1 Capaian. Bukan 20 Capaian).
3. **Syarat CK.B**: Hanya berasal dari jurnal yang berstatus setidaknya **Approved** oleh Lurah.
4. **Target CK.B Minimal**: Diambil dari `tukin_parameters` periode aktif (Carik=40, Kasi/Kaur=39, Dukuh=38).
5. **Penilaian KB & Capping**:
   - `KB = CK.B / TK.B × 100%`.
   - Nilai Aktual KB wajib disimpan secara terpisah di DB, terlepas dari aturan *capping* nantinya.
6. **Penilaian NPK & Kontinuitas Desimal**:
   - `NPK = (PB × 40%) + (KB × 60%)`. Tidak ada pembulatan, menggunakan relasi `>=` dan `<`.
   - `91 <= NPK` → 100%
   - `81 <= NPK < 91` → 90%
   - `71 <= NPK < 81` → 70%
   - `40 <= NPK < 71` → 40%
   - `10 <= NPK < 40` → 10%
   - `0 <= NPK < 10` → 0%
7. **Tukin Lurah**: `(Rata-rata % Tukin Pamong) × Pagu Tukin Lurah`.
   - Populasi Pamong: Semua Carik, Kasi, Kaur, Dukuh yang *eligible*. Mengeluarkan Lurah dan Bamuskal dari penyebut rata-rata.
8. **Timezone Server**: `check_in` dan `check_out` dipaksa mengambil zona waktu *Asia/Jakarta* dari server/DB. Jam lokal *browser* tidak dipercaya.
9. **Status Realtime**: 'Belum Presensi', 'Sedang di Kantor', 'Sedang [Aktivitas]' (hanya jika waktu saat ini berada persis di rentang jurnal hari berjalan), 'Sedang Melaksanakan Kegiatan di Wilayah', 'Selesai Bekerja'.

## 4. Final Unresolved Decisions (BLOCKED)
Pengembangan fitur kalkulasi Tukin harus menunggu kepastian dua klausul matematis ini, namun arsitektur DB dan kerangka *engine* harus dirancang sedemikian rupa agar dapat mengakomodasi apapun keputusannya kelak:

> [!WARNING]
> 1. **Perlakuan Capping KB > 100%**: Jika KB secara matematis > 100%, apakah limitasi nilai yang disuntikkan ke NPK dipangkas (capping = 100%), atau ditelusuri apa adanya.
> 2. **Capaian Parsial Output**: Apabila target 20, namun direalisasikan 10: Apakah diganjar 0 capaian, 0.5 capaian (proporsional), atau 1 capaian?

## 5. Development Roadmap (Actionable)
- **Tahap 1**: Eksekusi Revisi DB Schema Migrations (Penerapan *GiST*, Pemisahan *Snapshot Calculation*, Penambahan *Approval* Flow).
- **Tahap 2**: Backend API & Penguatan RLS berbasis *Role* Administratif (Carik) vs *Wewenang Evaluatif* (Lurah).
- **Tahap 3**: Modul Presensi & Homepage Realtime Status (Terikat zona waktu server).
- **Tahap 4**: Modul Matriks & Jurnal Kinerja (Input realisasi murni tanpa manipulasi *capaian*).
- **Tahap 5**: Modul Hitung NPK dan Tukin (Sembari menunggu Unresolved Decisions A & B).
- **Tahap 6**: Dasbor Tukin Lurah & Dashboard Pamong.
