import fs from 'fs';
import path from 'path';

const srcDir = path.join(process.cwd(), 'src');

const files = {
  'app/jurnal/page.tsx': `
'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';
import Link from 'next/link';

export default function JurnalList() {
  const { employee } = useAuth();
  const [journals, setJournals] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (employee) fetchJournals();
  }, [employee]);

  const fetchJournals = async () => {
    try {
      const { data, error } = await supabase
        .from('performance_journals')
        .select('*, journal_evidence(*)')
        .eq('employee_id', employee.id)
        .order('activity_date', { ascending: false });
      if (error) throw error;
      setJournals(data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Draft': return 'bg-gray-100 text-gray-800';
      case 'Submitted': return 'bg-blue-100 text-blue-800';
      case 'Approved': return 'bg-green-100 text-green-800';
      case 'Rejected': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
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
                      <span className={\`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full \${getStatusColor(j.status)}\`}>
                        {j.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <Link href={\`/jurnal/\${j.id}\`} className="text-indigo-600 hover:text-indigo-900">
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
`,
  'app/jurnal/create/page.tsx': `
'use client';
import { useState, useEffect } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';
import { useRouter } from 'next/navigation';
import Link from 'next/link';

export default function CreateJournal() {
  const { assignment } = useAuth();
  const router = useRouter();
  
  const [items, setItems] = useState<any[]>([]);
  const [selectedItem, setSelectedItem] = useState('');
  const [target, setTarget] = useState<any>(null);
  
  const [formData, setFormData] = useState({
    activity_date: new Date().toISOString().split('T')[0],
    start_time: '08:00',
    end_time: '16:00',
    realization: '',
    location: '',
    note: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (assignment) fetchMatrix();
  }, [assignment]);

  const fetchMatrix = async () => {
    try {
      const { data: matrix } = await supabase
        .from('matrix_versions')
        .select('id')
        .eq('position_id', assignment.position_id)
        .eq('status', 'Published')
        .order('effective_from', { ascending: false })
        .limit(1)
        .single();
        
      if (matrix) {
        const { data: groups } = await supabase
          .from('performance_groups')
          .select('id, name, performance_items(id, name, performance_targets(target, unit))')
          .eq('matrix_version_id', matrix.id);
          
        let flatItems: any[] = [];
        groups?.forEach(g => {
          g.performance_items?.forEach(i => {
            flatItems.push({
              ...i,
              group_name: g.name,
              target: i.performance_targets[0]?.target,
              unit: i.performance_targets[0]?.unit,
            });
          });
        });
        setItems(flatItems);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleItemChange = (e: any) => {
    const val = e.target.value;
    setSelectedItem(val);
    const item = items.find(i => i.id === val);
    setTarget(item || null);
  };

  const handleSubmit = async (e: any) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const { data, error } = await supabase.rpc('create_journal', {
        p_item_id: selectedItem,
        p_activity_date: formData.activity_date,
        p_start_time: formData.start_time,
        p_end_time: formData.end_time,
        p_realization: parseInt(formData.realization),
        p_location: formData.location,
        p_note: formData.note
      });
      if (error) throw error;
      router.push(\`/jurnal/\${data}\`);
    } catch (err: any) {
      setError(err.message.includes('42501') ? 'Anda tidak memiliki akses.' : err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <AppShell>
      <div className="max-w-2xl mx-auto">
        <div className="mb-6 flex items-center justify-between">
          <h1 className="text-2xl font-bold text-gray-900">Buat Jurnal Baru</h1>
          <Link href="/jurnal" className="text-sm text-gray-500 hover:text-gray-700">Kembali</Link>
        </div>

        <form onSubmit={handleSubmit} className="bg-white p-6 rounded-lg shadow-sm border border-gray-200 space-y-6">
          {error && <div className="p-3 bg-red-50 text-red-700 rounded text-sm">{error}</div>}
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Tanggal</label>
              <input type="date" required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2 border" value={formData.activity_date} onChange={e => setFormData({...formData, activity_date: e.target.value})} />
            </div>
            <div className="grid grid-cols-2 gap-2">
              <div>
                <label className="block text-sm font-medium text-gray-700">Mulai</label>
                <input type="time" required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2 border" value={formData.start_time} onChange={e => setFormData({...formData, start_time: e.target.value})} />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Selesai</label>
                <input type="time" required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2 border" value={formData.end_time} onChange={e => setFormData({...formData, end_time: e.target.value})} />
              </div>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Aktivitas (Matriks Kinerja)</label>
            <select required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2 border" value={selectedItem} onChange={handleItemChange}>
              <option value="">-- Pilih Aktivitas --</option>
              {items.map(item => (
                <option key={item.id} value={item.id}>[{item.group_name}] {item.name}</option>
              ))}
            </select>
          </div>

          {target && (
            <div className="p-4 bg-indigo-50 rounded-md border border-indigo-100">
              <p className="text-sm text-indigo-800 font-medium">Target Bulanan: {target.target} {target.unit}</p>
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Lokasi</label>
              <input type="text" required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2 border" value={formData.location} onChange={e => setFormData({...formData, location: e.target.value})} />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Realisasi (Angka)</label>
              <div className="flex mt-1 relative rounded-md shadow-sm">
                <input type="number" min="0" required className="block w-full rounded-md border-gray-300 p-2 border" value={formData.realization} onChange={e => setFormData({...formData, realization: e.target.value})} />
                {target && <span className="inline-flex items-center px-3 rounded-r-md border border-l-0 border-gray-300 bg-gray-50 text-gray-500 sm:text-sm">{target.unit}</span>}
              </div>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Catatan</label>
            <textarea className="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2 border" rows={3} value={formData.note} onChange={e => setFormData({...formData, note: e.target.value})}></textarea>
          </div>

          <div className="pt-4 border-t">
            <button type="submit" disabled={loading || !selectedItem} className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50">
              {loading ? 'Menyimpan...' : 'Simpan Draft Jurnal'}
            </button>
          </div>
        </form>
      </div>
    </AppShell>
  );
}
`,
  'app/jurnal/[id]/page.tsx': `
'use client';
import { useState, useEffect } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useRouter } from 'next/navigation';
import Link from 'next/link';

export default function JournalDetail({ params }: { params: { id: string } }) {
  const [journal, setJournal] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState('');
  const router = useRouter();

  useEffect(() => {
    fetchJournal();
  }, [params.id]);

  const fetchJournal = async () => {
    try {
      const { data, error } = await supabase
        .from('performance_journals')
        .select('*, journal_evidence(*)')
        .eq('id', params.id)
        .single();
      if (error) throw error;
      setJournal(data);
    } catch (err: any) {
      setError('Gagal memuat jurnal. Anda mungkin tidak memiliki akses.');
    } finally {
      setLoading(false);
    }
  };

  const handleFileUpload = async (e: any) => {
    const file = e.target.files[0];
    if (!file) return;
    
    if (file.size > 5 * 1024 * 1024) {
      setError('Ukuran maksimal file adalah 5MB.');
      return;
    }
    
    setUploading(true);
    setError('');
    
    try {
      const fileExt = file.name.split('.').pop();
      const safeName = file.name.replace(/[^a-zA-Z0-9.-]/g, '_');
      const filePath = \`\${params.id}/\${Date.now()}_\${safeName}\`;
      
      const { error: uploadError } = await supabase.storage
        .from('evidence')
        .upload(filePath, file);
        
      if (uploadError) throw uploadError;
      
      const { data: urlData } = supabase.storage.from('evidence').getPublicUrl(filePath);
      
      const { error: dbError } = await supabase.from('journal_evidence').insert({
        journal_id: params.id,
        file_url: filePath, // Store path instead of full url for secure RLS fetch
        file_name: file.name,
        file_size: file.size,
        mime_type: file.type
      });
      
      if (dbError) throw dbError;
      
      await fetchJournal();
    } catch (err: any) {
      setError(err.message.includes('42501') ? 'Anda tidak diizinkan mengubah evidence.' : 'Gagal mengunggah dokumen.');
    } finally {
      setUploading(false);
    }
  };

  const handleSubmit = async () => {
    if (!confirm('Kirim jurnal untuk dievaluasi? Tidak dapat diubah setelah dikirim.')) return;
    setError('');
    try {
      const { error } = await supabase.rpc('submit_journal', { p_journal_id: params.id });
      if (error) throw error;
      await fetchJournal();
    } catch (err: any) {
      setError('Gagal mengirim jurnal.');
    }
  };

  if (loading) return <AppShell><div className="animate-pulse h-64 bg-white rounded-lg"></div></AppShell>;
  if (error && !journal) return <AppShell><div className="bg-red-50 text-red-700 p-4 rounded">{error}</div></AppShell>;

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
            <span className="px-3 py-1 bg-gray-100 text-gray-800 rounded-full text-sm font-medium">
              {journal.status}
            </span>
          </div>

          <div className="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span className="text-gray-500 block">Tanggal</span>
              <span className="font-medium text-gray-900">{journal.activity_date}</span>
            </div>
            <div>
              <span className="text-gray-500 block">Waktu</span>
              <span className="font-medium text-gray-900">{journal.start_time.substring(0,5)} - {journal.end_time.substring(0,5)}</span>
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
              {journal.journal_evidence.map((ev: any) => (
                <li key={ev.id} className="p-3 flex justify-between items-center text-sm">
                  <span className="text-gray-900 font-medium truncate">{ev.file_name}</span>
                  <span className="text-gray-500 ml-4">{(ev.file_size / 1024).toFixed(0)} KB</span>
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
`
};

for (const [relPath, content] of Object.entries(files)) {
  const fullPath = path.join(srcDir, relPath);
  fs.mkdirSync(path.dirname(fullPath), { recursive: true });
  fs.writeFileSync(fullPath, content.trim() + '\\n', 'utf8');
}
console.log('UI files generated successfully.');
