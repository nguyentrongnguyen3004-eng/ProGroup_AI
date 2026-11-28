import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')
for idx in range(188, 205):
    p = doc.paragraphs[idx]
    if len(p.text.strip()) > 50:
        print(f"[{idx}] Text: {p.text.strip()[:60]}...")
        print(f"      Align: {p.alignment}, Indent: {p.paragraph_format.first_line_indent}, SpaceAfter: {p.paragraph_format.space_after}")
        for r in p.runs[:2]:
            sz = r.font.size.pt if r.font.size else None
            print(f"      Run: text='{r.text[:20]}', font={r.font.name}, size={sz}")
        break
