import docx

doc = docx.Document('file_coso_v4.docx')
for i, p in enumerate(doc.paragraphs):
    if i > 185 and p.style.name.startswith(('Heading 1', 'heading 1')):
        print(f'{i}: [{p.style.name}] "{p.text.strip()}"')
