import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')

for idx, p in enumerate(doc.paragraphs):
    if 'THIẾT KẾ CƠ SỞ DỮ LIỆU' in p.text:
        print(f"[{idx}] {p.style.name}: {p.text}")
