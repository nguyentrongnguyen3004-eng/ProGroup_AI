import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')
for idx, p in enumerate(doc.paragraphs):
    if p.style.name == 'Heading 1':
        print(f"[{idx}] text='{p.text}' | runs={len(p.runs)} | xml={p._element.xml[:120]}")
