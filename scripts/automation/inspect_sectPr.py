import docx

doc = docx.Document('file_coso_v4_perfect.docx')
for i, sec in enumerate(doc.sections):
    sectPr = sec._sectPr
    pgNumType = sectPr.xpath('.//w:pgNumType')
    print(f"Section {i}: pgNumType = {[p.attrib for p in pgNumType]}")
