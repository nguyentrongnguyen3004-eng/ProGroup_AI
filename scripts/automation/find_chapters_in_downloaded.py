import docx

doc = docx.Document(r'D:\Downloads\file_coso_v4.docx')
for idx, p in enumerate(doc.paragraphs):
    if p.style.name == 'Heading 1' or 'CHƯƠNG' in p.text.upper():
        print(f"[{idx}] {p.style.name}: '{p.text}'")
