'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';

export default function KalkulasiAdmin() {
  const { profile, assignment } = useAuth();
  const [periods, setPeriods] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [processingId, setProcessingId] = useState<string | null>(null);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const isCarik = profile?.role === 'admin' && assignment?.position?.name === 'Carik';

  useEffect(() => {
    if (isCarik) fetchPeriods();
    else setLoading(false);
  }, [isCarik]);

  const fetchPeriods = async () => {
    try {
      const { data, error } = await supabase
        .from('tukin_periods')
        .select('*, tukin_calculations(count)')
        .order('period_month', { ascending: false });
      if (error) throw error;
      setPeriods(data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleGenerate = async (periodId: string) => {
    if (!confirm('Yakin men-generate kalkulasi Tukin untuk periode ini? Tindakan ini tidak dapat dibatalkan jika periode telah terkunci.')) return;
    
    setProcessingId(periodId);
    setError('');
    setSuccess('');
    
    try {
      const { data, error } = await supabase.rpc('generate_calculations', {
        p_period_id: periodId
      });
      if (error) throw error;
      setSuccess(`Berhasil memproses ${data.total_calculated} data kalkulasi.`);
      await fetchPeriods();
    } catch (err: any) {
      setError(err.message || 'Gagal memproses kalkulasi Tukin.');
    } finally {
      setProcessingId(null);
    }
  };

  if (!isCarik && !loading) {
    return (
      <AppShell>
        <div className="bg-red-50 p-6 rounded-lg text-red-700">Akses ditolak. Modul Admin hanya untuk Carik.</div>
      </AppShell>
    );
  }

  return (
    <AppShell>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Manajemen Kalkulasi Tunjangan Kinerja</h1>
      </div>

      {error && <div className="mb-4 p-4 bg-red-50 text-red-700 rounded-md border border-red-200">{error}</div>}
      {success && <div className="mb-4 p-4 bg-green-50 text-green-700 rounded-md border border-green-200">{success}</div>}

      {loading ? (
        <div className="animate-pulse bg-white p-6 h-64 rounded-lg border"></div>
      ) : (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Periode</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Data Terkalkulasi</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {periods.map(p => (
                <tr key={p.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{p.period_month}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 rounded-full text-xs font-semibold ${p.status === 'Locked' ? 'bg-gray-200 text-gray-800' : 'bg-blue-100 text-blue-800'}`}>
                      {p.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {p.tukin_calculations?.[0]?.count || 0} Pegawai
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm">
                    {p.status === 'Locked' ? (
                      <span className="text-gray-400 font-medium">Terkunci</span>
                    ) : (
                      <button 
                        onClick={() => handleGenerate(p.id)} 
                        disabled={processingId === p.id}
                        className="text-white bg-indigo-600 hover:bg-indigo-700 px-3 py-1.5 rounded-md font-medium disabled:opacity-50"
                      >
                        {processingId === p.id ? 'Memproses...' : 'Generate Tukin'}
                      </button>
                    )}
                  </td>
                </tr>
              ))}
              {periods.length === 0 && (
                <tr><td colSpan={4} className="px-6 py-8 text-center text-gray-500">Belum ada data periode.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </AppShell>
  );
}
