import docx

doc = docx.Document('file_coso_v4_perfect.docx')
print("=== TẤT CẢ CAPTION HÌNH ===")
for idx, p in enumerate(doc.paragraphs):
    txt = p.text.strip()
    if txt.startswith('Hình'):
        print(f"[{idx}] {txt[:70]}")

print("\n=== TẤT CẢ CAPTION BẢNG ===")
for idx, p in enumerate(doc.paragraphs):
    txt = p.text.strip()
    if txt.startswith('Bảng'):
        print(f"[{idx}] {txt[:70]}")
