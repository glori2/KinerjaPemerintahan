'use client';
import { useState, useEffect } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Journal, JournalEvidence } from '@/types';

interface LocalJournalEvidence extends JournalEvidence {
  file_url: string;
  file_size: number;
}

interface JournalWithEvidenceAndEmployee extends Omit<Journal, 'employees' | 'journal_evidence'> {
  employees?: {
    profiles?: {
      full_name: string;
    };
  };
  journal_evidence?: LocalJournalEvidence[];
}

export default function EvaluasiDetail({ params }: { params: { id: string } }) {
  const { profile, assignment } = useAuth();
  const router = useRouter();
  
  const [journal, setJournal] = useState<JournalWithEvidenceAndEmployee | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  
  const [assessedRealization, setAssessedRealization] = useState('');
  const [capaianValue, setCapaianValue] = useState('');
  const [notes, setNotes] = useState('');
  
  const [returnReason, setReturnReason] = useState('');
  const [showReturn, setShowReturn] = useState(false);
  const [processing, setProcessing] = useState(false);

  const isLurah = profile?.role === 'user' && assignment?.position?.name === 'Lurah';

  useEffect(() => {
    const fetchJournal = async () => {
      try {
        const { data, error: qError } = await supabase
          .from('performance_journals')
          .select('*, employees!inner(profiles!inner(full_name)), journal_evidence(*)')
          .eq('id', params.id)
          .single();
        if (qError) throw qError;
        setJournal(data as unknown as JournalWithEvidenceAndEmployee);
        // Pre-fill
        setAssessedRealization(data.realization.toString());
        setCapaianValue(((data.realization / data.target_snapshot) * 100).toFixed(2));
      } catch {
        setError('Gagal memuat jurnal atau akses ditolak.');
      } finally {
        setLoading(false);
      }
    };

    if (isLurah) fetchJournal();
    else setLoading(false);
  }, [isLurah, params.id]);

  const handleApprove = async () => {
    if (!confirm('Yakin menyetujui jurnal ini?')) return;
    setProcessing(true);
    setError('');
    try {
      const { error: rpcError } = await supabase.rpc('approve_journal', {
        p_journal_id: params.id,
        p_assessed_realization: parseInt(assessedRealization, 10),
        p_capaian_value: parseFloat(capaianValue),
        p_note: notes || null
      });
      if (rpcError) throw rpcError;
      router.push('/evaluasi');
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Gagal menyetujui jurnal');
      setProcessing(false);
    }
  };

  const handleReturn = async () => {
    if (!returnReason.trim()) {
      setError('Alasan pengembalian wajib diisi.');
      return;
    }
    if (!confirm('Yakin mengembalikan jurnal ini?')) return;
    setProcessing(true);
    setError('');
    try {
      const { error: rpcError } = await supabase.rpc('return_journal', {
        p_journal_id: params.id,
        p_reason: returnReason
      });
      if (rpcError) throw rpcError;
      router.push('/evaluasi');
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Gagal mengembalikan jurnal');
      setProcessing(false);
    }
  };

  const [downloadingItems, setDownloadingItems] = useState<Record<string, boolean>>({});

  const handleDownload = async (path: string) => {
    setDownloadingItems(prev => ({ ...prev, [path]: true }));
    try {
      const { data, error: stError } = await supabase.storage.from('evidence').createSignedUrl(path, 300); // 5 minutes expiration
      if (stError) throw stError;
      window.open(data.signedUrl, '_blank');
    } catch {
      alert('Bukti tidak dapat diakses.');
    } finally {
      setDownloadingItems(prev => ({ ...prev, [path]: false }));
    }
  };

  if (!isLurah && !loading) return <AppShell><div className="bg-red-50 p-6 rounded-lg text-red-700">Akses ditolak.</div></AppShell>;
  if (loading) return <AppShell><div className="animate-pulse bg-white p-6 rounded-lg shadow-sm h-64"></div></AppShell>;
  if (error && !journal) return <AppShell><div className="bg-red-50 p-6 rounded-lg text-red-700">{error}</div></AppShell>;
  if (!journal) return <AppShell><div className="bg-gray-50 p-6 rounded-lg text-gray-700">Jurnal tidak ditemukan.</div></AppShell>;

  return (
    <AppShell>
      <div className="max-w-5xl mx-auto space-y-6">
        <div className="flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-900">Evaluasi Jurnal Kinerja</h1>
          <Link href="/evaluasi" className="text-sm text-gray-500 hover:text-gray-700">Kembali ke Antrean</Link>
        </div>

        {error && <div className="p-4 bg-red-50 text-red-700 rounded-md text-sm border border-red-200">{error}</div>}

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="md:col-span-2 space-y-6">
            <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
              <h2 className="text-lg font-bold text-gray-900 mb-4 border-b pb-2">Informasi Jurnal</h2>
              <div className="grid grid-cols-2 gap-y-4 gap-x-6 text-sm">
                <div><span className="block text-gray-500">Pamong</span><span className="font-medium text-gray-900">{journal.employees?.profiles?.full_name}</span></div>
                <div><span className="block text-gray-500">Tanggal</span><span className="font-medium text-gray-900">{journal.activity_date}</span></div>
                <div><span className="block text-gray-500">Waktu</span><span className="font-medium text-gray-900">{journal.start_time?.substring(0,5)} - {journal.end_time?.substring(0,5)}</span></div>
                <div><span className="block text-gray-500">Lokasi</span><span className="font-medium text-gray-900">{journal.location}</span></div>
                <div className="col-span-2"><span className="block text-gray-500">Grup</span><span className="font-medium text-gray-900">{journal.group_name_snapshot}</span></div>
                <div className="col-span-2"><span className="block text-gray-500">Aktivitas</span><span className="font-medium text-gray-900">{journal.item_name_snapshot}</span></div>
                <div><span className="block text-gray-500">Catatan Pelaksana</span><span className="font-medium text-gray-900">{journal.note || '-'}</span></div>
                <div>
                  <span className="block text-gray-500">Status</span>
                  <span className="inline-flex px-2 py-1 mt-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-800">Submitted</span>
                </div>
              </div>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
              <h2 className="text-lg font-bold text-gray-900 mb-4 border-b pb-2">Bukti Pendukung (Evidence)</h2>
              {journal.journal_evidence && journal.journal_evidence.length > 0 ? (
                <ul className="divide-y divide-gray-100">
                  {journal.journal_evidence.map((ev) => (
                    <li key={ev.id} className="py-3 flex justify-between items-center">
                      <div className="flex items-center">
                        <svg className="w-5 h-5 text-gray-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"></path></svg>
                        <span className="text-sm font-medium text-gray-900">{ev.file_name}</span>
                        <span className="ml-2 text-xs text-gray-500">({(ev.file_size / 1024).toFixed(0)} KB)</span>
                      </div>
                      <button onClick={() => handleDownload(ev.file_url)} disabled={downloadingItems[ev.file_url]} className="text-sm text-indigo-600 hover:text-indigo-900 font-medium disabled:opacity-50">
                        {downloadingItems[ev.file_url] ? 'Menyiapkan dokumen...' : 'Lihat Bukti'}
                      </button>
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="text-sm text-gray-500">Tidak ada bukti pendukung terlampir.</p>
              )}
            </div>
          </div>

          <div className="space-y-6">
            <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200 border-t-4 border-t-indigo-500">
              <h2 className="text-lg font-bold text-gray-900 mb-4 border-b pb-2">Formulir Penilaian</h2>
              
              <div className="space-y-4">
                <div className="p-3 bg-gray-50 rounded border text-sm text-gray-700">
                  <div className="flex justify-between mb-1"><span className="text-gray-500">Dilaporkan:</span> <span className="font-medium">{journal.realization} {journal.unit_snapshot}</span></div>
                  <div className="flex justify-between"><span className="text-gray-500">Target Bulanan:</span> <span className="font-medium">{journal.target_snapshot} {journal.unit_snapshot}</span></div>
                </div>

                {!showReturn ? (
                  <>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Realisasi Disetujui</label>
                      <input type="number" required min="0" max={journal.realization} value={assessedRealization} onChange={e => setAssessedRealization(e.target.value)} disabled={processing} className="w-full p-2 border rounded-md" />
                      <p className="text-xs text-gray-500 mt-1">Maksimal: {journal.realization}</p>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Nilai Capaian (%)</label>
                      <input type="number" step="0.01" required min="0" value={capaianValue} onChange={e => setCapaianValue(e.target.value)} disabled={processing} className="w-full p-2 border rounded-md" />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Catatan Evaluasi</label>
                      <textarea value={notes} onChange={e => setNotes(e.target.value)} disabled={processing} className="w-full p-2 border rounded-md" rows={3}></textarea>
                    </div>
                    <div className="pt-2 flex flex-col gap-2">
                      <button onClick={handleApprove} disabled={processing || !assessedRealization || !capaianValue} className="w-full py-2 bg-green-600 text-white rounded-md font-medium text-sm hover:bg-green-700 disabled:opacity-50">
                        {processing ? 'Memproses...' : 'Setujui'}
                      </button>
                      <button onClick={() => setShowReturn(true)} disabled={processing} className="w-full py-2 bg-white text-orange-600 border border-orange-200 rounded-md font-medium text-sm hover:bg-orange-50 disabled:opacity-50">
                        Opsi Kembalikan (Return)
                      </button>
                    </div>
                  </>
                ) : (
                  <>
                    <div>
                      <label className="block text-sm font-medium text-orange-800 mb-1">Alasan Pengembalian</label>
                      <textarea value={returnReason} onChange={e => setReturnReason(e.target.value)} disabled={processing} className="w-full p-2 border border-orange-300 focus:border-orange-500 focus:ring-orange-500 rounded-md" rows={4} placeholder="Jelaskan alasan jurnal dikembalikan..."></textarea>
                    </div>
                    <div className="pt-2 flex flex-col gap-2">
                      <button onClick={handleReturn} disabled={processing || !returnReason.trim()} className="w-full py-2 bg-orange-600 text-white rounded-md font-medium text-sm hover:bg-orange-700 disabled:opacity-50">
                        {processing ? 'Memproses...' : 'Kembalikan'}
                      </button>
                      <button onClick={() => setShowReturn(false)} disabled={processing} className="w-full py-2 bg-white text-gray-600 border border-gray-200 rounded-md font-medium text-sm hover:bg-gray-50 disabled:opacity-50">
                        Batal
                      </button>
                    </div>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
