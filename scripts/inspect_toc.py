import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')
for idx in range(65, 115):
    p = doc.paragraphs[idx]
    if 'CHƯƠNG' in p.text or p.style.name.startswith('toc'):
        print(f"[{idx}] {p.style.name}: {p.text[:60]}")
