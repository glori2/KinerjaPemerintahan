# Sistem Manajemen Kinerja & Presensi Pemerintah Kalurahan

Aplikasi web untuk manajemen kinerja dan presensi pamong kalurahan, dirancang khusus untuk Kalurahan Kalidengen (namun bersifat *configurable*).

## Stack Teknologi
- **Framework**: Next.js (App Router)
- **Bahasa**: TypeScript
- **Styling**: Tailwind CSS
- **Database & Auth**: Supabase
- **Deployment**: Vercel

## Cara Menjalankan di Local
1. Salin `.env.example` menjadi `.env.local`
2. Isi nilai kredensial Supabase Anda di `.env.local`
3. Install dependencies: `npm install`
4. Jalankan server: `npm run dev`
5. Buka [http://localhost:3000](http://localhost:3000)

## Struktur Folder
- `src/app` - Routing & Pages
- `src/components` - Reusable UI Components
- `src/lib/supabase` - Konfigurasi Supabase Client
- `src/lib/auth` - Logic otentikasi
- `src/lib/calculation` - Engine perhitungan Tukin & CK.B
- `src/services` - Business logic & Data fetching
