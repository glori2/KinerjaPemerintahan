import os

filepath = 'src/app/dashboard/page.tsx'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

old_block = """<p className="text-sm text-gray-500 mt-1">Jurnal menunggu persetujuan</p>
          </div>
        </div>"""

new_block = """<p className="text-sm text-gray-500 mt-1">Jurnal menunggu persetujuan</p>
            <div className="mt-4 pt-4 border-t border-gray-100">
              <a href="/evaluasi" className="text-sm font-medium text-indigo-600 hover:text-indigo-800">
                Lihat Antrean &rarr;
              </a>
            </div>
          </div>
        </div>"""

content = content.replace(old_block, new_block)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("Dashboard updated")
