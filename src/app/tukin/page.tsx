'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';

interface TukinCalculationResponse {
  id: string;
  employee_id: string;
  tukin_period_id: string;
  tukin_formula_role: string;
  pagu_snapshot: number;
  formula_version: string;
  attendance_policy_version: string;
  min_ckb_snapshot: number;
  hk: number;
  mk: number;
  pb: number;
  tkb: number;
  ckb: number;
  actual_kb: number;
  kb_used_for_npk: number;
  npk: number;
  tukin_percentage: number;
  gross_tukin: number;
  adjustment_amount: number;
  final_tukin: number;
  created_at: string;
  tukin_periods?: {
    period_month: string;
    status: string;
  };
  tukin_calculation_components?: {
    source_percentage_snapshot: number;
    employees?: {
      profiles?: {
        full_name: string;
      };
    };
  }[];
}

export default function TukinPage() {
  const { employee, assignment } = useAuth();
  const [calculations, setCalculations] = useState<TukinCalculationResponse[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchCalculations = async () => {
      if (!employee?.id) return;
      try {
        const { data, error } = await supabase
          .from('tukin_calculations')
          .select('*, tukin_periods(*), tukin_calculation_components(source_percentage_snapshot, employees(profiles(full_name)))')
          .eq('employee_id', employee.id)
          .order('created_at', { ascending: false });
          
        if (error) throw error;
        setCalculations((data as unknown as TukinCalculationResponse[]) || []);
      } catch {
        // Suppressing raw error logging
      } finally {
        setLoading(false);
      }
    };

    if (employee) fetchCalculations();
  }, [employee]);

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
