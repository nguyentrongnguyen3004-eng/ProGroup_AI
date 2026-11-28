import docx

doc = docx.Document('ProGroup_AI.docx')
for i in [220, 241, 373, 599, 694]:
    p = doc.paragraphs[i]
    print(f"=== Paragraph {i}: {p.text} ===")
    print(p._element.xml[:300])
