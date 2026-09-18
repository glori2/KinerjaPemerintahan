'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';
import { Employee, EmployeeAssignment } from '@/types';

export default function AdminPegawai() {
  const { profile, assignment } = useAuth();
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);

  const isCarik = profile?.role === 'admin' && assignment?.position?.name === 'Carik';

  useEffect(() => {
    const fetchEmployees = async () => {
      try {
        setLoading(true);
        const { data, error } = await supabase
          .from('employees')
          .select('*, profiles(full_name, role, status), employee_position_assignments(status, positions(name))')
          .eq('employee_position_assignments.status', 'active');
        if (error) throw error;
        setEmployees((data as unknown as Employee[]) || []);
      } catch (err: unknown) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    if (isCarik) fetchEmployees();
    else setLoading(false);
  }, [isCarik]);

  if (!isCarik && !loading) return <AppShell><div className="bg-red-50 p-6 rounded-lg text-red-700">Akses ditolak. Halaman ini hanya untuk Carik.</div></AppShell>;

  return (
    <AppShell>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Direktori Pegawai</h1>
        <p className="text-gray-500">Daftar Pamong dan Staf Kalurahan (Read-Only)</p>
      </div>

      {loading ? (
        <div className="animate-pulse bg-white rounded-lg h-64 border"></div>
      ) : (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nama Lengkap</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Jabatan Aktif</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role Sistem</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status Profil</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {employees.map(e => (
                <tr key={e.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{e.profiles?.full_name}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                    {e.employee_position_assignments?.find((a: EmployeeAssignment) => a.status === 'active')?.positions?.name || '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">{e.profiles?.role}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 rounded-full text-xs font-semibold ${e.profiles?.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                      {e.profiles?.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </AppShell>
  );
}
