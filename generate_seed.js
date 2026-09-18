const fs = require('fs');

const matrikData = JSON.parse(fs.readFileSync('MATRIK TUKIN KALIDENGEN.xlsx.json'));
const paguData = JSON.parse(fs.readFileSync('HITUNGAN TUNJANGAN KINERJA.xlsx.json'));

let sql = `-- Migration: Tukin Pagus Table\n`;
sql += `
CREATE TABLE IF NOT EXISTS tukin_pagus (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    position_id UUID NOT NULL REFERENCES positions(id) ON DELETE CASCADE,
    amount NUMERIC(15, 2) NOT NULL,
    effective_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE TRIGGER update_tukin_pagus_updated_at BEFORE UPDATE ON tukin_pagus FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
ALTER TABLE tukin_pagus ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Pagus: Anyone can view" ON tukin_pagus FOR SELECT USING (true);
CREATE POLICY "Pagus: Admin can manage" ON tukin_pagus FOR ALL USING (is_admin());
\n\n`;

sql += `-- SEED DATA KALURAHAN KALIDENGEN\n\n`;

// 1. Village Settings
sql += `INSERT INTO village_settings (id, setting_key, setting_value) VALUES 
(uuid_generate_v4(), 'kalurahan_name', '"Kalurahan Kalidengen"'),
(uuid_generate_v4(), 'kapanewon_name', '"Kapanewon Temon"'),
(uuid_generate_v4(), 'kabupaten_name', '"Kabupaten Kulon Progo"'),
(uuid_generate_v4(), 'provinsi_name', '"DI Yogyakarta"');\n\n`;

