'use client';
import { useCallback, useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';
import { TukinPeriod } from '@/types';

interface PeriodWithCount extends TukinPeriod {
  tukin_calculations?: { count: number }[];
}

export default function KalkulasiAdmin() {
  const { profile, assignment } = useAuth();
  const [periods, setPeriods] = useState<PeriodWithCount[]>([]);
  const [loading, setLoading] = useState(true);
  const [processingId, setProcessingId] = useState<string | null>(null);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // Modal states
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [newPeriodMonth, setNewPeriodMonth] = useState<number>(new Date().getMonth());
  const [newPeriodYear, setNewPeriodYear] = useState<number>(new Date().getFullYear());
  const [isCreating, setIsCreating] = useState(false);

  const isCarik = profile?.role === 'admin' && assignment?.position?.name === 'Carik';

  const fetchPeriods = useCallback(async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('tukin_periods')
        .select('*, tukin_calculations(count)')
        .order('period_month', { ascending: false });
      if (error) throw error;
      setPeriods((data as unknown as PeriodWithCount[]) || []);
    } catch (err: unknown) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (isCarik) fetchPeriods();
    else setLoading(false);
  }, [isCarik, fetchPeriods]);

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
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Gagal memproses kalkulasi Tukin.');
    } finally {
      setProcessingId(null);
    }
  };

  const handleCreatePeriod = async () => {
    const formattedMonth = `${newPeriodYear}-${String(newPeriodMonth + 1).padStart(2, '0')}-01`;
    setIsCreating(true);
    setError('');
    setSuccess('');
    
    try {
      const { error: rpcError } = await supabase.rpc('create_tukin_period', {
        p_period_month: formattedMonth
      });
      
      if (rpcError) {
        if (rpcError.message.includes('sudah tersedia') || rpcError.code === '23505') {
            throw new Error('Periode tersebut sudah tersedia.');
        } else if (rpcError.message.includes('hak untuk membuat')) {
            throw new Error('Anda tidak memiliki hak untuk membuat periode.');
        } else if (rpcError.message.includes('awal bulan')) {
            throw new Error('Periode harus menggunakan awal bulan.');
        }
        throw new Error(rpcError.message || 'Gagal membuat periode.');
      }
      
      setSuccess('Periode berhasil dibuat.');
      setIsModalOpen(false);
      await fetchPeriods();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Gagal membuat periode.');
    } finally {
      setIsCreating(false);
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
      <div className="mb-6 flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Manajemen Kalkulasi Tunjangan Kinerja</h1>
        <button
          onClick={() => setIsModalOpen(true)}
          className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md font-medium text-sm"
        >
          + Buat Periode
        </button>
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

      {isModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl w-full max-w-md overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-bold text-gray-900">Buat Periode Baru</h2>
            </div>
            <div className="p-6">
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">Bulan</label>
                <select
                  value={newPeriodMonth}
                  onChange={(e) => setNewPeriodMonth(Number(e.target.value))}
                  className="w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
                >
                  {Array.from({ length: 12 }, (_, i) => (
                    <option key={i} value={i}>
                      {new Date(2000, i, 1).toLocaleString('id-ID', { month: 'long' })}
                    </option>
                  ))}
                </select>
              </div>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">Tahun</label>
                <input
                  type="number"
                  value={newPeriodYear}
                  onChange={(e) => setNewPeriodYear(Number(e.target.value))}
                  className="w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
                  min={2026}
                  max={2030}
                />
              </div>
            </div>
            <div className="px-6 py-4 bg-gray-50 flex justify-end gap-3">
              <button
                onClick={() => setIsModalOpen(false)}
                disabled={isCreating}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
              >
                Batal
              </button>
              <button
                onClick={handleCreatePeriod}
                disabled={isCreating}
                className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-md hover:bg-indigo-700 disabled:opacity-50"
              >
                {isCreating ? 'Membuat...' : 'Buat Periode'}
              </button>
            </div>
          </div>
        </div>
      )}
    </AppShell>
  );
}
