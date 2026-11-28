import docx

doc = docx.Document('file_coso_v4_perfect.docx')
for i in range(560, 567):
    p = doc.paragraphs[i]
    print(f"[{i}] {p.style.name}: {p.text}")
