'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';
import { Employee, EmployeeAssignment } from '@/types';

function formatPositionDisplay(fullName?: string, positionName?: string): string {
  if (!positionName) return '-';
  if (positionName === 'Panata Laksana Sarta Pangripta') return 'Panata Laksana Sarta Pangripta (PALAPA)';
  if (positionName === 'Dukuh') {
    if (fullName?.includes('Widi')) return 'Dukuh Kalidengen I';
    if (fullName?.includes('Rendi')) return 'Dukuh Kalidengen II';
    if (fullName?.includes('Edi')) return 'Dukuh Sidatan';
  }
  return positionName;
}

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
          .select(`
            id,
            nip_nipt,
            profiles(
              id,
              full_name,
              role
            ),
            employee_position_assignments(
              id,
              status,
              effective_from,
              effective_to,
              positions(
                id,
                name
              )
            )
          `)
          .order('created_at', { ascending: true });

        if (error) throw error;
        setEmployees((data as unknown as Employee[]) || []);
      } catch (err: unknown) {
        if (process.env.NODE_ENV === 'development') {
          console.error('[AdminPegawai] Fetch error:', err);
        }
      } finally {
        setLoading(false);
      }
    };

    if (isCarik) fetchEmployees();
    else setLoading(false);
  }, [isCarik]);

  if (!isCarik && !loading) return <AppShell><div className="bg-red-50 p-6 rounded-lg text-red-700">Akses ditolak. Halaman ini hanya untuk Carik.</div></AppShell>;

  // Exclude Bamuskal if any
  const filteredEmployees = employees.filter(e => {
    const posName = e.employee_position_assignments?.find((a: EmployeeAssignment) => a.status === 'active')?.positions?.name;
    return !posName?.toLowerCase().includes('bamuskal');
  });

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
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">No</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nama Lengkap</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Jabatan Aktif</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role Sistem</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status Penugasan</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {filteredEmployees.map((e, idx) => {
                const activeAssignment = e.employee_position_assignments?.find((a: EmployeeAssignment) => a.status === 'active');
                const rawPosName = activeAssignment?.positions?.name;
                const displayPos = formatPositionDisplay(e.profiles?.full_name, rawPosName);

                return (
                  <tr key={e.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{idx + 1}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{e.profiles?.full_name}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">{displayPos}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                      <span className={`inline-flex px-2 py-0.5 rounded text-xs font-medium ${e.profiles?.role === 'admin' ? 'bg-purple-100 text-purple-800' : 'bg-gray-100 text-gray-800'}`}>
                        {e.profiles?.role}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 rounded-full text-xs font-semibold ${activeAssignment?.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}`}>
                        {activeAssignment?.status === 'active' ? 'Aktif' : (activeAssignment?.status || 'Nonaktif')}
                      </span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </AppShell>
  );
}
