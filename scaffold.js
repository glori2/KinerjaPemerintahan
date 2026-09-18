const fs = require('fs');
const path = require('path');

const srcDir = path.join(__dirname, 'src');

const files = {
  'lib/supabase.ts': `
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
`,
  'components/AuthProvider.tsx': `
'use client';

import React, { createContext, useContext, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import { useRouter } from 'next/navigation';

interface AuthContextType {
  user: any;
  profile: any;
  assignment: any;
  employee: any;
  loading: boolean;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  profile: null,
  assignment: null,
  employee: null,
  loading: true,
  signOut: async () => {},
});

export const useAuth = () => useContext(AuthContext);

export default function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<any>(null);
  const [profile, setProfile] = useState<any>(null);
  const [assignment, setAssignment] = useState<any>(null);
  const [employee, setEmployee] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const fetchSession = async () => {
      const { data: { session } } = await supabase.auth.getSession();
      if (session?.user) {
        await loadUserData(session.user);
      } else {
        setLoading(false);
      }
    };

    fetchSession();

    const { data: authListener } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (session?.user) {
        await loadUserData(session.user);
      } else {
        setUser(null);
        setProfile(null);
        setAssignment(null);
        setEmployee(null);
        setLoading(false);
        router.push('/login');
      }
    });

    return () => {
      authListener.subscription.unsubscribe();
    };
  }, []);

  const loadUserData = async (authUser: any) => {
    setUser(authUser);
    try {
      // Fetch profile
      const { data: prof } = await supabase.from('profiles').select('*').eq('id', authUser.id).single();
      setProfile(prof);

      // Fetch employee
      const { data: emp } = await supabase.from('employees').select('*').eq('profile_id', authUser.id).single();
      setEmployee(emp);

      if (emp) {
        // Fetch active assignment
        const { data: assign } = await supabase
          .from('employee_position_assignments')
          .select('*, position:positions(name, is_pamong_tukin_eligible)')
          .eq('employee_id', emp.id)
          .eq('status', 'active')
          .single();
        setAssignment(assign);
      }
    } catch (err) {
      console.error('Error loading user data:', err);
    } finally {
      setLoading(false);
    }
  };

  const signOut = async () => {
    await supabase.auth.signOut();
  };

  return (
    <AuthContext.Provider value={{ user, profile, assignment, employee, loading, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}
`,
  'components/AppShell.tsx': `
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
                  className={\`block px-3 py-2 rounded-md text-sm font-medium \${pathname.startsWith(item.path) ? 'bg-indigo-50 text-indigo-700' : 'text-gray-700 hover:bg-gray-100'}\`}
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
                      className={\`block px-3 py-2 rounded-md text-sm font-medium \${pathname.startsWith(item.path) ? 'bg-indigo-50 text-indigo-700' : 'text-gray-700 hover:bg-gray-100'}\`}
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
`,
  'app/layout.tsx': `
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
`,
  'app/login/page.tsx': `
'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/components/AuthProvider';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const router = useRouter();
  const { user } = useAuth();

  useEffect(() => {
    if (user) router.push('/dashboard');
  }, [user, router]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        if (error.message.includes('Invalid login credentials')) {
          setError('Email atau password tidak valid.');
        } else if (error.message.includes('Failed to fetch')) {
          setError('Koneksi ke server terputus. Silakan coba lagi.');
        } else {
          setError(error.message);
        }
      } else {
        router.push('/dashboard');
      }
    } catch (err: any) {
      setError('Terjadi kesalahan yang tidak terduga.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8 bg-white p-8 rounded-xl shadow-lg">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Login
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Sistem Kinerja & Presensi
          </p>
        </div>
        <form className="mt-8 space-y-6" onSubmit={handleLogin}>
          {error && (
            <div className="bg-red-50 text-red-700 p-3 rounded text-sm text-center">
              {error}
            </div>
          )}
          <div className="rounded-md shadow-sm -space-y-px">
            <div>
              <label-[sr-only]>Email</label-[sr-only]>
              <input
                type="email"
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="Email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
            <div className="relative">
              <label-[sr-only]>Password</label-[sr-only]>
              <input
                type={showPassword ? 'text' : 'password'}
                required
                className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
              <button
                type="button"
                className="absolute inset-y-0 right-0 pr-3 flex items-center text-sm leading-5 text-gray-500 hover:text-gray-700"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? 'Sembunyikan' : 'Tampilkan'}
              </button>
            </div>
          </div>

          <div>
            <button
              type="submit"
              disabled={loading}
              className="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
            >
              {loading ? 'Memproses...' : 'Sign in'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
`.replace(/label-\[sr-only\]/g, 'label className="sr-only"'),
  'app/dashboard/page.tsx': `
'use client';

import AppShell from '@/components/AppShell';
import { useAuth } from '@/components/AuthProvider';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

export default function DashboardPage() {
  const { profile, assignment, employee } = useAuth();
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const role = profile?.role || 'user';
  const positionName = assignment?.position?.name || '';
  const isCarik = role === 'admin' && positionName === 'Carik';
  const isLurah = role === 'user' && positionName === 'Lurah';

  useEffect(() => {
    if (employee) fetchDashboardData();
  }, [employee]);

  const fetchDashboardData = async () => {
    setLoading(true);
    try {
      const today = new Date().toISOString().split('T')[0];
      
      // Fetch today's attendance for the user
      const { data: todayAtt } = await supabase
        .from('attendance_records')
        .select('*')
        .eq('employee_id', employee.id)
        .eq('date', today)
        .single();
        
      let pendingEval = 0;
      if (isLurah) {
        const { count } = await supabase
          .from('performance_journals')
          .select('*', { count: 'exact', head: true })
          .eq('status', 'Submitted');
        pendingEval = count || 0;
      }

      setStats({
        todayAttendance: todayAtt,
        pendingEvaluations: pendingEval
      });
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const renderContent = () => {
    if (loading) {
      return <div className="animate-pulse bg-white p-6 rounded-lg shadow-sm h-32"></div>;
    }

    if (isCarik) {
      return (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
            <h3 className="text-sm font-medium text-gray-500">Status Administrasi</h3>
            <p className="mt-2 text-3xl font-semibold text-gray-900">Aktif</p>
          </div>
        </div>
      );
    }

    if (isLurah) {
      return (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
            <h3 className="text-sm font-medium text-gray-500">Antrean Evaluasi</h3>
            <p className="mt-2 text-3xl font-semibold text-indigo-600">{stats?.pendingEvaluations || 0}</p>
            <p className="text-sm text-gray-500 mt-1">Jurnal menunggu persetujuan</p>
          </div>
        </div>
      );
    }

    // Default Pamong
    return (
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
          <h3 className="text-sm font-medium text-gray-500">Presensi Hari Ini</h3>
          <p className="mt-2 text-xl font-semibold text-gray-900">
            {stats?.todayAttendance ? (
              <span className="text-green-600">Hadir ({stats.todayAttendance.check_in_time.substring(0,5)})</span>
            ) : (
              <span className="text-gray-400">Belum Check-In</span>
            )}
          </p>
        </div>
      </div>
    );
  };

  return (
    <AppShell>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Selamat datang, {profile?.full_name}</h1>
          <p className="text-gray-500">
            {new Date().toLocaleDateString('id-ID', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
          </p>
        </div>
        
        {renderContent()}
      </div>
    </AppShell>
  );
}
`,
  'app/presensi/page.tsx': `
'use client';

import AppShell from '@/components/AppShell';
import { useAuth } from '@/components/AuthProvider';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

export default function PresensiPage() {
  const { employee } = useAuth();
  const [loading, setLoading] = useState(true);
  const [todayRecord, setTodayRecord] = useState<any>(null);
  const [history, setHistory] = useState<any[]>([]);
  const [actionLoading, setActionLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  useEffect(() => {
    if (employee) fetchData();
  }, [employee]);

  const fetchData = async () => {
    setLoading(true);
    try {
      const today = new Date().toISOString().split('T')[0];
      
      const { data: todayAtt } = await supabase
        .from('attendance_records')
        .select('*')
        .eq('employee_id', employee.id)
        .eq('date', today)
        .single();
        
      setTodayRecord(todayAtt);

      const d = new Date();
      const firstDay = new Date(d.getFullYear(), d.getMonth(), 1).toISOString().split('T')[0];
      
      const { data: hist } = await supabase
        .from('attendance_records')
        .select('*')
        .eq('employee_id', employee.id)
        .gte('date', firstDay)
        .order('date', { ascending: false });

      setHistory(hist || []);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const handleCheckIn = async () => {
    setActionLoading(true);
    setErrorMsg('');
    try {
      const today = new Date().toISOString().split('T')[0];
      const now = new Date().toTimeString().split(' ')[0]; // HH:MM:SS
      
      const { error } = await supabase
        .from('attendance_records')
        .insert({
          employee_id: employee.id,
          date: today,
          check_in_time: now,
          status: 'present',
        });
        
      if (error) throw error;
      await fetchData();
    } catch (err: any) {
      setErrorMsg(err.message.includes('duplicate') ? 'Anda sudah melakukan check-in hari ini.' : 'Gagal check-in. Coba lagi.');
    } finally {
      setActionLoading(false);
    }
  };

  const handleCheckOut = async () => {
    if (!todayRecord?.id) return;
    setActionLoading(true);
    setErrorMsg('');
    try {
      const now = new Date().toTimeString().split(' ')[0];
      
      const { error } = await supabase
        .from('attendance_records')
        .update({ check_out_time: now })
        .eq('id', todayRecord.id);
        
      if (error) throw error;
      await fetchData();
    } catch (err: any) {
      setErrorMsg('Gagal check-out. Coba lagi.');
    } finally {
      setActionLoading(false);
    }
  };

  return (
    <AppShell>
      <div className="max-w-4xl mx-auto space-y-6">
        <h1 className="text-2xl font-bold text-gray-900">Presensi</h1>
        
        {errorMsg && (
          <div className="p-4 bg-red-50 text-red-700 rounded-md">
            {errorMsg}
          </div>
        )}

        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Hari Ini</h2>
          {loading ? (
            <div className="animate-pulse h-12 bg-gray-100 rounded"></div>
          ) : (
            <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
              <div className="flex-1">
                <p className="text-gray-500">Status: {todayRecord ? <span className="text-green-600 font-semibold uppercase">{todayRecord.status}</span> : 'Belum Check-In'}</p>
                {todayRecord && (
                  <p className="text-sm text-gray-500 mt-1">
                    Check-in: {todayRecord.check_in_time?.substring(0,5)} | 
                    Check-out: {todayRecord.check_out_time?.substring(0,5) || '-'}
                  </p>
                )}
              </div>
              <div className="flex gap-3 w-full sm:w-auto">
                {!todayRecord ? (
                  <button
                    onClick={handleCheckIn}
                    disabled={actionLoading}
                    className="flex-1 sm:flex-none px-6 py-3 bg-indigo-600 text-white rounded-md font-medium hover:bg-indigo-700 disabled:opacity-50 min-w-[120px]"
                  >
                    Check In
                  </button>
                ) : !todayRecord.check_out_time ? (
                  <button
                    onClick={handleCheckOut}
                    disabled={actionLoading}
                    className="flex-1 sm:flex-none px-6 py-3 bg-orange-500 text-white rounded-md font-medium hover:bg-orange-600 disabled:opacity-50 min-w-[120px]"
                  >
                    Check Out
                  </button>
                ) : (
                  <span className="px-6 py-3 bg-gray-100 text-gray-500 rounded-md font-medium">Selesai</span>
                )}
              </div>
            </div>
          )}
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden">
          <div className="px-6 py-4 border-b">
            <h2 className="text-lg font-semibold text-gray-900">Riwayat Bulan Ini</h2>
          </div>
          {loading ? (
            <div className="p-6 text-center text-gray-500">Memuat data...</div>
          ) : history.length === 0 ? (
            <div className="p-6 text-center text-gray-500">Tidak ada riwayat presensi bulan ini.</div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tanggal</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Check In</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Check Out</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {history.map((record) => (
                    <tr key={record.id}>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{record.date}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800 uppercase">
                          {record.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{record.check_in_time?.substring(0,5) || '-'}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{record.check_out_time?.substring(0,5) || '-'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </AppShell>
  );
}
`
};

for (const [relPath, content] of Object.entries(files)) {
  const fullPath = path.join(srcDir, relPath);
  fs.mkdirSync(path.dirname(fullPath), { recursive: true });
  fs.writeFileSync(fullPath, content.trim() + '\n', 'utf8');
}
console.log('Files generated successfully.');
