import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')
for i, p in enumerate(doc.paragraphs):
    if p.style.name.startswith('Heading') or 'CHƯƠNG' in p.text:
        numPr = p._element.xpath('.//w:numPr')
        num_xml = numPr[0].xml if numPr else "None"
        print(f"[{i}] {p.style.name} | Text: '{p.text[:60]}' | NumPr: {num_xml}")
