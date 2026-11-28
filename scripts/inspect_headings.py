import docx

doc = docx.Document('file_coso_v4_updated.docx')
for i, p in enumerate(doc.paragraphs):
    if 'Tổ chức cấu trúc mã nguồn' in p.text:
        print(f'P{i}: text="{p.text}", style="{p.style.name}"')
        print('XML:', p._p.xml[:500])
    if 'Cấu trúc mã nguồn Backend' in p.text:
        print(f'P{i}: text="{p.text}", style="{p.style.name}"')
        print('XML:', p._p.xml[:500])
