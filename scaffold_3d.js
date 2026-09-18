import fs from 'fs';
import path from 'path';

const srcDir = path.join(process.cwd(), 'src');

const userTukinPage = `
'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';

export default function TukinPage() {
  const { employee, profile, assignment } = useAuth();
  const [calculations, setCalculations] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (employee) fetchCalculations();
  }, [employee]);

  const fetchCalculations = async () => {
    try {
      // Get all calculations for the logged-in employee
      const { data, error } = await supabase
        .from('tukin_calculations')
        .select('*, tukin_periods(*), tukin_calculation_components(source_percentage_snapshot, employees(profiles(full_name)))')
        .eq('employee_id', employee.id)
        .order('created_at', { ascending: false });
        
      if (error) throw error;
      setCalculations(data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (val: number) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR' }).format(val);
  };

  if (loading) return <AppShell><div className="animate-pulse bg-white p-6 h-64 rounded-lg border"></div></AppShell>;

  return (
    <AppShell>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Slip Tunjangan Kinerja</h1>
        <p className="text-gray-500">Data hasil kalkulasi final sistem</p>
      </div>

      {calculations.length === 0 ? (
        <div className="bg-white p-8 text-center rounded-lg border border-gray-200">
          <p className="text-gray-500">Belum ada data kalkulasi Tunjangan Kinerja Anda.</p>
        </div>
      ) : (
        <div className="space-y-6">
          {calculations.map(calc => (
            <div key={calc.id} className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
              <div className="bg-gray-50 p-4 border-b flex justify-between items-center">
                <div>
                  <h3 className="font-bold text-gray-900">Periode: {calc.tukin_periods?.period_month}</h3>
                  <p className="text-sm text-gray-500">Status Periode: {calc.tukin_periods?.status}</p>
                </div>
                <div className="text-right">
                  <span className="block text-xs text-gray-500">Total Tukin Diterima</span>
                  <span className="text-xl font-bold text-green-600">{formatCurrency(calc.final_tukin)}</span>
                </div>
              </div>
              
              <div className="p-4 grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="text-sm font-semibold text-gray-900 border-b pb-1 mb-3">Informasi Snapshot</h4>
                  <table className="w-full text-sm text-left">
                    <tbody>
                      <tr><td className="py-1 text-gray-500">Jabatan Saat Kalkulasi</td><td className="font-medium">{assignment?.position?.name} ({calc.tukin_formula_role})</td></tr>
                      <tr><td className="py-1 text-gray-500">Pagu Tukin</td><td className="font-medium">{formatCurrency(calc.pagu_snapshot)}</td></tr>
                      <tr><td className="py-1 text-gray-500">Versi Formula</td><td className="font-medium">{calc.formula_version}</td></tr>
                    </tbody>
                  </table>
                  
                  {calc.tukin_formula_role === 'Lurah' && (
                    <div className="mt-4 pt-4 border-t">
                      <h4 className="text-sm font-semibold text-gray-900 border-b pb-1 mb-3">Rata-rata Capaian Pamong</h4>
                      <div className="bg-indigo-50 p-3 rounded border border-indigo-100 text-sm">
                        <div className="flex justify-between mb-1"><span className="text-indigo-800">Persentase Rata-Rata:</span> <span className="font-bold text-indigo-900">{calc.tukin_percentage}%</span></div>
                        <p className="text-xs text-indigo-700 mt-2">Diperoleh dari agregasi {calc.tukin_calculation_components?.length || 0} Pamong definitif (eligibility: true).</p>
                      </div>
                    </div>
                  )}
                </div>
                
                {calc.tukin_formula_role !== 'Lurah' && (
                  <div>
                    <h4 className="text-sm font-semibold text-gray-900 border-b pb-1 mb-3">Rincian Perhitungan (Pamong)</h4>
                    <table className="w-full text-sm text-left text-gray-600">
                      <tbody>
                        <tr><td className="py-1">Hari Kerja (HK)</td><td className="text-right font-medium text-gray-900">{calc.hk}</td></tr>
                        <tr><td className="py-1">Masuk Kerja (MK)</td><td className="text-right font-medium text-gray-900">{calc.mk}</td></tr>
                        <tr><td className="py-1 text-indigo-600 font-medium">Penilaian Kehadiran (PB)</td><td className="text-right font-bold text-indigo-700">{calc.pb}</td></tr>
                        <tr><td colSpan={2}><hr className="my-1 border-dashed" /></td></tr>
                        <tr><td className="py-1">Target Kinerja Bulanan (TK.B)</td><td className="text-right font-medium text-gray-900">{calc.tkb}</td></tr>
                        <tr><td className="py-1">Capaian Kinerja Bulanan (CK.B)</td><td className="text-right font-medium text-gray-900">{calc.ckb}</td></tr>
                        <tr><td className="py-1 text-indigo-600 font-medium">Kinerja Bulanan (KB)</td><td className="text-right font-bold text-indigo-700">{calc.actual_kb}</td></tr>
                        <tr><td className="py-1 text-xs text-gray-400">KB Digunakan (No Cap)</td><td className="text-right text-xs text-gray-500">{calc.kb_used_for_npk}</td></tr>
                        <tr><td colSpan={2}><hr className="my-1 border-dashed" /></td></tr>
                        <tr><td className="py-1 text-blue-700 font-medium">Nilai Prestasi Kerja (NPK)</td><td className="text-right font-bold text-blue-800">{calc.npk}</td></tr>
                        <tr><td className="py-1 text-blue-700 font-medium">Persentase Pemetaan</td><td className="text-right font-bold text-blue-800">{calc.tukin_percentage}%</td></tr>
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
              
              <div className="bg-gray-50 p-4 border-t text-sm">
                <div className="flex justify-between items-center mb-1">
                  <span className="text-gray-600">Kalkulasi Kotor (Gross)</span>
                  <span className="font-medium text-gray-900">{formatCurrency(calc.gross_tukin)}</span>
                </div>
                <div className="flex justify-between items-center mb-1">
                  <span className="text-red-600">Potongan Disiplin</span>
                  <span className="font-medium text-red-600">-{formatCurrency(calc.adjustment_amount)}</span>
                </div>
                <div className="flex justify-between items-center pt-2 border-t font-bold text-base">
                  <span className="text-gray-900">Tukin Final Diterima</span>
                  <span className="text-green-700">{formatCurrency(calc.final_tukin)}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </AppShell>
  );
}
`;

const carikKalkulasiPage = `
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
      setSuccess(\`Berhasil memproses \${data.total_calculated} data kalkulasi.\`);
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
                    <span className={\`inline-flex px-2 py-1 rounded-full text-xs font-semibold \${p.status === 'Locked' ? 'bg-gray-200 text-gray-800' : 'bg-blue-100 text-blue-800'}\`}>
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
`;

fs.mkdirSync(path.join(srcDir, 'app/tukin'), { recursive: true });
fs.mkdirSync(path.join(srcDir, 'app/admin/kalkulasi'), { recursive: true });

fs.writeFileSync(path.join(srcDir, 'app/tukin/page.tsx'), userTukinPage.trim() + '\\n', 'utf8');
fs.writeFileSync(path.join(srcDir, 'app/admin/kalkulasi/page.tsx'), carikKalkulasiPage.trim() + '\\n', 'utf8');

console.log('Tukin UI scaffolded.');
