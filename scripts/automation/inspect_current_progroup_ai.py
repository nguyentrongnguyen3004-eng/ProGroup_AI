import docx

doc = docx.Document('ProGroup_AI.docx')
print("Total paragraphs in ProGroup_AI.docx:", len(doc.paragraphs))

for idx, p in enumerate(doc.paragraphs):
    if p.style.name.startswith('Heading') or 'CHƯƠNG' in p.text.upper():
        print(f"[{idx}] {p.style.name}: '{p.text[:60]}'")
