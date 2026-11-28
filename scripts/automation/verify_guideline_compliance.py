import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')

print("=== 1. KIỂM TRA LỀ TRANG (PAGE MARGINS) ===")
for idx, sec in enumerate(doc.sections):
    print(f"Section {idx}: Trái={round(sec.left_margin.cm, 1)}cm, Phải={round(sec.right_margin.cm, 1)}cm, Trên={round(sec.top_margin.cm, 1)}cm, Dưới={round(sec.bottom_margin.cm, 1)}cm")

print("\n=== 2. KIỂM TRA CẤP CHƯƠNG VÀ ĐỀ MỤC ===")
for i in [188, 209, 341, 565, 660]:
    if i < len(doc.paragraphs):
        p = doc.paragraphs[i]
        r = p.runs[0] if p.runs else None
        sz = r.font.size.pt if r and r.font.size else 'None'
        bold = r.font.bold if r else 'None'
        print(f"Chương: '{p.text}' | Font={r.font.name if r else None} | Size={sz}pt | Bold={bold} | Align={p.alignment}")

print("\n=== 3. KIỂM TRA ĐỀ MỤC CẤP 1.1 (Heading 2) ===")
count_h2 = 0
for p in doc.paragraphs[188:]:
    if p.style.name == 'Heading 2' or any(p.text.startswith(f"{k}.1") for k in range(1, 6)):
        if count_h2 < 3:
            r = p.runs[0] if p.runs else None
            sz = r.font.size.pt if r and r.font.size else 'None'
            print(f"H2: '{p.text[:40]}' | Size={sz}pt | Bold={r.font.bold if r else None} | Align={p.alignment}")
            count_h2 += 1

print("\n=== 4. KIỂM TRA ĐỀ MỤC HÌNH VÀ BẢNG ===")
fig_found = 0
for p in doc.paragraphs[188:]:
    if p.text.startswith('Hình ') and fig_found < 2:
        r = p.runs[0] if p.runs else None
        sz = r.font.size.pt if r and r.font.size else 'None'
        print(f"Hình: '{p.text[:45]}' | Align={p.alignment} | Size={sz}pt | Bold={r.font.bold if r else None}")
        fig_found += 1
tbl_found = 0
for p in doc.paragraphs[188:]:
    if p.text.startswith('Bảng ') and tbl_found < 2:
        r = p.runs[0] if p.runs else None
        sz = r.font.size.pt if r and r.font.size else 'None'
        print(f"Bảng: '{p.text[:45]}' | Align={p.alignment} | Size={sz}pt | Bold={r.font.bold if r else None}")
        tbl_found += 1

print("\n=== 5. KIỂM TRA ĐOẠN VĂN (BODY PARAGRAPHS) ===")
body_count = 0
for p in doc.paragraphs[188:]:
    if len(p.text) > 100 and not p.text.startswith('Hình') and not p.text.startswith('Bảng') and not p.text.startswith('CHƯƠNG'):
        if body_count < 2:
            r = p.runs[0] if p.runs else None
            sz = r.font.size.pt if r and r.font.size else 'None'
            fl_indent = round(p.paragraph_format.first_line_indent.cm, 2) if p.paragraph_format.first_line_indent else 'None'
            print(f"Đoạn: '{p.text[:50]}...'")
            print(f"  Font={r.font.name if r else None}, Size={sz}pt, LineSpacing={p.paragraph_format.line_spacing}, Before={p.paragraph_format.space_before.pt if p.paragraph_format.space_before else None}pt, After={p.paragraph_format.space_after.pt if p.paragraph_format.space_after else None}pt, FirstLineIndent={fl_indent}cm, Align={p.alignment}")
            body_count += 1

print("\n=== 6. KIỂM TRA BẢNG BIỂU (TABLES) ===")
tbl = doc.tables[1]
c = tbl.rows[0].cells[0]
p = c.paragraphs[0]
r = p.runs[0] if p.runs else None
sz = r.font.size.pt if r and r.font.size else 'None'
print(f"Table Header Cell: Font={r.font.name if r else None}, Size={sz}pt, Bold={r.font.bold if r else None}, LineSpacing={p.paragraph_format.line_spacing}, Before={p.paragraph_format.space_before.pt if p.paragraph_format.space_before else 0}pt, After={p.paragraph_format.space_after.pt if p.paragraph_format.space_after else 0}pt")
c2 = tbl.rows[1].cells[0]
p2 = c2.paragraphs[0]
r2 = p2.runs[0] if p2.runs else None
sz2 = r2.font.size.pt if r2 and r2.font.size else 'None'
print(f"Table Body Cell: Font={r2.font.name if r2 else None}, Size={sz2}pt, Bold={r2.font.bold if r2 else None}, LineSpacing={p2.paragraph_format.line_spacing}, Before={p2.paragraph_format.space_before.pt if p2.paragraph_format.space_before else 0}pt, After={p2.paragraph_format.space_after.pt if p2.paragraph_format.space_after else 0}pt")
