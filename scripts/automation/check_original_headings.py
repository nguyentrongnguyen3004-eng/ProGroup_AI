import docx

doc = docx.Document('file_coso_v4_backup.docx')
for i, p in enumerate(doc.paragraphs[185:230], 185):
    if p.style.name.startswith(('Heading', 'heading')):
        print(f'{i}: [{p.style.name}] "{p.text}"')
