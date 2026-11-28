import docx

doc = docx.Document('file_coso_v4_perfect.docx')
for i, sec in enumerate(doc.sections):
    print(f"=== Sec {i} ===")
    footer = sec.footer
    for p in footer.paragraphs:
        print("  Footer P:", p._element.xml)
