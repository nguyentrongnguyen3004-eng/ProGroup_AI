import docx

doc = docx.Document('file_coso_v4_updated.docx')
print(f"Total paragraphs: {len(doc.paragraphs)}")
print(f"Total tables: {len(doc.tables)}")

print("\n--- CHECKING HEADINGS IN CHAPTER 4 & 5 ---")
for i, p in enumerate(doc.paragraphs):
    if p.style.name in ['Heading 1', 'Heading 2', 'Heading 3']:
        if any(kw in p.text for kw in ['CÀI ĐẶT', 'KIỂM THỬ', 'Tổ chức', 'Cấu trúc', 'Cài đặt', 'Giao diện', 'Phân hệ', 'Môi trường', 'Đóng gói', 'Triển khai', 'Đánh giá', 'Ưu điểm', 'Hạn chế', 'Hướng phát triển']):
            print(f"P{i:3d} [{p.style.name}]: \"{p.text}\"")

print("\n--- CHECKING DIRECTORY TREES ---")
for i, p in enumerate(doc.paragraphs):
    if "ProGroup_AI.API/" in p.text or "progroup_ai_frontend/lib/" in p.text:
        lines = p.text.split("\n")
        print(f"Tree paragraph P{i}: {len(lines)} lines")
        for line_no, l in enumerate(lines):
            print(f"   L{line_no+1:2d} (len {len(l):2d}): {l}")
