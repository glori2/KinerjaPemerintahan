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
        .from('attendances')
        .select('*')
        .eq('employee_id', employee.id)
        .eq('date', today)
        .single();
        
      let pendingEval = 0;
      let carikStats = null;
      
      if (isLurah) {
        const { count } = await supabase
          .from('performance_journals')
          .select('*', { count: 'exact', head: true })
          .eq('status', 'Submitted');
        pendingEval = count || 0;
      }

      if (isCarik) {
        // Fetch active matrix
        const { data: mx } = await supabase.from('matrix_versions').select('version_number').eq('status', 'Published').order('created_at', { ascending: false }).limit(1).single();
        
        // Fetch current period
        const { data: pd } = await supabase.from('tukin_periods').select('period_month, status').order('period_month', { ascending: false }).limit(1).single();
        
        // Fetch journal counts
        const { count: j_draft } = await supabase.from('performance_journals').select('*', { count: 'exact', head: true }).eq('status', 'Draft');
        const { count: j_submitted } = await supabase.from('performance_journals').select('*', { count: 'exact', head: true }).eq('status', 'Submitted');
        const { count: j_approved } = await supabase.from('performance_journals').select('*', { count: 'exact', head: true }).eq('status', 'Approved');
        
        carikStats = {
          matrixVersion: mx ? mx.version_number : '-',
          currentPeriod: pd ? pd.period_month : '-',
          periodStatus: pd ? pd.status : '-',
          journals: { draft: j_draft || 0, submitted: j_submitted || 0, approved: j_approved || 0 }
        };
      }

      setStats({
        todayAttendance: todayAtt,
        pendingEvaluations: pendingEval,
        carik: carikStats
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
        <div className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
              <h3 className="text-sm font-medium text-gray-500">Matriks Aktif</h3>
              <p className="mt-2 text-2xl font-semibold text-gray-900">V{stats?.carik?.matrixVersion}</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
              <h3 className="text-sm font-medium text-gray-500">Periode Berjalan</h3>
              <p className="mt-2 text-2xl font-semibold text-gray-900">{stats?.carik?.currentPeriod}</p>
              <p className="text-sm text-gray-500 mt-1">Status: {stats?.carik?.periodStatus}</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
              <h3 className="text-sm font-medium text-gray-500">Aktivitas Jurnal (Semua Pamong)</h3>
              <div className="mt-2 flex gap-4 text-sm font-medium">
                <span className="text-gray-600">{stats?.carik?.journals?.draft} Draft</span>
                <span className="text-blue-600">{stats?.carik?.journals?.submitted} Submitted</span>
                <span className="text-green-600">{stats?.carik?.journals?.approved} Approved</span>
              </div>
            </div>
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
