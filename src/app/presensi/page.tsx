'use client';

import AppShell from '@/components/AppShell';
import { useAuth } from '@/components/AuthProvider';
import { useCallback, useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

interface Attendance {
  id: string;
  employee_id: string;
  date: string;
  check_in_time: string;
  check_out_time?: string;
  status: string;
}

export default function PresensiPage() {
  const { employee } = useAuth();
  const [loading, setLoading] = useState(true);
  const [todayRecord, setTodayRecord] = useState<Attendance | null>(null);
  const [history, setHistory] = useState<Attendance[]>([]);
  const [actionLoading, setActionLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  const fetchData = useCallback(async () => {
    if (!employee?.id) return;
    setLoading(true);
    try {
      const today = new Date().toISOString().split('T')[0];
      
      const { data: todayAtt } = await supabase
        .from('attendances')
        .select('*')
        .eq('employee_id', employee.id)
        .eq('date', today)
        .single();
        
      setTodayRecord((todayAtt as unknown as Attendance) || null);

      const d = new Date();
      const firstDay = new Date(d.getFullYear(), d.getMonth(), 1).toISOString().split('T')[0];
      
      const { data: hist } = await supabase
        .from('attendances')
        .select('*')
        .eq('employee_id', employee.id)
        .gte('date', firstDay)
        .order('date', { ascending: false });

      setHistory((hist as unknown as Attendance[]) || []);
    } catch (e: unknown) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  }, [employee?.id]);

  useEffect(() => {
    if (employee) fetchData();
  }, [employee, fetchData]);

  const handleCheckIn = async () => {
    if (!employee?.id) return;
    setActionLoading(true);
    setErrorMsg('');
    try {
      const today = new Date().toISOString().split('T')[0];
      const now = new Date().toTimeString().split(' ')[0]; // HH:MM:SS
      
      const { error } = await supabase
        .from('attendances')
        .insert({
          employee_id: employee.id,
          date: today,
          check_in_time: now,
          status: 'present',
        });
        
      if (error) throw error;
      await fetchData();
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      setErrorMsg(msg.includes('duplicate') ? 'Anda sudah melakukan check-in hari ini.' : 'Gagal check-in. Coba lagi.');
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
        .from('attendances')
        .update({ check_out_time: now })
        .eq('id', todayRecord.id);
        
      if (error) throw error;
      await fetchData();
    } catch (err: unknown) {
      console.error(err);
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
