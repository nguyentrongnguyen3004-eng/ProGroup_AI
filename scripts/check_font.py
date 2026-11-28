import docx

doc = docx.Document('file_coso_v4.docx')
for p in doc.paragraphs[559:563]:
    print(f'P: {p.text[:60]}...')
    for r in p.runs[:2]:
        font_name = r.font.name or 'default'
        font_size = r.font.size.pt if r.font.size else 'default'
        print(f'   Run: \"{r.text[:30]}\", font={font_name}, size={font_size}, italic={r.italic}, bold={r.bold}')
