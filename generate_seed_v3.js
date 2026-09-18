const fs = require('fs');

const matrikData = JSON.parse(fs.readFileSync('MATRIK TUKIN KALIDENGEN.xlsx.json'));
const paguData = JSON.parse(fs.readFileSync('HITUNGAN TUNJANGAN KINERJA.xlsx.json'));

let sql = `-- ============================================================
-- Migration 015 - Seed Kalidengen
-- Baseline: IMPLEMENTATION SPECIFICATION FINAL V3.2.2.4
-- ============================================================

BEGIN;

-- 1. SEED POSITIONS (Idempotent)
INSERT INTO public.positions (id, name, is_pamong_tukin_eligible) VALUES
  ('b0000000-0000-0000-0000-000000000001', 'Lurah', false),
  ('b0000000-0000-0000-0000-000000000002', 'Carik', true),
  ('b0000000-0000-0000-0000-000000000003', 'Danarta', true),
  ('b0000000-0000-0000-0000-000000000004', 'Panata Laksana Sarta Pangripta', true),
  ('b0000000-0000-0000-0000-000000000005', 'Jagabaya', true),
  ('b0000000-0000-0000-0000-000000000006', 'Ulu-Ulu', true),
  ('b0000000-0000-0000-0000-000000000007', 'Kamituwa', true),
  ('b0000000-0000-0000-0000-000000000008', 'Dukuh', true),
  ('b0000000-0000-0000-0000-000000000009', 'Staf', false)
ON CONFLICT (name) DO UPDATE SET is_pamong_tukin_eligible = EXCLUDED.is_pamong_tukin_eligible;

-- 2. SEED VILLAGE SETTINGS (Idempotent)
INSERT INTO public.village_settings (setting_key, setting_value)
VALUES ('working_days', '{"hk": 22}'::jsonb)
ON CONFLICT (setting_key) DO UPDATE SET setting_value = EXCLUDED.setting_value;

-- 3. SEED TUKIN PARAMETERS
`;

// Extract pagu from generate_seed logic
const positions = [
    { id: 'b0000000-0000-0000-0000-000000000001', name: 'Lurah', min_ckb: 0, pagu: 1561000 },
    { id: 'b0000000-0000-0000-0000-000000000002', name: 'Carik', min_ckb: 40, pagu: 1384950 },
    { id: 'b0000000-0000-0000-0000-000000000003', name: 'Danarta', min_ckb: 39, pagu: 1223600 },
    { id: 'b0000000-0000-0000-0000-000000000004', name: 'Panata Laksana Sarta Pangripta', min_ckb: 39, pagu: 1223600 },
    { id: 'b0000000-0000-0000-0000-000000000005', name: 'Jagabaya', min_ckb: 39, pagu: 1223600 },
    { id: 'b0000000-0000-0000-0000-000000000006', name: 'Ulu-Ulu', min_ckb: 39, pagu: 1223600 },
    { id: 'b0000000-0000-0000-0000-000000000007', name: 'Kamituwa', min_ckb: 39, pagu: 1223600 },
    { id: 'b0000000-0000-0000-0000-000000000008', name: 'Dukuh', min_ckb: 38, pagu: 1140300 }
];

positions.forEach(p => {
    sql += `INSERT INTO public.tukin_parameters (position_id, effective_from, pagu_tukin, min_ckb_target)
SELECT '${p.id}', '2027-01-01'::DATE, ${p.pagu}, ${p.min_ckb}
WHERE NOT EXISTS (
    SELECT 1 FROM public.tukin_parameters 
    WHERE position_id = '${p.id}' AND effective_from = '2027-01-01'::DATE
);\n`;
});

sql += `\n-- 4. SEED AUTH.USERS (Idempotent for trusted provisioning)\n`;
const employees = [
    { profile_id: 'a0000000-0000-0000-0000-000000000001', name: 'Sunardi', pos: 'b0000000-0000-0000-0000-000000000001', role: 'user', email: 'sunardi@kalidengen.desa.id', nip: '197001012000011001' },
    { profile_id: 'a0000000-0000-0000-0000-000000000002', name: 'Muh. Masruri Mustofa', pos: 'b0000000-0000-0000-0000-000000000002', role: 'admin', email: 'carik@kalidengen.desa.id', nip: '197502022005011002' },
    { profile_id: 'a0000000-0000-0000-0000-000000000003', name: 'Viki Wulandari', pos: 'b0000000-0000-0000-0000-000000000003', role: 'user', email: 'viki@kalidengen.desa.id', nip: '198003032010012003' },
    { profile_id: 'a0000000-0000-0000-0000-000000000004', name: 'Agus Endarto', pos: 'b0000000-0000-0000-0000-000000000004', role: 'user', email: 'agus@kalidengen.desa.id', nip: '198504042015011004' },
    { profile_id: 'a0000000-0000-0000-0000-000000000005', name: 'Subarno', pos: 'b0000000-0000-0000-0000-000000000005', role: 'user', email: 'subarno@kalidengen.desa.id', nip: '199005052020011005' },
    { profile_id: 'a0000000-0000-0000-0000-000000000006', name: 'Saridi', pos: 'b0000000-0000-0000-0000-000000000006', role: 'user', email: 'saridi@kalidengen.desa.id', nip: '198806062021011006' },
    { profile_id: 'a0000000-0000-0000-0000-000000000007', name: 'Sumardi', pos: 'b0000000-0000-0000-0000-000000000007', role: 'user', email: 'sumardi@kalidengen.desa.id', nip: '198907072022011007' },
    { profile_id: 'a0000000-0000-0000-0000-000000000008', name: 'Widi Hartono', pos: 'b0000000-0000-0000-0000-000000000008', role: 'user', email: 'widi@kalidengen.desa.id', nip: '199108082023011008' },
    { profile_id: 'a0000000-0000-0000-0000-000000000009', name: 'Rendi Ardiyanto', pos: 'b0000000-0000-0000-0000-000000000008', role: 'user', email: 'rendi@kalidengen.desa.id', nip: '199509092024011009' },
    { profile_id: 'a0000000-0000-0000-0000-000000000010', name: 'Edi Supriyanto', pos: 'b0000000-0000-0000-0000-000000000008', role: 'user', email: 'edi@kalidengen.desa.id', nip: '199210102025011010' }
];

