import docx

doc = docx.Document(r'D:\Downloads\file_coso_v4.docx')
for i in range(215, 250):
    p = doc.paragraphs[i]
    print(f"[{i}] {p.style.name}: {p.text}")
