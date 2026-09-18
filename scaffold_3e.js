import fs from 'fs';
import path from 'path';

const srcDir = path.join(process.cwd(), 'src');

const pegawaiPage = `
'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';

export default function AdminPegawai() {
  const { profile, assignment } = useAuth();
  const [employees, setEmployees] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const isCarik = profile?.role === 'admin' && assignment?.position?.name === 'Carik';

  useEffect(() => {
    if (isCarik) fetchEmployees();
    else setLoading(false);
  }, [isCarik]);

  const fetchEmployees = async () => {
    try {
      const { data, error } = await supabase
        .from('employees')
        .select('*, profiles(full_name, role, status), employee_position_assignments(status, positions(name))')
        .eq('employee_position_assignments.status', 'active');
      if (error) throw error;
      setEmployees(data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

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
                    {e.employee_position_assignments?.find((a:any) => a.status === 'active')?.positions?.name || '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">{e.profiles?.role}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={\`inline-flex px-2 py-1 rounded-full text-xs font-semibold \${e.profiles?.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}\`}>
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
`;

const matriksPage = `
'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';

export default function AdminMatriks() {
  const { profile, assignment } = useAuth();
  const [matrices, setMatrices] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const isCarik = profile?.role === 'admin' && assignment?.position?.name === 'Carik';

  useEffect(() => {
    if (isCarik) fetchMatrices();
    else setLoading(false);
  }, [isCarik]);

  const fetchMatrices = async () => {
    try {
      const { data, error } = await supabase
        .from('matrix_versions')
        .select('*, positions(name), performance_groups(count)')
        .order('created_at', { ascending: false });
      if (error) throw error;
      setMatrices(data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handlePublish = async (matrixId: string) => {
    setError('');
    try {
      const { error } = await supabase.rpc('publish_matrix_version', {
        p_matrix_version_id: matrixId
      });
      if (error) throw error;
      await fetchMatrices();
    } catch (err: any) {
      setError(err.message || 'Gagal publish matriks.');
    }
  };

  if (!isCarik && !loading) return <AppShell><div className="bg-red-50 p-6 rounded-lg text-red-700">Akses ditolak.</div></AppShell>;

  return (
    <AppShell>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Matriks Kinerja</h1>
        <p className="text-gray-500">Manajemen versi matriks penilaian kinerja</p>
      </div>

      {error && <div className="mb-4 p-3 bg-red-50 text-red-700 rounded text-sm">{error}</div>}

      {loading ? (
        <div className="animate-pulse bg-white rounded-lg h-64 border"></div>
      ) : (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Jabatan</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Versi</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Masa Berlaku</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Grup</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {matrices.map(m => (
                <tr key={m.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{m.positions?.name || '-'}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">V{m.version_number}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={\`inline-flex px-2 py-1 rounded-full text-xs font-semibold \${m.status === 'Published' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}\`}>
                      {m.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                    {m.effective_from || '-'} s/d {m.effective_to || 'Seterusnya'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                    {m.performance_groups?.[0]?.count || 0} Grup
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm">
                    {m.status === 'Draft' && (
                      <button onClick={() => handlePublish(m.id)} className="text-indigo-600 hover:text-indigo-900 font-medium">
                        Publish
                      </button>
                    )}
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
`;

const auditPage = `
'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';

export default function AdminAudit() {
  const { profile, assignment } = useAuth();
  const [logs, setLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  // Filters
  const [actionFilter, setActionFilter] = useState('');
  const [entityFilter, setEntityFilter] = useState('');

  const isCarik = profile?.role === 'admin' && assignment?.position?.name === 'Carik';

  useEffect(() => {
    if (isCarik) fetchLogs();
    else setLoading(false);
  }, [isCarik, actionFilter, entityFilter]);

  const fetchLogs = async () => {
    try {
      setLoading(true);
      let query = supabase
        .from('audit_logs')
        .select('*, profiles(full_name)')
        .order('created_at', { ascending: false })
        .limit(100);
        
      if (actionFilter) query = query.eq('action', actionFilter);
      if (entityFilter) query = query.eq('entity_type', entityFilter);
      
      const { data, error } = await query;
      if (error) throw error;
      setLogs(data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  if (!isCarik && !loading) return <AppShell><div className="bg-red-50 p-6 rounded-lg text-red-700">Akses ditolak.</div></AppShell>;

  return (
    <AppShell>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Log Audit Sistem</h1>
        <p className="text-gray-500">Jejak aktivitas dan perubahan data (Read-Only)</p>
      </div>
      
      <div className="mb-4 flex gap-4 bg-white p-4 rounded-lg shadow-sm border border-gray-200">
        <div>
          <label className="block text-xs font-medium text-gray-700 mb-1">Aksi</label>
          <select value={actionFilter} onChange={(e) => setActionFilter(e.target.value)} className="border rounded p-1 text-sm min-w-[150px]">
            <option value="">Semua Aksi</option>
            <option value="INSERT">INSERT</option>
            <option value="UPDATE">UPDATE</option>
            <option value="DELETE">DELETE</option>
          </select>
        </div>
        <div>
          <label className="block text-xs font-medium text-gray-700 mb-1">Entitas</label>
          <select value={entityFilter} onChange={(e) => setEntityFilter(e.target.value)} className="border rounded p-1 text-sm min-w-[150px]">
            <option value="">Semua Entitas</option>
            <option value="performance_journals">Jurnal Kinerja</option>
            <option value="tukin_calculations">Kalkulasi Tukin</option>
            <option value="tukin_periods">Periode Tukin</option>
            <option value="attendances">Presensi</option>
          </select>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Waktu</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Aktor</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Aksi</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Entitas</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID Entitas</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {logs.map(log => (
              <tr key={log.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap text-xs text-gray-500">{new Date(log.created_at).toLocaleString('id-ID')}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-medium">
                  {log.actor_type === 'SYSTEM' ? 'Sistem' : log.profiles?.full_name || 'Unknown'}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={\`inline-flex px-2 py-1 rounded text-xs font-bold \${
                    log.action === 'INSERT' ? 'text-green-700 bg-green-50' : 
                    log.action === 'UPDATE' ? 'text-blue-700 bg-blue-50' : 
                    'text-red-700 bg-red-50'
                  }\`}>{log.action}</span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">{log.entity_type}</td>
                <td className="px-6 py-4 whitespace-nowrap text-xs text-gray-500 truncate max-w-xs">{log.entity_id}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AppShell>
  );
}
`;

fs.mkdirSync(path.join(srcDir, 'app/admin/pegawai'), { recursive: true });
fs.mkdirSync(path.join(srcDir, 'app/admin/matriks'), { recursive: true });
fs.mkdirSync(path.join(srcDir, 'app/admin/audit'), { recursive: true });

fs.writeFileSync(path.join(srcDir, 'app/admin/pegawai/page.tsx'), pegawaiPage.trim() + '\\n', 'utf8');
fs.writeFileSync(path.join(srcDir, 'app/admin/matriks/page.tsx'), matriksPage.trim() + '\\n', 'utf8');
fs.writeFileSync(path.join(srcDir, 'app/admin/audit/page.tsx'), auditPage.trim() + '\\n', 'utf8');

console.log('Phase 3E routes scaffolded.');
