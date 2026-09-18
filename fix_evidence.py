import os

# 1. Update evaluasi/[id]/page.tsx
evaluasi_path = r'src/app/evaluasi/[id]/page.tsx'
with open(evaluasi_path, 'r', encoding='utf-8') as f:
    evaluasi = f.read()

# Replace getPublicUrl definition and adding download state
old_get_public = """  const getPublicUrl = (path: string) => {
    const { data } = supabase.storage.from('evidence').getPublicUrl(path);
    return data.publicUrl;
  };"""

new_download_logic = """  const [downloadingItems, setDownloadingItems] = useState<Record<string, boolean>>({});

  const handleDownload = async (path: string) => {
    setDownloadingItems(prev => ({ ...prev, [path]: true }));
    try {
      const { data, error } = await supabase.storage.from('evidence').createSignedUrl(path, 300); // 5 minutes expiration
      if (error) throw error;
      window.open(data.signedUrl, '_blank');
    } catch (err) {
      alert('Bukti tidak dapat diakses.');
    } finally {
      setDownloadingItems(prev => ({ ...prev, [path]: false }));
    }
  };"""

evaluasi = evaluasi.replace(old_get_public, new_download_logic)

# Replace the anchor tag
old_anchor = """<a href={getPublicUrl(ev.file_url)} target="_blank" rel="noopener noreferrer" className="text-sm text-indigo-600 hover:text-indigo-900 font-medium">Lihat Dokumen</a>"""
new_anchor = """<button onClick={() => handleDownload(ev.file_url)} disabled={downloadingItems[ev.file_url]} className="text-sm text-indigo-600 hover:text-indigo-900 font-medium disabled:opacity-50">
                        {downloadingItems[ev.file_url] ? 'Menyiapkan dokumen...' : 'Lihat Bukti'}
                      </button>"""

evaluasi = evaluasi.replace(old_anchor, new_anchor)

with open(evaluasi_path, 'w', encoding='utf-8') as f:
    f.write(evaluasi)

# 2. Update jurnal/[id]/page.tsx
jurnal_path = r'src/app/jurnal/[id]/page.tsx'
with open(jurnal_path, 'r', encoding='utf-8') as f:
    jurnal = f.read()

# Add download logic next to fetchJournal
jurnal_hook = """  const fetchJournal = async () => {"""
new_jurnal_hook = """  const [downloadingItems, setDownloadingItems] = useState<Record<string, boolean>>({});

  const handleDownload = async (path: string) => {
    setDownloadingItems(prev => ({ ...prev, [path]: true }));
    try {
      const { data, error } = await supabase.storage.from('evidence').createSignedUrl(path, 300); // 5 minutes expiration
      if (error) throw error;
      window.open(data.signedUrl, '_blank');
    } catch (err) {
      alert('Bukti tidak dapat diakses.');
    } finally {
      setDownloadingItems(prev => ({ ...prev, [path]: false }));
    }
  };

  const fetchJournal = async () => {"""

jurnal = jurnal.replace(jurnal_hook, new_jurnal_hook)

# Remove getPublicUrl line inside handleFileUpload
jurnal_get_url = """      const { data: urlData } = supabase.storage.from('evidence').getPublicUrl(filePath);
      
      const { error: dbError } = await supabase.from('journal_evidence').insert({"""
new_db_insert = """      const { error: dbError } = await supabase.from('journal_evidence').insert({"""
jurnal = jurnal.replace(jurnal_get_url, new_db_insert)

# Replace the evidence list rendering to include the button
old_jurnal_ev = """<span className="text-gray-500 ml-4">{(ev.file_size / 1024).toFixed(0)} KB</span>
                </li>"""
new_jurnal_ev = """<span className="text-gray-500 mx-4">{(ev.file_size / 1024).toFixed(0)} KB</span>
                  <button onClick={() => handleDownload(ev.file_url)} disabled={downloadingItems[ev.file_url]} className="text-indigo-600 hover:text-indigo-900 font-medium disabled:opacity-50">
                    {downloadingItems[ev.file_url] ? 'Menyiapkan...' : 'Lihat Bukti'}
                  </button>
                </li>"""

jurnal = jurnal.replace(old_jurnal_ev, new_jurnal_ev)

with open(jurnal_path, 'w', encoding='utf-8') as f:
    f.write(jurnal)

print("Patch applied successfully")
