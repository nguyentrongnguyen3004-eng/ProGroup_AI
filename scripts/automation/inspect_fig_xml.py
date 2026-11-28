import docx

doc = docx.Document('file_coso_v4_perfect.docx')
p = doc.paragraphs[357]
print("Text:", p.text)
print("XML:", p._element.xml)
