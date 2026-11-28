import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')

for idx in range(560, 606):
    p = doc.paragraphs[idx]
    print(f"[{idx}] {p.style.name}: {p.text[:60]}")
