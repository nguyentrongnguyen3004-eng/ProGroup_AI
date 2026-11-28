import docx

doc = docx.Document('file_coso_v4_backup.docx')
sec = doc.sections[0]
print(f"Page width: {sec.page_width.inches} in ({sec.page_width.pt} pt)")
print(f"Page height: {sec.page_height.inches} in ({sec.page_height.pt} pt)")
print(f"Left margin: {sec.left_margin.inches} in ({sec.left_margin.pt} pt)")
print(f"Right margin: {sec.right_margin.inches} in ({sec.right_margin.pt} pt)")
usable_width = sec.page_width.inches - sec.left_margin.inches - sec.right_margin.inches
print(f"Usable width: {usable_width} in ({usable_width * 72} pt)")
