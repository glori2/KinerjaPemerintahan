import os

filepath = 'src/app/dashboard/page.tsx'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Update fetchDashboardData
old_fetch = """      let pendingEval = 0;
      if (isLurah) {
        const { count } = await supabase
          .from('performance_journals')
          .select('*', { count: 'exact', head: true })
          .eq('status', 'Submitted');
        pendingEval = count || 0;
      }

      setStats({
        todayAttendance: todayAtt,
        pendingEvaluations: pendingEval
      });"""

new_fetch = """      let pendingEval = 0;
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
      });"""

content = content.replace(old_fetch, new_fetch)

# Update render for Carik
old_render = """    if (isCarik) {
      return (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
            <h3 className="text-sm font-medium text-gray-500">Status Administrasi</h3>
            <p className="mt-2 text-3xl font-semibold text-gray-900">Aktif</p>
          </div>
        </div>
      );
    }"""

new_render = """    if (isCarik) {
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
    }"""

content = content.replace(old_render, new_render)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("Dashboard updated for Carik")
