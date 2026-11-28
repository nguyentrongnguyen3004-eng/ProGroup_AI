import docx

doc = docx.Document('ProGroup_AI.docx')
h1_style = doc.styles['Heading 1']
numPr = h1_style._element.xpath('.//w:numPr')
print("Heading 1 style numPr:", numPr[0].xml if numPr else "None")

h2_style = doc.styles['Heading 2']
numPr2 = h2_style._element.xpath('.//w:numPr')
print("Heading 2 style numPr:", numPr2[0].xml if numPr2 else "None")
