import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

print('Testing python-docx imports and methods...')
doc = docx.Document('file_coso_v4.docx')

# Check index of Heading 1
idx_ch4 = None
idx_ch5 = None
idx_ref = None

for i, p in enumerate(doc.paragraphs):
    if p.text.strip() == "CÀI ĐẶT HỆ THỐNG":
        idx_ch4 = i
    elif p.text.strip() == "KIỂM THỬ, TRIỂN KHAI VÀ ĐÁNH GIÁ HỆ THỐNG":
        idx_ch5 = i
    elif p.text.strip() == "TÀI LIỆU THAM KHẢO":
        idx_ref = i

print(f'idx_ch4: {idx_ch4}, idx_ch5: {idx_ch5}, idx_ref: {idx_ref}')
