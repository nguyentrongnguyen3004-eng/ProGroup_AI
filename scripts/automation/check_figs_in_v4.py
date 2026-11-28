import docx

doc = docx.Document(r'D:\Downloads\file_coso_v4.docx')
found_figs = []
for i, p in enumerate(doc.paragraphs):
    if 'Hình 4.' in p.text:
        found_figs.append((i, p.text[:50]))

print("Found Hình 4 in file_coso_v4.docx:", len(found_figs))
for i, t in found_figs[:5]:
    print(f"  [{i}] {t}")
