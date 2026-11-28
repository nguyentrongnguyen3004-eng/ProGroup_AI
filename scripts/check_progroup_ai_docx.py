import docx

doc = docx.Document('ProGroup_AI.docx')
print("Total paragraphs:", len(doc.paragraphs))
for i in [179, 180, 201, 202, 333, 334]:
    if i < len(doc.paragraphs):
        p = doc.paragraphs[i]
        print(f"[{i}] {p.style.name}: '{p.text[:60]}'")
