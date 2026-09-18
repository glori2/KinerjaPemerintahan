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
                    <span className={`inline-flex px-2 py-1 rounded-full text-xs font-semibold ${m.status === 'Published' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}`}>
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
