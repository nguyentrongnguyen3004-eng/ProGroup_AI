import docx

doc = docx.Document('ProGroup_AI.docx')
for idx in [45, 54, 59, 63, 66, 159, 190, 217, 220, 221, 241, 242, 373, 374]:
    p = doc.paragraphs[idx]
    numPr = p._element.xpath('.//w:numPr')
    num_str = numPr[0].xml if numPr else "None"
    print(f"[{idx}] {p.style.name}: '{p.text[:40]}' | numPr: {num_str}")