// 2. Positions
const positions = [
    { id: '11111111-1111-1111-1111-111111111111', name: 'Lurah', min_ckb: 0, pagu: 1561000 },
    { id: '22222222-2222-2222-2222-222222222222', name: 'Carik', min_ckb: 40, pagu: 1384950 },
    { id: '33333333-3333-3333-3333-333333333333', name: 'Danarta', min_ckb: 39, pagu: 1223600 },
    { id: '44444444-4444-4444-4444-444444444444', name: 'Panata Laksana Sarta Pangripta', min_ckb: 39, pagu: 1223600 },
    { id: '55555555-5555-5555-5555-555555555555', name: 'Jagabaya', min_ckb: 39, pagu: 1223600 },
    { id: '66666666-6666-6666-6666-666666666666', name: 'Ulu-Ulu', min_ckb: 39, pagu: 1223600 },
    { id: '77777777-7777-7777-7777-777777777777', name: 'Kamituwa', min_ckb: 39, pagu: 1223600 },
    { id: '88888888-8888-8888-8888-888888888888', name: 'Dukuh Kalidengen I', min_ckb: 38, pagu: 1140300 },
    { id: '99999999-9999-9999-9999-999999999999', name: 'Dukuh Kalidengen II', min_ckb: 38, pagu: 1140300 },
    { id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', name: 'Dukuh Sidatan', min_ckb: 38, pagu: 1140300 },
    { id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', name: 'Staf', min_ckb: 0, pagu: 0 }
];

positions.forEach(p => {
    sql += `INSERT INTO positions (id, name, min_ckb_target) VALUES ('${p.id}', '${p.name}', ${p.min_ckb});\n`;
    if (p.pagu > 0) {
        sql += `INSERT INTO tukin_pagus (id, position_id, amount, effective_date) VALUES (uuid_generate_v4(), '${p.id}', ${p.pagu}, '2026-01-01');\n`;
    }
});
sql += '\n';

// 3. Profiles & Employees
const employees = [
    { profile_id: '00000000-0000-0000-0000-000000000001', name: 'Sunardi', pos: '11111111-1111-1111-1111-111111111111', role: 'user' },
    { profile_id: '00000000-0000-0000-0000-000000000002', name: 'Muh. Masruri Mustofa', pos: '22222222-2222-2222-2222-222222222222', role: 'admin' },
    { profile_id: '00000000-0000-0000-0000-000000000003', name: 'Viki Wulandari', pos: '33333333-3333-3333-3333-333333333333', role: 'user' },
    { profile_id: '00000000-0000-0000-0000-000000000004', name: 'Agus Endarto', pos: '44444444-4444-4444-4444-444444444444', role: 'user' },
    { profile_id: '00000000-0000-0000-0000-000000000005', name: 'Subarno', pos: '55555555-5555-5555-5555-555555555555', role: 'user' },
    { profile_id: '00000000-0000-0000-0000-000000000006', name: 'Saridi', pos: '66666666-6666-6666-6666-666666666666', role: 'user' },
    { profile_id: '00000000-0000-0000-0000-000000000007', name: 'Sumardi', pos: '77777777-7777-7777-7777-777777777777', role: 'user' },
    { profile_id: '00000000-0000-0000-0000-000000000008', name: 'Widi Hartono', pos: '88888888-8888-8888-8888-888888888888', role: 'user' },
    { profile_id: '00000000-0000-0000-0000-000000000009', name: 'Rendi Ardiyanto', pos: '99999999-9999-9999-9999-999999999999', role: 'user' },
    { profile_id: '00000000-0000-0000-0000-000000000010', name: 'Edi Supriyanto', pos: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', role: 'user' },
];

employees.forEach(e => {
    sql += `INSERT INTO profiles (id, role, full_name) VALUES ('${e.profile_id}', '${e.role}', '${e.name}');\n`;
    sql += `INSERT INTO employees (id, profile_id, position_id, status) VALUES (uuid_generate_v4(), '${e.profile_id}', '${e.pos}', 'active');\n`;
});
sql += '\n';

// 4. MATRICES mapping
const sheetToPos = {
    'CARIK': ['22222222-2222-2222-2222-222222222222'],
    'DAnarta': ['33333333-3333-3333-3333-333333333333'],
    'PALAPA': ['44444444-4444-4444-4444-444444444444'],
    'JAGABAYA': ['55555555-5555-5555-5555-555555555555'],
    'ULU-ULU': ['66666666-6666-6666-6666-666666666666'],
    'KAMITUWA': ['77777777-7777-7777-7777-777777777777'],
    'DUKUH': ['88888888-8888-8888-8888-888888888888', '99999999-9999-9999-9999-999999999999', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'],
    'STAF': ['bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb']
};

function escapeStr(str) {
    if(!str) return '';
    return String(str).replace(/'/g, "''").replace(/\\/g, "\\\\");
}

let anomalyCount = 0;

for (const sheet of Object.keys(matrikData)) {
    if (!sheetToPos[sheet]) continue;
    
    // For DUKUH, we apply the same matrix to all 3 Dukuhs
    const posIds = sheetToPos[sheet];
    
    for (const posId of posIds) {
        // We do 1 matrix_version per posId
        const matVersionId = 'm' + posId.substring(1);
        sql += `INSERT INTO matrix_versions (id, position_id, version_number, status, effective_date) VALUES ('${matVersionId}', '${posId}', 1, 'published', '2026-01-01');\n`;
        
        let currentGroupId = null;
        
        const rows = matrikData[sheet];
        for (let i = 8; i < rows.length; i++) {
            const row = rows[i];
            if (!row || row.length < 5) continue;
            
            const groupNum = row[0];
            const groupName = row[1];
            const itemId = row[2];
            const itemName = row[3];
            const annualTarget = parseInt(row[4]);
            const unit = row[5];
            
            // If groupNum is a number or groupName exists but itemId is null, it might be a Group Row
            if (groupNum && !itemId) {
                currentGroupId = 'g_' + Math.random().toString(36).substr(2, 9);
                sql += `INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('${currentGroupId}', '${matVersionId}', '${escapeStr(groupName)}');\n`;
                continue;
            }
            
            if (groupNum && itemId) {
                // Inline group and item
                currentGroupId = 'g_' + Math.random().toString(36).substr(2, 9);
                sql += `INSERT INTO performance_groups (id, matrix_version_id, name) VALUES ('${currentGroupId}', '${matVersionId}', '${escapeStr(groupName)}');\n`;
            }
            
            if (itemId && itemName && currentGroupId && !isNaN(annualTarget)) {
                // It's an item
                let monthlyTarget = Math.ceil(annualTarget / 12);
                
                // Consistency check logic: we could sum month cols (6 to 17 if they exist)
                let sumTarget = 0;
                for(let c=6; c<=17; c++) {
                    if(row[c] && !isNaN(parseInt(row[c]))) sumTarget += parseInt(row[c]);
                }
                let note = "";
                if (sumTarget > 0 && sumTarget !== annualTarget) {
                    note = ` -- [INKONSISTENSI] Jumlah bulanan (${sumTarget}) tidak cocok dengan target tahunan (${annualTarget})`;
                    anomalyCount++;
                }

                sql += `WITH new_item AS (
    INSERT INTO performance_items (id, group_id, name, unit) 
    VALUES (uuid_generate_v4(), '${currentGroupId}', '${escapeStr(itemName)}', '${escapeStr(unit)}') 
    RETURNING id
)
INSERT INTO performance_targets (id, item_id, annual_target, monthly_target) 
SELECT uuid_generate_v4(), id, ${annualTarget}, ${monthlyTarget} FROM new_item;${note}\n`;
            }
        }
        sql += `\n`;
    }
}

fs.writeFileSync('supabase/migrations/20260916000003_seed_kalidengen.sql', sql);
console.log('Seed migration created! Anomalies found:', anomalyCount);
