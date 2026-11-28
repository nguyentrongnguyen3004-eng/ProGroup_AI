import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')

for idx, p in enumerate(doc.paragraphs):
    if p.style.name == 'Heading 1' or 'CHƯƠNG' in p.text:
        print(f"[{idx}] text='{p.text}' | style={p.style.name}")
