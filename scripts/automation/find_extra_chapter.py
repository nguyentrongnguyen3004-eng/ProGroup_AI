import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')
for idx in range(670, len(doc.paragraphs)):
    p = doc.paragraphs[idx]
    if 'CHƯƠNG' in p.text.upper() or p.style.name == 'Heading 1':
        print(f"[{idx}] {p.style.name}: '{p.text}'")
