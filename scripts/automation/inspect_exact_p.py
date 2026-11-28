import docx

doc = docx.Document('file_coso_v4_updated.docx')
for i, p in enumerate(doc.paragraphs):
    if 'Tổ chức cấu trúc mã nguồn' in p.text:
        print(f"P{i} Full Text: {repr(p.text)}")
        print("Runs:", [repr(r.text) for r in p.runs])
        print("XML:\n", p._p.xml)
        break
