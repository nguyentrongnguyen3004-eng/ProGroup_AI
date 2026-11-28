import docx
from docx.shared import Pt, Cm, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls, qn
import os, re

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

def build_perfect_document():
    src_file = 'file_coso_v4_perfect.docx'
    dst_file = 'file_coso_v4_chuan_format.docx'
    
    print(f"=== FULL BUILD & REFORMAT: {src_file} -> {dst_file} ===")
    doc = docx.Document(src_file)

    # -------------------------------------------------------------
    # 1. YÊU CẦU CHUNG: LỀ TRANG & KHỔ GIẤY A4
    # Trái: 3.5 cm, Phải: 2.5 cm, Trên: 2.5 cm, Dưới: 2.5 cm
    # -------------------------------------------------------------
    print("Step 1: Setting page margins (Left 3.5cm, Right 2.5cm, Top 2.5cm, Bottom 2.5cm, A4)...")
    for sec in doc.sections:
        sec.top_margin = Cm(2.5)
        sec.bottom_margin = Cm(2.5)
        sec.left_margin = Cm(3.5)
        sec.right_margin = Cm(2.5)
        sec.page_width = Cm(21.0)
        sec.page_height = Cm(29.7)
        
        # Đảm bảo footer canh giữa cho số trang
        for fp in sec.footer.paragraphs:
            fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
            for fr in fp.runs:
                fr.font.name = 'Times New Roman'
                fr.font.size = Pt(12)

    # -------------------------------------------------------------
    # 2. XÓA BỎ CÁC ĐOẠN PAGE BREAK RỖNG BỊ GẮN NHẦM STYLE HEADING 1
    # -------------------------------------------------------------
    print("Step 2: Cleaning ghost Heading 1 page breaks...")
    for p in doc.paragraphs:
        if p.style.name == 'Heading 1' and not p.text.strip():
            p.style = doc.styles['Normal']
            pPr = p._element.get_or_add_pPr()
            for np in pPr.findall(qn('w:numPr')):
                pPr.remove(np)

    # -------------------------------------------------------------
    # 3. CHÈN MỤC THIẾT KẾ CƠ SỞ DỮ LIỆU VÀ SƠ ĐỒ ERD VÀO CHƯƠNG 3
    # Vị trí: Trước CHƯƠNG 4: CÀI ĐẶT HỆ THỐNG
    # -------------------------------------------------------------
    print("Step 3: Checking and inserting Database Design (ERD) into Chapter 3...")
    ch4_idx = None
    for idx, p in enumerate(doc.paragraphs):
        txt_u = p.text.strip().upper()
        if ('CHƯƠNG 4' in txt_u or 'CÀI ĐẶT HỆ THỐNG' in txt_u) and idx > 300:
            ch4_idx = idx
            break

    if ch4_idx:
        target_p = doc.paragraphs[ch4_idx]
        def add_p_before(text, style='Normal'):
            return target_p.insert_paragraph_before(text, style=style)

        # 3.5. THIẾT KẾ CƠ SỞ DỮ LIỆU (không hardcode số '3.5.' trong text để Word tự đánh số chuẩn)
        add_p_before('THIẾT KẾ CƠ SỞ DỮ LIỆU', style='Heading 2')
        
        add_p_before(
            'Cơ sở dữ liệu của hệ thống ProGroup AI được xây dựng trên hệ quản trị cơ sở dữ liệu quan hệ Microsoft SQL Server với tên gọi ProjectRegistrationDB. Mô hình dữ liệu bao gồm 17 bảng thực thể được thiết kế chuẩn hóa, đảm bảo tính toàn vẹn tham chiếu, tối ưu hóa truy vấn thông qua các chỉ mục (indexes) và ràng buộc khóa ngoại (foreign keys).'
        )
        add_p_before(
            'Toàn bộ kiến trúc dữ liệu được phân chia thành 3 phân hệ chức năng cốt lõi nhằm phục vụ xuyên suốt toàn bộ vòng đời đăng ký đồ án: (1) Phân hệ Người dùng, Vai trò và Xác thực tài khoản; (2) Phân hệ Quản lý Đào tạo, Học phần và Phân công giảng dạy; (3) Phân hệ Quản lý Đề tài, Đăng ký đề tài, Nhóm đồ án và Báo cáo tiến độ.'
        )

        # 3.5.1. Sơ đồ thực thể liên kết (ERD)
        add_p_before('Sơ đồ thực thể liên kết (ERD - Entity Relationship Diagram)', style='Heading 3')
        add_p_before(
            'Nhằm đảm bảo tính trực quan, độ sắc nét và khả năng theo dõi chi tiết cấu trúc các thuộc tính của 17 bảng trên khổ giấy A4, sơ đồ ERD được chuẩn hóa và trình bày thông qua 3 phân hệ cơ sở dữ liệu chuyên biệt dưới đây:'
        )

        # Module 1: Người dùng & Xác thực
        add_p_before('- Phân hệ Người dùng, Vai trò và Xác thực:')
        add_p_before(
            'Bao gồm các thực thể NguoiDungs, VaiTros, GiangViens, SinhViens và PasswordResetOtps. Phân hệ này chịu trách nhiệm lưu trữ hồ sơ người dùng, phân quyền truy cập theo 5 nhóm vai trò và cơ chế xác thực an toàn bằng mã OTP băm SHA-256 kết hợp mã hóa BCrypt cho mật khẩu.'
        )
        p_img1 = add_p_before('')
        r_img1 = p_img1.add_run()
        if os.path.exists('docs/database/erd/ProGroupAI_ERD_Module_01.png'):
            r_img1.add_picture('docs/database/erd/ProGroupAI_ERD_Module_01.png', width=Inches(6.2))
        add_p_before('Hình 3.28: Sơ đồ quan hệ thực thể (ERD) - Phân hệ Người dùng và Phân quyền', style='Caption')

        # Module 2: Đào tạo & Phân công
        add_p_before('- Phân hệ Quản lý Đào tạo, Học phần và Phân công:')
        add_p_before(
            'Bao gồm các thực thể Khoas, HocPhans, HocKys, LopHocPhans, PhanCongGiangViens, SinhVienLopHocPhans, DotImports và LoiImports. Phân hệ này cho phép quản lý cơ cấu học phần, phân công giảng viên hướng dẫn và giảng viên phản biện, cũng như theo dõi lịch sử nạp dữ liệu danh sách đào tạo hàng loạt.'
        )
        p_img2 = add_p_before('')
        r_img2 = p_img2.add_run()
        if os.path.exists('docs/database/erd/ProGroupAI_ERD_Module_02.png'):
            r_img2.add_picture('docs/database/erd/ProGroupAI_ERD_Module_02.png', width=Inches(6.2))
        add_p_before('Hình 3.29: Sơ đồ quan hệ thực thể (ERD) - Phân hệ Quản lý Đào tạo và Lớp học phần', style='Caption')

        # Module 3: Đề tài & Tiến độ
        add_p_before('- Phân hệ Đề tài, Đăng ký, Nhóm đồ án và Tiến độ:')
        add_p_before(
            'Bao gồm các thực thể DotDangKyDoAns, DeTaiDoAns, NhomDoAns, ThanhVienNhoms, DangKyDeTais, BaoCaoTienDos, ThongBaos và AIRequests. Phân hệ này quản lý toàn diện đợt mở đăng ký, danh mục đề tài, quy trình đăng ký nhóm, bình duyệt đề tài đề xuất, gửi báo cáo tiến độ tuần và lịch sử nhật ký trợ lý AI.'
        )
        p_img3 = add_p_before('')
        r_img3 = p_img3.add_run()
        if os.path.exists('docs/database/erd/ProGroupAI_ERD_Module_03.png'):
            r_img3.add_picture('docs/database/erd/ProGroupAI_ERD_Module_03.png', width=Inches(6.2))
        add_p_before('Hình 3.30: Sơ đồ quan hệ thực thể (ERD) - Phân hệ Đề tài, Nhóm đồ án và Báo cáo tiến độ', style='Caption')

        # 3.5.2. Từ điển dữ liệu
        add_p_before('Từ điển dữ liệu các thực thể trong cơ sở dữ liệu', style='Heading 3')
        add_p_before(
            'Bảng dưới đây tổng hợp danh mục 17 bảng thực thể được quản lý trong cơ sở dữ liệu SQL Server của hệ thống ProGroup AI, xác định rõ vai trò nghiệp vụ, khóa chính (PK) và các liên kết khóa ngoại (FK):'
        )
        add_p_before('Bảng 3.15: Danh mục 17 bảng thực thể trong cơ sở dữ liệu ProjectRegistrationDB', style='Caption')

        # Bảng dữ liệu 17 bảng
        table_data = [
            ("STT", "Tên bảng", "Khóa chính (PK)", "Khóa ngoại (FK)", "Mô tả nghiệp vụ"),
            ("1", "NguoiDungs", "NguoiDungId", "VaiTroId", "Lưu trữ tài khoản người dùng, email, mật khẩu băm BCrypt"),
            ("2", "VaiTros", "VaiTroId", "Không", "Danh mục 5 vai trò hệ thống (Admin, PDT, GVK, GV, SV)"),
            ("3", "SinhViens", "SinhVienId", "NguoiDungId, KhoaId", "Hồ sơ sinh viên, mã số sinh viên (MSSV), lớp sinh hoạt"),
            ("4", "GiangViens", "GiangVienId", "NguoiDungId, KhoaId", "Hồ sơ giảng viên, học hàm, học vị, chuyên môn khoa"),
            ("5", "Khoas", "KhoaId", "Không", "Danh mục các khoa trực thuộc trường đại học"),
            ("6", "HocKys", "HocKyId", "Không", "Danh mục học kỳ, năm học và khoảng thời gian đào tạo"),
            ("7", "HocPhans", "HocPhanId", "KhoaId", "Danh mục học phần đồ án, số tín chỉ, khoa phụ trách"),
            ("8", "LopHocPhans", "LopHocPhanId", "HocPhanId, HocKyId, KhoaId", "Lớp học phần mở theo từng học kỳ thực tế"),
            ("9", "PhanCongGiangViens", "PhanCongId", "LopHocPhanId, GiangVienId", "Phân công giảng viên hướng dẫn/phản biện lớp học phần"),
            ("10", "SinhVienLopHocPhans", "SinhVienId, LopHocPhanId", "SinhVienId, LopHocPhanId", "Bảng quan hệ phân bổ sinh viên vào từng lớp học phần"),
            ("11", "DotDangKyDoAns", "DotDangKyId", "LopHocPhanId", "Đợt mở đăng ký đề tài và thành lập nhóm đồ án"),
            ("12", "DeTaiDoAns", "DeTaiId", "DotDangKyId, GiangVienId, LopHocPhanId", "Danh mục đề tài giảng viên giao hoặc sinh viên đề xuất"),
            ("13", "NhomDoAns", "NhomDoAnId", "DotDangKyId, TruongNhomId", "Nhóm sinh viên thực hiện đồ án môn học"),
            ("14", "ThanhVienNhoms", "ThanhVienNhomId", "NhomDoAnId, SinhVienId", "Danh sách các thành viên trong từng nhóm đồ án"),
            ("15", "DangKyDeTais", "DangKyDeTaiId", "NhomDoAnId, DeTaiId", "Đăng ký đề tài của nhóm và trạng thái phê duyệt"),
            ("16", "BaoCaoTienDos", "BaoCaoId", "NhomDoAnId, DeTaiId", "Báo cáo tiến độ tuần, đính kèm file Cloudflare R2"),
            ("17", "PasswordResetOtps", "OtpId", "NguoiDungId", "Mã xác thực OTP băm SHA-256 dùng để đặt lại mật khẩu"),
        ]

        new_tbl = doc.add_table(rows=len(table_data), cols=5)
        target_p._element.addprevious(new_tbl._tbl)
        for r_idx, row_values in enumerate(table_data):
            for c_idx, val in enumerate(row_values):
                new_tbl.rows[r_idx].cells[c_idx].text = val

    # -------------------------------------------------------------
    # 4. CHUẨN HÓA CẤP CHƯƠNG VÀ DANH SÁCH ĐA CẤP (MULTILEVEL LIST)
    # -------------------------------------------------------------
    print("Step 4: Linking Chapter Headings to Multilevel List 19...")
    chapter_titles = {
        1: 'GIỚI THIỆU ĐỀ TÀI',
        2: 'CƠ SỞ LÝ THUYẾT',
        3: 'THIẾT KẾ HỆ THỐNG',
        4: 'CÀI ĐẶT HỆ THỐNG',
        5: 'KIỂM THỬ, TRIỂN KHAI VÀ ĐÁNH GIÁ HỆ THỐNG'
    }

    found_ch = 0
    for idx, p in enumerate(doc.paragraphs):
        txt_u = p.text.strip().upper()
        if idx > 150 and (p.style.name == 'Heading 1' or any(txt_u.startswith(f'CHƯƠNG {k}') for k in range(1, 6))) and len(txt_u) < 120 and found_ch < 5:
            found_ch += 1
            ch_num = found_ch
            title = chapter_titles[ch_num]
            print(f"  Chapter {ch_num} at paragraph [{idx}]: setting title='{title}' with numId=19, ilvl=0")
            
            p.style = doc.styles['Heading 1']
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(18)
            p.paragraph_format.space_after = Pt(12)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)

            # Set text to title only (Word prepends "CHƯƠNG %1: ")
            p.text = title
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(18)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)

            # Set numPr = ilvl 0, numId 19
            pPr = p._element.get_or_add_pPr()
            for np in pPr.findall(qn('w:numPr')):
                pPr.remove(np)
            new_numPr = parse_xml(f'<w:numPr {nsdecls("w")}><w:ilvl w:val="0"/><w:numId w:val="19"/></w:numPr>')
            pPr.append(new_numPr)

    # -------------------------------------------------------------
    # 5. ĐỊNH DẠNG TẤT CẢ ĐỀ MỤC & ĐOẠN VĂN THEO THỂ THỨC CHUẨN
    # -------------------------------------------------------------
    print("Step 5: Formatting Headings, Paragraphs, Bullets, Captions...")
    
    # Base styles
    for s_name in ['Normal', 'Body Text', 'Normal (Web)', 'Caption']:
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
    for i in range(start_main_idx, len(doc.paragraphs)):
        p = doc.paragraphs[i]
        txt = p.text.strip()
        st = p.style.name

        for r in p.runs:
            r.font.name = 'Times New Roman'

        drawings = p._element.xpath('.//w:drawing | .//w:pict')
        has_real_image = len(drawings) > 0

        # Nếu là hình ảnh độc lập
        if has_real_image and len(txt) < 10:
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(6)
            p.paragraph_format.space_after = Pt(4)
            p.paragraph_format.first_line_indent = Cm(0)
            continue

        if not txt:
            p.paragraph_format.space_before = Pt(0)
            p.paragraph_format.space_after = Pt(0)
            continue

        # Đã xử lý Chapter ở Step 4, bỏ qua nếu là Heading 1
        if st == 'Heading 1':
            continue

        # B. ĐỀ MỤC CẤP 1.1 (Heading 2)
        # Cỡ chữ 14, in hoa, tô đậm, canh trái
        if st == 'Heading 2':
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
        if st in ['Heading 3', 'Heading 4', 'Heading 5']:
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
        # "Hình X.Y: Tên hình..." (Cỡ 13, tô đậm, canh giữa)
        if (st == 'Caption' and txt.startswith('Hình')) or (txt.startswith('Hình ') and any(txt.startswith(f'Hình {k}') for k in range(1, 10))):
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(4)
            p.paragraph_format.space_after = Pt(10)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(13)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)
            continue

        # E. ĐỀ MỤC BẢNG BIỂU: Đặt phía trên bảng, canh giữa
        # "Bảng X.Y: Tên bảng..." (Cỡ 13, tô đậm, canh giữa)
        if (st == 'Caption' and txt.startswith('Bảng')) or (txt.startswith('Bảng ') and any(txt.startswith(f'Bảng {k}') for k in range(1, 10))):
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(10)
            p.paragraph_format.space_after = Pt(4)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(13)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)
            continue

        # F. BULLET LISTS
        # Bullet cấp 1: Dấu gạch “-”; Position 0.3 cm, Text indent 0.8 cm
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

        # G. ĐOẠN VĂN THƯỜNG (BODY PARAGRAPH)
        # Thụt vào đầu dòng 0.8 cm, Cỡ chữ 13, Line spacing Multiple at 1.3, Before 6pt, After 6pt, canh đều 2 bên
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.line_spacing = 1.3
        p.paragraph_format.space_before = Pt(6)
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.left_indent = Cm(0)
        p.paragraph_format.first_line_indent = Cm(0.8)
        for r in p.runs:
            r.font.name = 'Times New Roman'
            r.font.size = Pt(13)
            r.font.color.rgb = RGBColor(0, 0, 0)

    # -------------------------------------------------------------
    # 6. ĐỊNH DẠNG BẢNG BIỂU (TABLES)
    # Cỡ chữ 12, Line spacing 1.3, Before 0pt, After 0pt. Lặp lại tiêu đề.
    # -------------------------------------------------------------
    print("Step 6: Formatting all Tables (Size 12, Line Spacing 1.3, Before 0pt, After 0pt, Header Repeat)...")
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
                    p.paragraph_format.left_indent = Cm(0)
                    p.paragraph_format.first_line_indent = Cm(0)
                    for r in p.runs:
                        r.font.name = 'Times New Roman'
                        r.font.size = Pt(12)
                        if is_header:
                            r.font.bold = True

    # Lưu kết quả
    doc.save(dst_file)
    print(f"SUCCESSFULLY generated and formatted: {dst_file} ({os.path.getsize(dst_file)} bytes)!")

if __name__ == '__main__':
    build_perfect_document()
