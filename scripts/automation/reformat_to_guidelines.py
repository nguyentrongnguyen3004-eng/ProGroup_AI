import docx
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls
import re, os

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

def reformat_document(src_path, dst_path):
    print(f"=== REFORMATTING DOCUMENT: {src_path} -> {dst_path} ===")
    doc = docx.Document(src_path)

    # 1. YÊU CẦU CHUNG: LỀ TRANG
    # Trái: 3.5 cm, Phải: 2.5 cm, Trên: 2.5 cm, Dưới: 2.5 cm
    print("1. Setting page margins (Left 3.5cm, Right 2.5cm, Top 2.5cm, Bottom 2.5cm)...")
    for sec in doc.sections:
        sec.top_margin = Cm(2.5)
        sec.bottom_margin = Cm(2.5)
        sec.left_margin = Cm(3.5)
        sec.right_margin = Cm(2.5)
        sec.page_width = Cm(21.0)
        sec.page_height = Cm(29.7)

    # Configure base styles
    print("2. Configuring base styles...")
    for s_name in ['Normal', 'Body Text', 'Normal (Web)']:
        if s_name in doc.styles:
            s = doc.styles[s_name]
            s.font.name = 'Times New Roman'
            s.font.size = Pt(13)
            s.font.color.rgb = RGBColor(0, 0, 0)
            s.paragraph_format.line_spacing = 1.3
            s.paragraph_format.space_before = Pt(6)
            s.paragraph_format.space_after = Pt(6)

    # Find where main body starts
    start_main_idx = 188
    for idx, p in enumerate(doc.paragraphs):
        txt_u = p.text.strip().upper()
        if ('GIỚI THIỆU ĐỀ TÀI' in txt_u or 'CHƯƠNG 1' in txt_u) and idx > 150:
            start_main_idx = idx
            break

    print(f"Main body starts at paragraph index: {start_main_idx}")

    # Process Front Matter (0 to start_main_idx - 1)
    for i in range(start_main_idx):
        p = doc.paragraphs[i]
        st = p.style.name
        for r in p.runs:
            r.font.name = 'Times New Roman'
        
        # TOC items
        if st.startswith('toc') or st.startswith('table of figures'):
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.space_before = Pt(2)
            p.paragraph_format.space_after = Pt(2)
            for r in p.runs:
                r.font.size = Pt(13)

    # Process Main Body Content
    print("3. Formatting Main Chapters (Headings, Paragraphs, Bullets, Figures, Captions)...")
    for i in range(start_main_idx, len(doc.paragraphs)):
        p = doc.paragraphs[i]
        txt = p.text.strip()
        st = p.style.name

        for r in p.runs:
            r.font.name = 'Times New Roman'

        if not txt:
            # Empty line or standalone image
            has_image = any('graphic' in r._element.xml or 'drawing' in r._element.xml for r in p.runs)
            if has_image:
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                p.paragraph_format.space_before = Pt(6)
                p.paragraph_format.space_after = Pt(4)
                p.paragraph_format.first_line_indent = Cm(0)
            continue

        # A. CẤP CHƯƠNG (Heading 1)
        # Cỡ chữ 18, in hoa, canh giữa, tô đậm
        is_chapter = (st == 'Heading 1') or txt.startswith('CHƯƠNG') or txt in [
            'GIỚI THIỆU ĐỀ TÀI', 'CƠ SỞ LÝ THUYẾT', 'THIẾT KẾ HỆ THỐNG', 'CÀI ĐẶT HỆ THỐNG', 'KIỂM THỬ, TRIỂN KHAI VÀ ĐÁNH GIÁ HỆ THỐNG'
        ]
        if is_chapter:
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(18)
            p.paragraph_format.space_after = Pt(12)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)
            
            new_text = txt.upper()
            if 'GIỚI THIỆU' in new_text and not new_text.startswith('CHƯƠNG 1'):
                new_text = 'CHƯƠNG 1: ' + new_text.replace('CHƯƠNG 1:', '').strip()
            elif 'CƠ SỞ LÝ THUYẾT' in new_text and not new_text.startswith('CHƯƠNG 2'):
                new_text = 'CHƯƠNG 2: ' + new_text.replace('CHƯƠNG 2:', '').strip()
            elif 'THIẾT KẾ' in new_text and not new_text.startswith('CHƯƠNG 3'):
                new_text = 'CHƯƠNG 3: ' + new_text.replace('CHƯƠNG 3:', '').strip()
            elif 'CÀI ĐẶT' in new_text and not new_text.startswith('CHƯƠNG 4'):
                new_text = 'CHƯƠNG 4: ' + new_text.replace('CHƯƠNG 4:', '').strip()
            elif 'KIỂM THỬ' in new_text and not new_text.startswith('CHƯƠNG 5'):
                new_text = 'CHƯƠNG 5: ' + new_text.replace('CHƯƠNG 5:', '').strip()

            p.text = new_text
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(18)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)
            print(f"  [Chapter 18pt Bold] {p.text}")
            continue

        # B. ĐỀ MỤC CẤP 1.1 (Heading 2)
        # Cỡ chữ 14, in hoa, tô đậm, canh trái
        is_h2 = (st == 'Heading 2') or (re.match(r'^\d+\.\d+\.\s+[^\.]+$', txt) and len(txt) < 120)
        if is_h2:
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.space_before = Pt(12)
            p.paragraph_format.space_after = Pt(6)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)
            p.text = txt.upper()
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(14)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)
            continue

        # C. ĐỀ MỤC CẤP 1.1.1 VÀ 1.1.1.1 (Heading 3, 4, 5)
        # Cỡ chữ 13, in thường, tô đậm, canh trái
        is_h3 = (st in ['Heading 3', 'Heading 4', 'Heading 5']) or (re.match(r'^\d+\.\d+\.\d+(\.\d+)?\.\s+', txt) and len(txt) < 150)
        if is_h3:
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.space_before = Pt(6)
            p.paragraph_format.space_after = Pt(6)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(13)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)
            continue

        # D. ĐỀ MỤC HÌNH ẢNH: Đặt phía dưới hình, canh giữa
        # "Hình X.Y: Tên hình"
        if txt.startswith('Hình ') and any(txt.startswith(f'Hình {k}') for k in range(1, 10)):
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(4)
            p.paragraph_format.space_after = Pt(10)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)
            m = re.match(r'^(Hình\s+\d+\.\d+)[.:]\s*(.+)$', txt)
            if m:
                p.text = f"{m.group(1)}: {m.group(2)}"
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(13)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)
            continue

        # E. ĐỀ MỤC BẢNG BIỂU: Đặt phía trên bảng, canh giữa
        # "Bảng X.Y: Tên bảng"
        if txt.startswith('Bảng ') and any(txt.startswith(f'Bảng {k}') for k in range(1, 10)):
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(10)
            p.paragraph_format.space_after = Pt(4)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)
            m = re.match(r'^(Bảng\s+\d+\.\d+)[.:]\s*(.+)$', txt)
            if m:
                p.text = f"{m.group(1)}: {m.group(2)}"
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(13)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)
            continue

        # F. BULLET LISTS
        # Bullet cấp 1: Dấu gạch “-”; Line spacing Multiple at 1.3, Before 6pt, After 6pt, canh đều 2 bên; Position 0.3 cm, Text indent 0.8 cm
        if txt.startswith('- ') or txt.startswith('– '):
            p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.space_before = Pt(6)
            p.paragraph_format.space_after = Pt(6)
            p.paragraph_format.left_indent = Cm(0.8)
            p.paragraph_format.first_line_indent = Cm(-0.5)
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(13)
                r.font.color.rgb = RGBColor(0, 0, 0)
            continue

        # Bullet cấp 2: Dấu “+”; Position 0.8 cm, Text indent 1.3 cm
        if txt.startswith('+ '):
            p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.space_before = Pt(6)
            p.paragraph_format.space_after = Pt(6)
            p.paragraph_format.left_indent = Cm(1.3)
            p.paragraph_format.first_line_indent = Cm(-0.5)
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(13)
                r.font.color.rgb = RGBColor(0, 0, 0)
            continue

        # G. HÌNH ẢNH ĐỨNG ĐỘC LẬP
        has_image = any('graphic' in r._element.xml or 'drawing' in r._element.xml for r in p.runs)
        if has_image:
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(6)
            p.paragraph_format.space_after = Pt(4)
            p.paragraph_format.first_line_indent = Cm(0)
            continue

        # H. ĐOẠN VĂN THƯỜNG (BODY PARAGRAPH)
        # Viết dạng đoạn văn, thụt vào đầu dòng mỗi đoạn. Cỡ chữ 13, Line spacing Multiple at 1.3, Before 6pt, After 6pt, canh đều 2 bên.
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.line_spacing = 1.3
        p.paragraph_format.space_before = Pt(6)
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.first_line_indent = Cm(0.8)
        for r in p.runs:
            r.font.name = 'Times New Roman'
            r.font.size = Pt(13)
            r.font.color.rgb = RGBColor(0, 0, 0)

    # 4. ĐỊNH DẠNG BẢNG BIỂU (TABLES)
    # Nội dung trong bảng có cỡ chữ 12, Line spacing Multiple at 1.3, Before 0pt, After 0pt. Lặp lại tiêu đề bảng nếu sang trang mới.
    print("4. Formatting all Tables (Size 12, Line Spacing 1.3, Before 0pt, After 0pt, Repeat Header Row)...")
    for tbl in doc.tables:
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        if len(tbl.rows) > 0:
            header_tr = tbl.rows[0]._tr.get_or_add_trPr()
            header_tr.append(parse_xml(f'<w:tblHeader {nsdecls("w")}/>'))
            header_tr.append(parse_xml(f'<w:cantSplit {nsdecls("w")}/>'))

        for row_idx, row in enumerate(tbl.rows):
            trPr = row._tr.get_or_add_trPr()
            trPr.append(parse_xml(f'<w:cantSplit {nsdecls("w")}/>'))
            is_header = (row_idx == 0)
            for cell in row.cells:
                cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
                set_cell_margins(cell, top=100, bottom=100, left=150, right=150)
                for p in cell.paragraphs:
                    p.paragraph_format.line_spacing = 1.3
                    p.paragraph_format.space_before = Pt(0)
                    p.paragraph_format.space_after = Pt(0)
                    p.paragraph_format.first_line_indent = Cm(0)
                    for r in p.runs:
                        r.font.name = 'Times New Roman'
                        r.font.size = Pt(12)
                        if is_header:
                            r.font.bold = True

    doc.save(dst_path)
    print(f"SUCCESSFULLY generated: {dst_path} ({os.path.getsize(dst_path)} bytes)!")

if __name__ == '__main__':
    reformat_document('file_coso_v4_perfect.docx', 'file_coso_v4_chuan_format.docx')
