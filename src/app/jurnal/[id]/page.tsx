'use client';
import { useState, useEffect, useCallback, ChangeEvent } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import Link from 'next/link';
import { Journal, JournalEvidence } from '@/types';

interface LocalJournalEvidence extends JournalEvidence {
  file_url: string;
  file_size: number;
}

interface JournalWithEvidence extends Omit<Journal, 'journal_evidence'> {
  journal_evidence?: LocalJournalEvidence[];
}

export default function JournalDetail({ params }: { params: { id: string } }) {
  const [journal, setJournal] = useState<JournalWithEvidence | null>(null);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState('');

  const fetchJournal = useCallback(async () => {
    try {
      const { data, error: qError } = await supabase
        .from('performance_journals')
        .select('*, journal_evidence(*)')
        .eq('id', params.id)
        .single();
      if (qError) throw qError;
      setJournal(data as unknown as JournalWithEvidence);
    } catch {
      setError('Gagal memuat jurnal. Anda mungkin tidak memiliki akses.');
    } finally {
      setLoading(false);
    }
  }, [params.id]);

  useEffect(() => {
    fetchJournal();
  }, [fetchJournal]);

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

  const handleFileUpload = async (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    
    if (file.size > 5 * 1024 * 1024) {
      setError('Ukuran maksimal file adalah 5MB.');
      return;
    }
    
    setUploading(true);
    setError('');
    
    try {
      const safeName = file.name.replace(/[^a-zA-Z0-9.-]/g, '_');
      const filePath = `${params.id}/${Date.now()}_${safeName}`;
      
      const { error: uploadError } = await supabase.storage
        .from('evidence')
        .upload(filePath, file);
        
      if (uploadError) throw uploadError;
      
      const { error: dbError } = await supabase.from('journal_evidence').insert({
        journal_id: params.id,
        file_url: filePath, // Store path instead of full url for secure RLS fetch
        file_name: file.name,
        file_size: file.size,
        mime_type: file.type
      });
      
      if (dbError) throw dbError;
      
      await fetchJournal();
    } catch (err: unknown) {
      if (err instanceof Error && err.message.includes('42501')) {
        setError('Anda tidak diizinkan mengubah evidence.');
      } else {
        setError('Gagal mengunggah dokumen.');
      }
    } finally {
      setUploading(false);
    }
  };

  const handleSubmit = async () => {
    if (!confirm('Kirim jurnal untuk dievaluasi? Tidak dapat diubah setelah dikirim.')) return;
    setError('');
    try {
      const { error: rpcError } = await supabase.rpc('submit_journal', { p_journal_id: params.id });
      if (rpcError) throw rpcError;
      await fetchJournal();
    } catch {
      setError('Gagal mengirim jurnal.');
    }
  };

  if (loading) return <AppShell><div className="animate-pulse h-64 bg-white rounded-lg"></div></AppShell>;
  if (error && !journal) return <AppShell><div className="bg-red-50 text-red-700 p-4 rounded">{error}</div></AppShell>;
  if (!journal) return <AppShell><div className="bg-red-50 text-red-700 p-4 rounded">Jurnal tidak ditemukan.</div></AppShell>;

  const isEditable = journal.status === 'Draft' || journal.status === 'Returned';

  return (
    <AppShell>
      <div className="max-w-4xl mx-auto">
        <div className="mb-6 flex items-center justify-between">
          <h1 className="text-2xl font-bold text-gray-900">Detail Jurnal</h1>
          <Link href="/jurnal" className="text-sm text-gray-500 hover:text-gray-700">Kembali</Link>
        </div>

        {error && <div className="mb-4 p-3 bg-red-50 text-red-700 rounded text-sm">{error}</div>}

        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200 mb-6">
          <div className="flex justify-between items-start border-b pb-4 mb-4">
            <div>
              <h2 className="text-xl font-bold text-gray-900">{journal.item_name_snapshot}</h2>
              <p className="text-gray-500 text-sm">{journal.group_name_snapshot}</p>
            </div>
            {(() => {
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
                <span className={`px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(journal.status)}`}>
                  {getStatusLabel(journal.status)}
                </span>
              );
            })()}
          </div>

          <div className="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span className="text-gray-500 block">Tanggal</span>
              <span className="font-medium text-gray-900">{journal.activity_date}</span>
            </div>
            <div>
              <span className="text-gray-500 block">Waktu</span>
              <span className="font-medium text-gray-900">{journal.start_time?.substring(0,5)} - {journal.end_time?.substring(0,5)}</span>
            </div>
            <div>
              <span className="text-gray-500 block">Lokasi</span>
              <span className="font-medium text-gray-900">{journal.location}</span>
            </div>
            <div>
              <span className="text-gray-500 block">Realisasi / Target</span>
              <span className="font-medium text-gray-900">{journal.realization} / {journal.target_snapshot} {journal.unit_snapshot}</span>
            </div>
            <div className="col-span-2">
              <span className="text-gray-500 block">Catatan</span>
              <span className="font-medium text-gray-900">{journal.note || '-'}</span>
            </div>
            {journal.return_reason && (
              <div className="col-span-2 p-3 bg-orange-50 border border-orange-200 rounded text-orange-800">
                <span className="font-semibold block text-xs uppercase">Alasan Penolakan:</span>
                {journal.return_reason}
              </div>
            )}
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <h3 className="text-lg font-bold text-gray-900 mb-4">Evidence Pendukung</h3>
          
          {journal.journal_evidence && journal.journal_evidence.length > 0 ? (
            <ul className="divide-y divide-gray-200 mb-4 border rounded">
              {journal.journal_evidence.map((ev) => (
                <li key={ev.id} className="p-3 flex justify-between items-center text-sm">
                  <span className="text-gray-900 font-medium truncate">{ev.file_name}</span>
                  <span className="text-gray-500 mx-4">{(ev.file_size / 1024).toFixed(0)} KB</span>
                  <button onClick={() => handleDownload(ev.file_url)} disabled={downloadingItems[ev.file_url]} className="text-indigo-600 hover:text-indigo-900 font-medium disabled:opacity-50">
                    {downloadingItems[ev.file_url] ? 'Menyiapkan...' : 'Lihat Bukti'}
                  </button>
                </li>
              ))}
            </ul>
          ) : (
            <p className="text-gray-500 text-sm mb-4">Belum ada dokumen pendukung.</p>
          )}

          {isEditable && (
            <div className="mt-4 border-t pt-4">
              <input type="file" accept=".jpg,.jpeg,.png,.pdf" onChange={handleFileUpload} disabled={uploading} className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-medium file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100" />
              {uploading && <p className="text-sm text-indigo-600 mt-2">Mengunggah...</p>}
            </div>
          )}
        </div>

        {isEditable && (
          <div className="mt-6 flex justify-end gap-3">
            <button onClick={handleSubmit} className="px-6 py-2 bg-green-600 text-white rounded-md text-sm font-medium hover:bg-green-700">
              Submit Jurnal
            </button>
          </div>
        )}
      </div>
    </AppShell>
  );
}
