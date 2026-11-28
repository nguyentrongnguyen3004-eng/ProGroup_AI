import docx

doc = docx.Document('file_coso_v4.docx')
for i, p in enumerate(doc.paragraphs):
    if any(k in p.text.lower() for k in ['chương 1', 'chương 2', 'chương 3', '1.1', '2.1', '3.1']):
        print(f'{i}: [{p.style.name}] "{p.text.strip()}"')
