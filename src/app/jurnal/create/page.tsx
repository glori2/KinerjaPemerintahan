'use client';
import { useState, useEffect } from 'react';
import AppShell from '@/components/AppShell';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/components/AuthProvider';
import { useRouter } from 'next/navigation';
import Link from 'next/link';

interface LocalPerformanceItem {
  id: string;
  name: string;
  group_name: string;
  target?: number;
  unit?: string;
}

interface QueryGroup {
  id: string;
  name: string;
  performance_items: {
    id: string;
    name: string;
    unit?: string;
    performance_targets: { target: number } | { target: number }[] | null;
  }[] | null;
}

export default function CreateJournal() {
  const { assignment } = useAuth();
  const router = useRouter();
  
  const [items, setItems] = useState<LocalPerformanceItem[]>([]);
  const [selectedItem, setSelectedItem] = useState('');
  const [target, setTarget] = useState<LocalPerformanceItem | null>(null);
  
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
    const fetchMatrix = async () => {
      if (!assignment?.position_id) return;
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
            .select(`
              id,
              name,
              performance_items(
                id,
                name,
                unit,
                performance_targets(
                  target:monthly_target
                )
              )
            `)
            .eq('matrix_version_id', matrix.id);
            
          const flatItems: LocalPerformanceItem[] = [];
          if (groups) {
            const typedGroups = groups as unknown as QueryGroup[];
            typedGroups.forEach(g => {
              g.performance_items?.forEach(i => {
                const targetObj = Array.isArray(i.performance_targets)
                  ? i.performance_targets[0]
                  : i.performance_targets;

                flatItems.push({
                  id: i.id,
                  name: i.name,
                  group_name: g.name,
                  target: targetObj?.target,
                  unit: i.unit,
                });
              });
            });
          }
          setItems(flatItems);
        }
      } catch {
        // Omit raw error logging
      }
    };

    if (assignment) fetchMatrix();
  }, [assignment]);

  useEffect(() => {
    if (assignment?.effective_from) {
      const today = new Date().toISOString().split('T')[0];
      if (today < assignment.effective_from) {
        setFormData(prev => ({ ...prev, activity_date: assignment.effective_from }));
      }
    }
  }, [assignment?.effective_from]);

  const handleItemChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const val = e.target.value;
    setSelectedItem(val);
    const item = items.find(i => i.id === val);
    setTarget(item || null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const payload = {
        p_item_id: selectedItem,
        p_activity_date: formData.activity_date,
        p_start_time: formData.start_time,
        p_end_time: formData.end_time,
        p_realization: parseInt(formData.realization, 10),
        p_location: formData.location,
        p_note: formData.note || null
      };

      if (process.env.NODE_ENV === 'development') {
        console.log('[RPC create_journal] Invoking with payload:', {
          p_item_id: payload.p_item_id,
          p_activity_date: payload.p_activity_date,
          p_start_time: payload.p_start_time,
          p_end_time: payload.p_end_time,
          p_realization: payload.p_realization,
          p_location: payload.p_location,
          p_note: payload.p_note ? '[present]' : '[null]'
        });
      }

      const { data, error: rpcError } = await supabase.rpc('create_journal', payload);
      if (rpcError) {
        if (process.env.NODE_ENV === 'development') {
          console.error('[RPC create_journal] Failed:', {
            code: rpcError.code,
            message: rpcError.message,
            details: rpcError.details,
            hint: rpcError.hint
          });
        }
        throw rpcError;
      }
      router.push(`/jurnal/${data}`);
    } catch (err: unknown) {
      if (err && typeof err === 'object' && 'message' in err) {
        const rpcErr = err as { message: string; code?: string };
        if (rpcErr.message.includes('42501')) {
          setError('Anda tidak memiliki akses.');
        } else if (
          rpcErr.code === '22000' ||
          rpcErr.message.includes('No active position assignment found')
        ) {
          setError('Tanggal kegiatan berada di luar masa berlaku penugasan Anda. Silakan pilih tanggal mulai penugasan.');
        } else if (rpcErr.code === '23P01') {
          setError('Waktu kegiatan bertabrakan dengan jurnal yang sudah ada. Silakan pilih waktu yang berbeda.');
        } else {
          setError('Gagal menyimpan jurnal.');
        }
      } else {
        setError('Gagal menyimpan jurnal.');
      }
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
