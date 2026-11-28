import docx

doc = docx.Document('ProGroup_AI.docx')
for idx, p in enumerate(doc.paragraphs):
    txt_u = p.text.strip().upper()
    if p.style.name == 'Heading 1' or txt_u.startswith('CHƯƠNG'):
        print(f"[{idx}] {p.style.name}: '{p.text}'")
