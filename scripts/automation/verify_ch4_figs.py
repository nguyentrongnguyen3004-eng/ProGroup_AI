import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')
found_figs = []
for idx, p in enumerate(doc.paragraphs):
    txt = p.text.strip()
    if txt.startswith('Hình 4.'):
        found_figs.append((idx, txt[:60]))

print(f"Total Chapter 4 Figures found: {len(found_figs)}")
for idx, title in found_figs:
    print(f"  [{idx}] {title}")
