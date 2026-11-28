import docx

for fn in ['file_coso_v4.docx', 'file_coso_v4_backup.docx', 'file_coso_v4_updated.docx']:
    try:
        doc = docx.Document(fn)
        for i, p in enumerate(doc.paragraphs):
            if 'Tổ chức cấu trúc mã nguồn' in p.text:
                print(f'{fn} -> P{i}: text="{p.text}", style="{p.style.name}"')
    except Exception as e:
        print(f'{fn}: {e}')
