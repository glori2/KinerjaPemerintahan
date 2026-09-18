'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';
import Link from 'next/link';
import { Journal } from '@/types';

interface JournalWithEmployee extends Omit<Journal, 'employees' | 'journal_evidence'> {
  employees?: {
    profiles?: {
      full_name: string;
    };
  };
  journal_evidence?: { count: number }[];
}

export default function EvaluasiList() {
  const { profile, assignment } = useAuth();
  const [journals, setJournals] = useState<JournalWithEmployee[]>([]);
  const [loading, setLoading] = useState(true);

  const isLurah = profile?.role === 'user' && assignment?.position?.name === 'Lurah';

  useEffect(() => {
    const fetchJournals = async () => {
      try {
        const { data, error } = await supabase
          .from('performance_journals')
          .select('*, employees!inner(profiles!inner(full_name)), journal_evidence(count)')
          .eq('status', 'Submitted')
          .order('activity_date', { ascending: true });
        if (error) throw error;
        setJournals((data as unknown as JournalWithEmployee[]) || []);
      } catch {
        // Suppress raw error leakage
      } finally {
        setLoading(false);
      }
    };

    if (isLurah) fetchJournals();
    else setLoading(false);
  }, [isLurah]);

  if (!isLurah && !loading) {
    return (
      <AppShell>
        <div className="bg-red-50 p-6 rounded-lg text-red-700">Akses ditolak. Halaman ini hanya untuk Lurah.</div>
      </AppShell>
    );
  }

  return (
    <AppShell>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Antrean Evaluasi Jurnal</h1>
      </div>

      {loading ? (
        <div className="animate-pulse bg-white rounded-lg h-64 border border-gray-200"></div>
      ) : journals.length === 0 ? (
        <div className="bg-white p-8 text-center rounded-lg border border-gray-200">
          <p className="text-gray-500">Tidak ada jurnal yang menunggu evaluasi.</p>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Pamong</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Aktivitas & Target</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Realisasi</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Eviden</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {journals.map((j) => (
                  <tr key={j.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-medium">
                      {j.employees?.profiles?.full_name || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{j.activity_date}</td>
                    <td className="px-6 py-4 text-sm text-gray-900">
                      <div className="font-medium">{j.item_name_snapshot}</div>
                      <div className="text-xs text-gray-500">Target: {j.target_snapshot} {j.unit_snapshot}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {j.realization} {j.unit_snapshot}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {j.journal_evidence?.[0]?.count || 0} file
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <Link href={`/evaluasi/${j.id}`} className="text-indigo-600 hover:text-indigo-900">
                        Evaluasi
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </AppShell>
  );
}