sql += `INSERT INTO auth.users (id, aud, role, email) VALUES\n`;
const userValues = employees.map(e => `  ('${e.profile_id}', 'authenticated', 'authenticated', '${e.email}')`).join(',\n');
sql += userValues + `\nON CONFLICT (id) DO NOTHING;\n\n`;

sql += `-- 5. TRUSTED PROVISIONING (Idempotent)\nDO $$\nDECLARE\n    v_emp_id UUID;\nBEGIN\n`;
employees.forEach(e => {
    sql += `    SELECT id INTO v_emp_id FROM public.employees WHERE profile_id = '${e.profile_id}';\n`;
    sql += `    IF v_emp_id IS NULL THEN\n`;
    sql += `        PERFORM public.provision_employee_identity(\n`;
    sql += `            '${e.profile_id}', '${e.role}'::public.app_profile_role, '${e.name}', '${e.nip}', '${e.pos}', '2027-01-01'::DATE\n`;
    sql += `        );\n    END IF;\n`;
});
sql += `END $$;\n\n`;

// 6. MATRICES mapping
sql += `-- 6. SEED MATRIX VERSIONS & TARGETS\n`;
const sheetToPos = {
    'CARIK': 'b0000000-0000-0000-0000-000000000002',
    'DAnarta': 'b0000000-0000-0000-0000-000000000003',
    'PALAPA': 'b0000000-0000-0000-0000-000000000004',
    'JAGABAYA': 'b0000000-0000-0000-0000-000000000005',
    'ULU-ULU': 'b0000000-0000-0000-0000-000000000006',
    'KAMITUWA': 'b0000000-0000-0000-0000-000000000007',
    'DUKUH': 'b0000000-0000-0000-0000-000000000008',
    'STAF': 'b0000000-0000-0000-0000-000000000009'
};

function escapeStr(str) {
    if(!str) return '';
    return String(str).replace(/'/g, "''").replace(/\\/g, "\\\\");
}

sql += `DO $$\nDECLARE\n    v_mat_id UUID;\n    v_grp_id UUID;\n    v_item_id UUID;\nBEGIN\n`;

for (const sheet of Object.keys(matrikData)) {
    if (!sheetToPos[sheet]) continue;
    
    const posId = sheetToPos[sheet];
    
    sql += `    SELECT id INTO v_mat_id FROM public.matrix_versions WHERE position_id = '${posId}' AND effective_from = '2027-01-01'::DATE;\n`;
    sql += `    IF v_mat_id IS NULL THEN\n`;
    sql += `        INSERT INTO public.matrix_versions (position_id, status, effective_from) VALUES ('${posId}', 'Published', '2027-01-01'::DATE) RETURNING id INTO v_mat_id;\n`;
    
    let currentGroupName = "";
    
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
        
        if (groupNum && !itemId) {
            currentGroupName = groupName;
            sql += `        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, '${escapeStr(groupName)}') RETURNING id INTO v_grp_id;\n`;
            continue;
        }
        
        if (groupNum && itemId) {
            currentGroupName = groupName;
            sql += `        INSERT INTO public.performance_groups (matrix_version_id, name) VALUES (v_mat_id, '${escapeStr(groupName)}') RETURNING id INTO v_grp_id;\n`;
        }
        
        if (itemId && itemName && currentGroupName && !isNaN(annualTarget)) {
            let monthlyTarget = Math.ceil(annualTarget / 12);
            let sumTarget = 0;
            for(let c=6; c<=17; c++) {
                if(row[c] && !isNaN(parseInt(row[c]))) sumTarget += parseInt(row[c]);
            }
            let note = "";
            if (sumTarget > 0 && sumTarget !== annualTarget) {
                note = ` -- [INKONSISTENSI SPREADSHEET] Jumlah bulan = ${sumTarget}, Annual = ${annualTarget}`;
            }

            sql += `        INSERT INTO public.performance_items (group_id, name, unit) VALUES (v_grp_id, '${escapeStr(itemName)}', '${escapeStr(unit)}') RETURNING id INTO v_item_id;\n`;
            sql += `        INSERT INTO public.performance_targets (item_id, annual_target, monthly_target) VALUES (v_item_id, ${annualTarget}, ${monthlyTarget});${note}\n`;
        }
    }
    sql += `    END IF;\n\n`;
}

sql += `END $$;\n\nCOMMIT;\n`;

fs.writeFileSync('015_seed_kalidengen.sql', sql);
console.log('015_seed_kalidengen.sql created successfully!');
