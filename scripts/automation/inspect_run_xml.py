import docx

doc = docx.Document('file_coso_v4_perfect.docx')
p = doc.paragraphs[190]
print("Text:", p.text[:100])
print("Runs count:", len(p.runs))
for i, r in enumerate(p.runs):
    xml = r._element.xml
    if 'drawing' in xml or 'graphic' in xml or 'shape' in xml or 'pict' in xml:
        print(f"Run {i} has image xml: {xml[:200]}")
