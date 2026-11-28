import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')

chapters = []
for idx, p in enumerate(doc.paragraphs):
    if p.style.name == 'Heading 1' or 'CHƯƠNG' in p.text:
        chapters.append((idx, p.text, p._element.xpath('.//w:numPr')))

for idx, txt, numPr in chapters:
    xml_str = numPr[0].xml if numPr else "None"
    print(f"[{idx}] Text='{txt}' | numPr={xml_str}")
