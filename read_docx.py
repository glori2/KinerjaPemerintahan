import zipfile
import re

def extract_text_from_docx(docx_path):
    with zipfile.ZipFile(docx_path) as docx:
        xml_content = docx.read('word/document.xml').decode('utf-8')
        # Remove XML tags
        text = re.sub('<[^<]+>', ' ', xml_content)
        # Clean up multiple spaces
        text = re.sub('\s+', ' ', text)
        return text

try:
    text = extract_text_from_docx('DRAFT PL-TUNJANGAN KINERJA  Template 060826 (Repaired).docx')
    print("Found text. Length:", len(text))
    
    # Let's search for "Evaluasi", "Lurah", "Carik", "Jurnal"
    sentences = [s.strip() for s in text.split('.') if s.strip()]
    for s in sentences:
        s_lower = s.lower()
        if 'evaluasi' in s_lower or 'jurnal' in s_lower or 'penilaian' in s_lower or 'carik' in s_lower or 'lurah' in s_lower:
            if len(s) > 20 and len(s) < 300:
                print("-", s)
except Exception as e:
    print(e)
