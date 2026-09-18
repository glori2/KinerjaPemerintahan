import './globals.css';
import AuthProvider from '@/components/AuthProvider';

export const metadata = {
  title: 'Sistem Manajemen Kinerja & Presensi',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="id">
      <body className="antialiased text-gray-900 bg-gray-50">
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
