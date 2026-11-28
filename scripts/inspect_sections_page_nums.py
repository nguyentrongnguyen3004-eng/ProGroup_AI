import docx

doc = docx.Document('file_coso_v4_perfect.docx')
print(f"Total sections: {len(doc.sections)}")
for i, sec in enumerate(doc.sections):
    print(f"\n--- Section {i} ---")
    print(f"Start type: {sec.start_type}")
    print(f"Margins: Left={round(sec.left_margin.cm, 1)}, Right={round(sec.right_margin.cm, 1)}, Top={round(sec.top_margin.cm, 1)}, Bottom={round(sec.bottom_margin.cm, 1)}")
    footer = sec.footer
    print(f"Footer paragraphs: {len(footer.paragraphs)}")
    for fp in footer.paragraphs:
        print(f"  Footer text: '{fp.text}', xml: {fp._element.xml[:120]}")
