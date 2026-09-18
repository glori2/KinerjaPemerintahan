import os

filepath_list = 'src/app/jurnal/page.tsx'
with open(filepath_list, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace getStatusColor logic
old_get_status_color = """  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Draft': return 'bg-gray-100 text-gray-800';
      case 'Submitted': return 'bg-blue-100 text-blue-800';
      case 'Approved': return 'bg-green-100 text-green-800';
      case 'Rejected': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };"""

new_get_status_color = """  const getStatusColor = (status: string) => {
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
  };"""

content = content.replace(old_get_status_color, new_get_status_color)
content = content.replace('{j.status}', '{getStatusLabel(j.status)}')

with open(filepath_list, 'w', encoding='utf-8') as f:
    f.write(content)

filepath_detail = 'src/app/jurnal/[id]/page.tsx'
with open(filepath_detail, 'r', encoding='utf-8') as f:
    content_detail = f.read()

old_detail_status_render = """<span className="px-3 py-1 bg-gray-100 text-gray-800 rounded-full text-sm font-medium">
              {journal.status}
            </span>"""

new_detail_status_render = """{(() => {
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
            })()}"""

content_detail = content_detail.replace(old_detail_status_render, new_detail_status_render)

with open(filepath_detail, 'w', encoding='utf-8') as f:
    f.write(content_detail)

print("Patch applied")
