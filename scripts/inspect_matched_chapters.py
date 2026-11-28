import docx

doc = docx.Document('ProGroup_AI.docx')
for i in [220, 227, 232, 241, 373]:
    p = doc.paragraphs[i]
    print(f"[{i}] {p.style.name}: '{p.text}'")
