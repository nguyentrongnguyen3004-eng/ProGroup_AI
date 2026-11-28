import docx

doc = docx.Document('ProGroup_AI.docx')
for i in range(215, 255):
    p = doc.paragraphs[i]
    print(f"[{i}] {p.style.name}: {p.text}")
