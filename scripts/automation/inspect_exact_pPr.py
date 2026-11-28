import docx

doc = docx.Document('ProGroup_AI.docx')
for i in [220, 241]:
    p = doc.paragraphs[i]
    pPr = p._element.find('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}pPr')
    import xml.etree.ElementTree as ET
    print(f"=== Paragraph {i}: {p.text} ===")
    print(ET.tostring(pPr, encoding='unicode'))
