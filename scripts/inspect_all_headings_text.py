import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')

for idx, p in enumerate(doc.paragraphs):
    if p.style.name in ['Heading 1', 'Heading 2', 'Heading 3', 'Heading 4']:
        print(f"[{idx}] {p.style.name}: '{p.text}'")
