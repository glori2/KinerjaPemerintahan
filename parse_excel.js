const XLSX = require('xlsx');
const fs = require('fs');

const files = [
  'HITUNGAN TUNJANGAN KINERJA.xlsx',
  'MATRIK TUKIN KALIDENGEN.xlsx',
  'simulasi penghitungan kinerja.xlsx'
];

files.forEach(file => {
  if (fs.existsSync(file)) {
    const workbook = XLSX.readFile(file);
    const result = {};
    workbook.SheetNames.forEach(sheetName => {
      const sheet = workbook.Sheets[sheetName];
      result[sheetName] = XLSX.utils.sheet_to_json(sheet, { header: 1 });
    });
    fs.writeFileSync(`${file}.json`, JSON.stringify(result, null, 2));
    console.log(`Parsed ${file}`);
  }
});
