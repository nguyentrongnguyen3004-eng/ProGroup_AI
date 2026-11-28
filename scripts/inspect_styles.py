import docx

doc = docx.Document('file_coso_v4_updated.docx')
styles = doc.styles
h2_style = styles['Heading 2']
print("h2_style:", h2_style.name)
print("h2_style._element.xml:\n", h2_style._element.xml[:1000])

try:
    numbering = doc.part.numbering_part
    print("Numbering part found!")
except Exception as e:
    print("Numbering part:", e)
