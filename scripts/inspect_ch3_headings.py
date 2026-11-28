import docx

doc = docx.Document('file_coso_v4_perfect.docx')
in_ch3 = False
for idx, p in enumerate(doc.paragraphs):
    txt = p.text.strip()
    if 'CHƯƠNG 3' in txt or 'THIẾT KẾ HỆ THỐNG' in txt:
        in_ch3 = True
        print(f"[{idx}] {txt}")
    elif 'CHƯƠNG 4' in txt or 'CÀI ĐẶT HỆ THỐNG' in txt:
        in_ch3 = False
        print(f"[{idx}] {txt}")
    elif in_ch3 and (p.style.name.startswith('Heading') or any(txt.startswith(f"3.{k}") for k in range(1, 10))):
        print(f"  [{idx}] {p.style.name}: {txt[:80]}")
