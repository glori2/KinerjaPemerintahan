'use client';

import React, { useState } from 'react';
import { useAuth } from './AuthProvider';
import { useRouter, usePathname } from 'next/navigation';

export default function AppShell({ children }: { children: React.ReactNode }) {
  const { user, profile, assignment, loading, signOut } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const router = useRouter();
  const pathname = usePathname();

  if (loading) {
    return <div className="min-h-screen flex items-center justify-center bg-gray-50"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div></div>;
  }

  if (!user) {
    router.push('/login');
    return null;
  }

  const role = profile?.role || 'user';
  const positionName = assignment?.position?.name || '';
  const isCarik = role === 'admin' && positionName === 'Carik';
  const isLurah = role === 'user' && positionName === 'Lurah';

  const menuItems = [
    { name: 'Dashboard', path: '/dashboard', show: true },
    { name: 'Presensi', path: '/presensi', show: true },
    { name: 'Jurnal', path: '/jurnal', show: !isLurah },
    { name: 'Tukin', path: '/tukin', show: true },
    { name: 'Evaluasi', path: '/evaluasi', show: isLurah },
    { name: 'Pegawai', path: '/admin/pegawai', show: isCarik },
    { name: 'Matriks', path: '/admin/matriks', show: isCarik },
    { name: 'Kalkulasi', path: '/admin/kalkulasi', show: isCarik },
    { name: 'Audit', path: '/admin/audit', show: isCarik },
  ];

  return (
    <div className="min-h-screen flex bg-gray-50">
      {/* Sidebar Desktop */}
      <aside className="hidden md:flex flex-col w-64 bg-white border-r">
        <div className="h-16 flex items-center px-6 border-b font-bold text-xl text-indigo-600">
          Presensi Tukin
        </div>
        <nav className="flex-1 overflow-y-auto py-4">
          <ul className="space-y-1 px-3">
            {menuItems.filter(m => m.show).map((item) => (
              <li key={item.path}>
                <a
                  href={item.path}
                  className={`block px-3 py-2 rounded-md text-sm font-medium ${pathname.startsWith(item.path) ? 'bg-indigo-50 text-indigo-700' : 'text-gray-700 hover:bg-gray-100'}`}
                >
                  {item.name}
                </a>
              </li>
            ))}
          </ul>
        </nav>
      </aside>

      {/* Mobile Sidebar Overlay */}
      {sidebarOpen && (
        <div className="fixed inset-0 z-40 flex md:hidden">
          <div className="fixed inset-0 bg-gray-600 bg-opacity-75" onClick={() => setSidebarOpen(false)}></div>
          <aside className="relative flex-1 flex flex-col max-w-xs w-full bg-white">
            <div className="h-16 flex items-center px-6 border-b font-bold text-xl text-indigo-600">
              Presensi Tukin
            </div>
            <nav className="flex-1 overflow-y-auto py-4">
              <ul className="space-y-1 px-3">
                {menuItems.filter(m => m.show).map((item) => (
                  <li key={item.path}>
                    <a
                      href={item.path}
                      onClick={() => setSidebarOpen(false)}
                      className={`block px-3 py-2 rounded-md text-sm font-medium ${pathname.startsWith(item.path) ? 'bg-indigo-50 text-indigo-700' : 'text-gray-700 hover:bg-gray-100'}`}
                    >
                      {item.name}
                    </a>
                  </li>
                ))}
              </ul>
            </nav>
          </aside>
        </div>
      )}

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Topbar */}
        <header className="h-16 flex items-center justify-between px-4 sm:px-6 lg:px-8 bg-white border-b">
          <button className="md:hidden p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500" onClick={() => setSidebarOpen(true)}>
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          
          <div className="flex items-center space-x-4 ml-auto">
            <div className="text-right hidden sm:block">
              <div className="text-sm font-medium text-gray-900">{profile?.full_name || user.email}</div>
              <div className="text-xs text-gray-500 flex items-center justify-end space-x-2">
                <span>{positionName}</span>
                <span className="bg-indigo-100 text-indigo-800 text-[10px] px-1.5 py-0.5 rounded-full font-semibold uppercase">{role}</span>
              </div>
            </div>
            <button
              onClick={signOut}
              className="text-sm text-red-600 font-medium hover:text-red-900"
            >
              Logout
            </button>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-y-auto bg-gray-50 p-4 sm:p-6 lg:p-8">
          {children}
        </main>
      </div>
    </div>
  );
}
