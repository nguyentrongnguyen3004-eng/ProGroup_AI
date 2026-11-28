import docx

doc = docx.Document('file_coso_v4_updated.docx')
print("--- Full Heading 2 style XML ---")
print(doc.styles['Heading 2']._element.xml)

print("\n--- Let's look at Heading 2 in Chapter 1, 2, 3 ---")
for i, p in enumerate(doc.paragraphs):
    if p.style.name == 'Heading 2':
        print(f"P{i} [H2]: text='{p.text}'")
        if i < 400: # first few
            print("  pPr:", p._p.pPr.xml if p._p.pPr is not None else "None")
        if i > 100:
            break
