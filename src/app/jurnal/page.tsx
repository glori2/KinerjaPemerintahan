'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';
import Link from 'next/link';
import { Journal, JournalEvidence } from '@/types';

interface JournalWithEvidence extends Journal {
  journal_evidence?: JournalEvidence[];
}

export default function JurnalList() {
  const { employee } = useAuth();
  const [journals, setJournals] = useState<JournalWithEvidence[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchJournals = async () => {
      if (!employee?.id) return;
      try {
        const { data, error } = await supabase
          .from('performance_journals')
          .select('*, journal_evidence(*)')
          .eq('employee_id', employee.id)
          .order('activity_date', { ascending: false });
        if (error) throw error;
        setJournals((data as unknown as JournalWithEvidence[]) || []);
      } catch {
        // Prevent raw error leakage
      } finally {
        setLoading(false);
      }
    };

    if (employee) fetchJournals();
  }, [employee]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Draft': return 'bg-gray-100 text-gray-800';
      case 'Submitted': return 'bg-blue-100 text-blue-800';
      case 'Verified': return 'bg-purple-100 text-purple-800';
      case 'Returned': return 'bg-orange-100 text-orange-800';
      case 'Approved': return 'bg-green-100 text-green-800';
      case 'Locked': return 'bg-gray-200 text-gray-900';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'Draft': return 'Draft';
      case 'Submitted': return 'Menunggu Evaluasi';
      case 'Verified': return 'Terverifikasi';
      case 'Returned': return 'Dikembalikan';
      case 'Approved': return 'Disetujui';
      case 'Locked': return 'Terkunci';
      default: return status || 'Unknown';
    }
  };

  return (
    <AppShell>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Jurnal Kinerja</h1>
        <Link href="/jurnal/create" className="px-4 py-2 bg-indigo-600 text-white rounded-md text-sm font-medium hover:bg-indigo-700">
          + Tambah Jurnal
        </Link>
      </div>

      {loading ? (
        <div className="animate-pulse bg-white rounded-lg h-64 border border-gray-200"></div>
      ) : journals.length === 0 ? (
        <div className="bg-white p-8 text-center rounded-lg border border-gray-200">
          <p className="text-gray-500">Belum ada jurnal ditemukan.</p>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tanggal</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Aktivitas</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Realisasi</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {journals.map((j) => (
                  <tr key={j.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{j.activity_date}</td>
                    <td className="px-6 py-4 text-sm text-gray-900">
                      <div className="font-medium">{j.item_name_snapshot}</div>
                      <div className="text-xs text-gray-500">{j.group_name_snapshot}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {j.realization} / {j.target_snapshot} {j.unit_snapshot}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(j.status)}`}>
                        {getStatusLabel(j.status)}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <Link href={`/jurnal/${j.id}`} className="text-indigo-600 hover:text-indigo-900">
                        Detail
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
