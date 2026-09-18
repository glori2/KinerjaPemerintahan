'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';

import { AuditLog } from '@/types';

export default function AdminAudit() {
  const { profile, assignment } = useAuth();
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [loading, setLoading] = useState(true);

  // Filters
  const [actionFilter, setActionFilter] = useState('');
  const [entityFilter, setEntityFilter] = useState('');

  const isCarik = profile?.role === 'admin' && assignment?.position?.name === 'Carik';

  useEffect(() => {
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
        setLogs((data as unknown as AuditLog[]) || []);
      } catch (err: unknown) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    if (isCarik) fetchLogs();
    else setLoading(false);
  }, [isCarik, actionFilter, entityFilter]);

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
                  <span className={`inline-flex px-2 py-1 rounded text-xs font-bold ${
                    log.action === 'INSERT' ? 'text-green-700 bg-green-50' : 
                    log.action === 'UPDATE' ? 'text-blue-700 bg-blue-50' : 
                    'text-red-700 bg-red-50'
                  }`}>{log.action}</span>
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
