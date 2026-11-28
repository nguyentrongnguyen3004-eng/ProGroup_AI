import docx

doc = docx.Document('file_coso_v4.docx')
print('=== VERIFYING FILE_COSO_V4.DOCX ===')

# 1. Check headings
print('--- Checking Headings in Ch4 & Ch5 ---')
for p in doc.paragraphs:
    if p.style.name.startswith('Heading') and any(k in p.text for k in ['Tổ chức', 'Cấu trúc', 'Cài đặt', 'Giao diện', 'Kiểm thử', 'Triển khai', 'Đánh giá']):
        print(f'{p.style.name}: "{p.text}"')

# 2. Check figures
print('--- Checking Figures ---')
figs = [p.text for p in doc.paragraphs if p.text.strip().startswith('Hình 4.')]
print(f'Total figures found: {len(figs)}')
for f in figs:
    print('  ', f)
