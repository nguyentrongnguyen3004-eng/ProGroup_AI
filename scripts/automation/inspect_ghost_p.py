import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')
for i in [200, 577]:
    p = doc.paragraphs[i]
    print(f"=== Paragraph {i} ===")
    print(p._element.xml)
