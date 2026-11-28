import docx
from docx.shared import Pt, Cm, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml, OxmlElement
from docx.oxml.ns import nsdecls, qn
import os, sys, shutil, zipfile, re
import xml.etree.ElementTree as ET

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

def set_cell_background(cell, fill_hex):
    shading_elm = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    cell._tc.get_or_add_tcPr().append(shading_elm)

def set_table_borders(table, color="D3D3D3"):
    tblPr = table._tbl.tblPr
    borders = parse_xml(
        f'<w:tblBorders {nsdecls("w")}>'
        f'  <w:top w:val="single" w:sz="6" w:space="0" w:color="{color}"/>'
        f'  <w:left w:val="single" w:sz="6" w:space="0" w:color="{color}"/>'
        f'  <w:bottom w:val="single" w:sz="6" w:space="0" w:color="{color}"/>'
        f'  <w:right w:val="single" w:sz="6" w:space="0" w:color="{color}"/>'
        f'  <w:insideH w:val="single" w:sz="4" w:space="0" w:color="{color}"/>'
        f'  <w:insideV w:val="single" w:sz="4" w:space="0" w:color="{color}"/>'
        f'</w:tblBorders>'
    )
    tblPr.append(borders)

def create_master_doc():
    src_base = r'D:\Downloads\file_coso_v4.docx'
    work_doc_path = 'master_building.docx'
    print(f"=== 1. PREPARING BASE DOCUMENT FROM {src_base} ===")
    shutil.copy(src_base, work_doc_path)
    
    # 1. PRE-PATCH numbering.xml for lvlRestart
    print(f"=== 2. PRE-PATCHING numbering.xml in {work_doc_path} ===")
    temp_dir = 'temp_zip_master'
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
    with zipfile.ZipFile(work_doc_path, 'r') as z:
        z.extractall(temp_dir)

    num_xml_path = os.path.join(temp_dir, 'word', 'numbering.xml')
    if os.path.exists(num_xml_path):
        with open(num_xml_path, 'r', encoding='utf-8') as f:
            content = f.read()
        root = ET.fromstring(content.encode('utf-8'))
        w_ns = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
        ns = {'w': w_ns}
        
        for ab in root.findall('w:abstractNum', ns):
            for lvl in ab.findall('w:lvl', ns):
                ilvl = lvl.attrib.get(f'{{{w_ns}}}ilvl')
                lvlRestart = lvl.find('w:lvlRestart', ns)
                if ilvl == '1' and lvlRestart is None:
                    elem = ET.Element(f'{{{w_ns}}}lvlRestart', {f'{{{w_ns}}}val': '1'})
                    lvl.insert(1, elem)
                elif ilvl == '2' and lvlRestart is None:
                    elem = ET.Element(f'{{{w_ns}}}lvlRestart', {f'{{{w_ns}}}val': '2'})
                    lvl.insert(1, elem)
                elif ilvl == '3' and lvlRestart is None:
                    elem = ET.Element(f'{{{w_ns}}}lvlRestart', {f'{{{w_ns}}}val': '3'})
                    lvl.insert(1, elem)

        xml_str = ET.tostring(root, encoding='utf-8', xml_declaration=True)
        with open(num_xml_path, 'wb') as f:
            f.write(xml_str)

        with zipfile.ZipFile(work_doc_path, 'w', zipfile.ZIP_DEFLATED) as z_out:
            for root_d, dirs, files in os.walk(temp_dir):
                for file in files:
                    full_p = os.path.join(root_d, file)
                    rel_p = os.path.relpath(full_p, temp_dir)
                    z_out.write(full_p, rel_p)
        shutil.rmtree(temp_dir)
        print("Patched numbering.xml with lvlRestart val=1, 2, 3!")

    # 2. OPEN WITH PYTHON-DOCX
    print(f"=== 3. OPENING WITH PYTHON-DOCX ===")
    doc = docx.Document(work_doc_path)

    # Set Page Margins & A4
    print("Setting page margins (Left 3.5cm, Right 2.5cm, Top 2.5cm, Bottom 2.5cm)...")
    for sec in doc.sections:
        sec.top_margin = Cm(2.5)
        sec.bottom_margin = Cm(2.5)
        sec.left_margin = Cm(3.5)
        sec.right_margin = Cm(2.5)
        sec.page_width = Cm(21.0)
        sec.page_height = Cm(29.7)
        for fp in sec.footer.paragraphs:
            fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
            for fr in fp.runs:
                fr.font.name = 'Times New Roman'
                fr.font.size = Pt(12)

    # Find target numId
    target_numId = '19'
    h1_style = doc.styles['Heading 1']
    numPr_s = h1_style._element.xpath('.//w:numPr')
    if numPr_s:
        nid = numPr_s[0].find(qn('w:numId'))
        if nid is not None:
            target_numId = nid.attrib.get(qn('w:val'), '19')
    print(f"Target numId for Multilevel List: {target_numId}")

    # Find the EXACT 5 main chapter headings by style == 'Heading 1'
    h1_paras = [p for p in doc.paragraphs if p.style and p.style.name == 'Heading 1']
    print(f"Found {len(h1_paras)} Heading 1 paragraphs in source:")
    for idx, p in enumerate(h1_paras):
        print(f"  H1[{idx}]: {p.text}")

    if len(h1_paras) < 5:
        raise ValueError(f"Expected at least 5 Heading 1 paragraphs, found {len(h1_paras)}")

    p_ch1 = h1_paras[0]
    p_ch2 = h1_paras[1]
    p_ch3 = h1_paras[2]
    p_ch4 = h1_paras[3]
    p_ch5 = h1_paras[4]

    # Find References paragraph
    p_ref = None
    for p in doc.paragraphs:
        txt = p.text.strip().upper()
        if 'TÀI LIỆU THAM KHẢO' in txt:
            p_ref = p
            break
    print(f"Found landmarks: CH1='{p_ch1.text}', CH2='{p_ch2.text}', CH3='{p_ch3.text}', CH4='{p_ch4.text}', CH5='{p_ch5.text}', Ref={bool(p_ref)}")

    # 3. INSERT DATABASE DESIGN SECTION INTO CHAPTER 3 BEFORE CHAPTER 4
    print("=== 4. INSERTING SECTION 3.5 (ERD) BEFORE CHAPTER 4 ===")
    def add_p_before(anchor, text, style='Normal'):
        return anchor.insert_paragraph_before(text, style=style)

    add_p_before(p_ch4, 'THIẾT KẾ CƠ SỞ DỮ LIỆU', style='Heading 2')
    add_p_before(p_ch4, 
        'Cơ sở dữ liệu của hệ thống ProGroup AI được xây dựng trên hệ quản trị cơ sở dữ liệu quan hệ Microsoft SQL Server với tên gọi ProjectRegistrationDB. Mô hình dữ liệu bao gồm 17 bảng thực thể được thiết kế chuẩn hóa, đảm bảo tính toàn vẹn tham chiếu, tối ưu hóa truy vấn thông qua các chỉ mục (indexes) và ràng buộc khóa ngoại (foreign keys).'
    )
    add_p_before(p_ch4,
        'Toàn bộ kiến trúc dữ liệu được phân chia thành 3 phân hệ chức năng cốt lõi nhằm phục vụ xuyên suốt toàn bộ vòng đời đăng ký đồ án: (1) Phân hệ Người dùng, Vai trò và Xác thực tài khoản; (2) Phân hệ Quản lý Đào tạo, Học phần và Phân công giảng dạy; (3) Phân hệ Quản lý Đề tài, Đăng ký đề tài, Nhóm đồ án và Báo cáo tiến độ.'
    )
    add_p_before(p_ch4, 'Sơ đồ thực thể liên kết (ERD - Entity Relationship Diagram)', style='Heading 3')
    add_p_before(p_ch4,
        'Nhằm đảm bảo tính trực quan, độ sắc nét và khả năng theo dõi chi tiết cấu trúc các thuộc tính của 17 bảng trên khổ giấy A4, sơ đồ ERD được chuẩn hóa và trình bày thông qua 3 phân hệ cơ sở dữ liệu chuyên biệt dưới đây:'
    )
    add_p_before(p_ch4, '- Phân hệ Người dùng, Vai trò và Xác thực:')
    add_p_before(p_ch4,
        'Bao gồm các thực thể NguoiDungs, VaiTros, GiangViens, SinhViens và PasswordResetOtps. Phân hệ này chịu trách nhiệm lưu trữ hồ sơ người dùng, phân quyền truy cập theo 5 nhóm vai trò và cơ chế xác thực an toàn bằng mã OTP băm SHA-256 kết hợp mã hóa BCrypt cho mật khẩu.'
    )
    p_img1 = add_p_before(p_ch4, '')
    p_img1.alignment = WD_ALIGN_PARAGRAPH.CENTER
    if os.path.exists('docs/database/erd/ProGroupAI_ERD_Module_01.png'):
        p_img1.add_run().add_picture('docs/database/erd/ProGroupAI_ERD_Module_01.png', width=Inches(6.2))
    add_p_before(p_ch4, 'Hình 3.28: Sơ đồ quan hệ thực thể (ERD) - Phân hệ Người dùng và Phân quyền', style='Caption')

    add_p_before(p_ch4, '- Phân hệ Quản lý Đào tạo, Học phần và Phân công:')
    add_p_before(p_ch4,
        'Bao gồm các thực thể Khoas, HocPhans, HocKys, LopHocPhans, PhanCongGiangViens, SinhVienLopHocPhans, DotImports và LoiImports. Phân hệ này cho phép quản lý cơ cấu học phần, phân công giảng viên hướng dẫn và giảng viên phản biện, cũng như theo dõi lịch sử nạp dữ liệu danh sách đào tạo hàng loạt.'
    )
    p_img2 = add_p_before(p_ch4, '')
    p_img2.alignment = WD_ALIGN_PARAGRAPH.CENTER
    if os.path.exists('docs/database/erd/ProGroupAI_ERD_Module_02.png'):
        p_img2.add_run().add_picture('docs/database/erd/ProGroupAI_ERD_Module_02.png', width=Inches(6.2))
    add_p_before(p_ch4, 'Hình 3.29: Sơ đồ quan hệ thực thể (ERD) - Phân hệ Quản lý Đào tạo và Lớp học phần', style='Caption')

    add_p_before(p_ch4, '- Phân hệ Đề tài, Đăng ký, Nhóm đồ án và Tiến độ:')
    add_p_before(p_ch4,
        'Bao gồm các thực thể DotDangKyDoAns, DeTaiDoAns, NhomDoAns, ThanhVienNhoms, DangKyDeTais, BaoCaoTienDos, ThongBaos và AIRequests. Phân hệ này quản lý toàn diện đợt mở đăng ký, danh mục đề tài, quy trình đăng ký nhóm, bình duyệt đề tài đề xuất, gửi báo cáo tiến độ tuần và lịch sử nhật ký trợ lý AI.'
    )
    p_img3 = add_p_before(p_ch4, '')
    p_img3.alignment = WD_ALIGN_PARAGRAPH.CENTER
    if os.path.exists('docs/database/erd/ProGroupAI_ERD_Module_03.png'):
        p_img3.add_run().add_picture('docs/database/erd/ProGroupAI_ERD_Module_03.png', width=Inches(6.2))
    add_p_before(p_ch4, 'Hình 3.30: Sơ đồ quan hệ thực thể (ERD) - Phân hệ Đề tài, Nhóm đồ án và Báo cáo tiến độ', style='Caption')

    add_p_before(p_ch4, 'Từ điển dữ liệu các thực thể trong cơ sở dữ liệu', style='Heading 3')
    add_p_before(p_ch4,
        'Bảng dưới đây tổng hợp danh mục 17 bảng thực thể được quản lý trong cơ sở dữ liệu SQL Server của hệ thống ProGroup AI, xác định rõ vai trò nghiệp vụ, khóa chính (PK) và các liên kết khóa ngoại (FK):'
    )
    add_p_before(p_ch4, 'Bảng 3.15: Danh mục 17 bảng thực thể trong cơ sở dữ liệu ProjectRegistrationDB', style='Caption')

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
    p_ch4._element.addprevious(new_tbl._tbl)
    for r_idx, row_values in enumerate(table_data):
        for c_idx, val in enumerate(row_values):
            new_tbl.rows[r_idx].cells[c_idx].text = val

    # 4. CLEAR PLACEHOLDERS BETWEEN CH4 AND CH5, AND BETWEEN CH5 AND REF
    print("Clearing placeholder paragraphs between CH4 and CH5...")
    p_cur = p_ch4._p.getnext()
    while p_cur is not None and p_cur != p_ch5._p:
        p_next = p_cur.getnext()
        p_cur.getparent().remove(p_cur)
        p_cur = p_next

    print("Clearing placeholder paragraphs between CH5 and References...")
    p_cur = p_ch5._p.getnext()
    while p_cur is not None and p_cur != p_ref._p:
        p_next = p_cur.getnext()
        p_cur.getparent().remove(p_cur)
        p_cur = p_next

    # 5. INSERT FULL CHAPTER 4 CONTENT BEFORE p_ch5
    print("=== 5. INSERTING CHAPTER 4 CONTENT BEFORE CH5 ===")
    def add_p4(text, style='Normal'):
        return p_ch5.insert_paragraph_before(text, style=style)

    add_p4("Chương 4 trình bày chi tiết về quá trình hiện thực hóa các mô hình phân tích và thiết kế đã xây dựng ở Chương 3 thành sản phẩm phần mềm hoàn chỉnh. Nội dung chương bao gồm: đặc tả môi trường phát triển và công cụ triển khai; tổ chức cấu trúc mã nguồn ở cả hai tầng Backend (ASP.NET Core Web API) và Frontend (Flutter); quy trình cài đặt cơ sở dữ liệu quan hệ trên Microsoft SQL Server cùng các dịch vụ đám mây tích hợp (Firebase, Cloudflare R2, Google Gemini AI); và cuối cùng là hệ thống giao diện trực quan kèm theo mô tả kỹ thuật cho từng luồng nghiệp vụ thực tế của 6 vai trò người dùng trong hệ thống.")

    # 4.1
    add_p4("MÔI TRƯỜNG PHÁT TRIỂN VÀ CÔNG CỤ TRIỂN KHAI", style='Heading 2')
    add_p4("Hệ thống ProGroup_AI được xây dựng trên nền tảng kiến trúc Client - Server hiện đại, tách biệt hoàn toàn giữa tầng xử lý nghiệp vụ trung tâm (Backend Web API) và tầng giao diện tương tác người dùng đa nền tảng (Frontend Mobile/Web). Để đảm bảo tính tương thích, hiệu năng cao và độ ổn định trong quá trình phát triển cũng như vận hành, các công cụ, ngôn ngữ và nền tảng công nghệ được lựa chọn và cấu hình đồng bộ như mô tả trong Bảng 4.1.")

    add_p4("Bảng 4.1: Bảng tổng hợp môi trường phát triển và công nghệ triển khai", style='Caption')

    table_data_4_1 = [
        ["STT", "Thành phần", "Công nghệ / Nền tảng", "Phiên bản", "Vai trò & Mục đích sử dụng"],
        ["1", "Hệ điều hành máy chủ / dev", "Windows 11 / Ubuntu 22.04 LTS", "-", "Môi trường phát triển cục bộ và máy chủ lưu trữ dịch vụ."],
        ["2", "Framework Backend", "ASP.NET Core Web API", ".NET 10.0 / C# 13", "Xây dựng RESTful API, xử lý nghiệp vụ, xác thực JWT và tích hợp dịch vụ."],
        ["3", "ORM (Object-Relational)", "Entity Framework Core", "10.0.x", "Ánh xạ thực thể C# xuống bảng CSDL, truy vấn LINQ và quản lý Migrations."],
        ["4", "Hệ quản trị CSDL", "Microsoft SQL Server", "2022 Express", "Lưu trữ dữ liệu quan hệ 21 bảng với bảng mã Unicode UTF-8."],
        ["5", "Framework Frontend", "Flutter SDK", "3.29.x / Dart 3.7.x", "Ứng dụng di động đa nền tảng (Android/iOS) giao diện Material Design 3."],
        ["6", "Xác thực & Bảo mật", "JSON Web Token (JWT)", "RFC 7519 / HmacSha256", "Cấp Access Token, duy trì phiên Stateless và phân quyền Claims."],
        ["7", "Thông báo tức thời", "Firebase Cloud Messaging", "Admin SDK 3.x", "Gửi thông báo đẩy (Push Notification) thời gian thực đến SV và GV."],
        ["8", "Nhắn tin thời gian thực", "Cloud Firestore", "Firebase SDK 11.x", "Lưu trữ và đồng bộ tức thời tin nhắn trao đổi nội bộ trong nhóm đồ án."],
        ["9", "Lưu trữ tệp đám mây", "Cloudflare R2 Storage", "AWSSDK.S3 for .NET", "Lưu ảnh đại diện, tệp báo cáo tiến độ (.pdf, .docx) không tốn phí băng thông."],
        ["10", "Trí tuệ nhân tạo (AI)", "Google Gemini API", "Gemini 2.5 Flash / Lite", "Gợi ý đề tài nghiên cứu, chuẩn hóa cấu trúc đề xuất và phân tích số liệu."],
        ["11", "Dịch vụ Gửi email", "MailKit / SMTP Gmail", "4.x", "Gửi mã xác thực OTP 6 số phục vụ quy trình khôi phục mật khẩu tài khoản."],
        ["12", "Công cụ lập trình (IDE)", "VS Code & Visual Studio 2022", "Mới nhất", "Biên dịch mã nguồn, gỡ lỗi và quản lý máy ảo Android (API 34)."]
    ]

    t41 = doc.add_table(rows=len(table_data_4_1), cols=5)
    t41.style = 'Table Grid'
    t41.alignment = WD_TABLE_ALIGNMENT.CENTER
    for r_idx, row_data in enumerate(table_data_4_1):
        for c_idx, val in enumerate(row_data):
            t41.rows[r_idx].cells[c_idx].text = val
    set_table_borders(t41)
    p_ch5._p.addprevious(t41._tbl)

    # 4.2
    add_p4("TỔ CHỨC CẤU TRÚC MÃ NGUỒN", style='Heading 2')
    add_p4("Mã nguồn của hệ thống ProGroup_AI được phân chia thành hai phân vùng độc lập nhằm đảm bảo nguyên lý đơn nhiệm (Single Responsibility Principle), khả năng mở rộng linh hoạt và bảo trì thuận lợi.")

    add_p4("Cấu trúc mã nguồn Backend (ASP.NET Core Web API)", style='Heading 3')
    add_p4("Toàn bộ logic nghiệp vụ, các bộ điều khiển tiếp nhận yêu cầu HTTP và tương tác cơ sở dữ liệu được tổ chức theo mô hình phân tầng hướng dịch vụ (Service-Oriented Architecture) bên trong thư mục ProGroup_AI.API:")

    backend_compact_tree = (
        "ProGroup_AI.API/\n"
        "|-- Controllers/       # Tiếp nhận và xử lý HTTP API\n"
        "|   |-- AiController.cs          # API trợ lý AI\n"
        "|   |-- AuthController.cs        # Xác thực & JWT\n"
        "|   |-- DeTaiController.cs       # Quản lý đề tài\n"
        "|   |-- NhomDoAnController.cs    # Quản lý nhóm\n"
        "|   +-- ...\n"
        "|-- Models/            # Thực thể CSDL & DTO\n"
        "|   |-- Entities/                # Bảng SQL Server\n"
        "|   +-- DTOs/                    # Dữ liệu truyền tải\n"
        "|-- Services/          # Tầng xử lý nghiệp vụ lõi\n"
        "|   |-- AiService.cs             # Tích hợp Gemini API\n"
        "|   |-- AuthService.cs           # Cấp phát Token & OTP\n"
        "|   |-- StorageService.cs        # Tải tệp lên Cloud\n"
        "|   +-- ...\n"
        "|-- Data/              # DbContext & Migrations\n"
        "|   |-- AppDbContext.cs          # Cấu hình EF Core\n"
        "|   +-- Migrations/              # Lịch sử dịch chuyển\n"
        "+-- Program.cs         # Cấu hình DI Container & Middleware"
    )
    p_tree_b = add_p4(backend_compact_tree)
    for r in p_tree_b.runs:
        r.font.name = 'Courier New'
        r.font.size = Pt(10)

    add_p4("Cấu trúc mã nguồn Frontend (Flutter Mobile Application)", style='Heading 3')
    add_p4("Ứng dụng di động Flutter được tổ chức theo kiến trúc phân tách tính năng kết hợp tầng dịch vụ kết nối Web API:")

    frontend_compact_tree = (
        "progroup_ai_frontend/lib/\n"
        "|-- main.dart          # Khởi động ứng dụng\n"
        "|-- config/            # Cấu hình màu sắc, theme, API\n"
        "|-- models/            # Mô hình dữ liệu Dart\n"
        "|-- services/          # Gọi RESTful API Backend\n"
        "|   |-- api_service.dart         # HTTP Client tập trung\n"
        "|   |-- auth_service.dart        # Quản lý Session\n"
        "|   |-- chat_service.dart        # Kết nối Firestore\n"
        "|   +-- ...\n"
        "|-- screens/           # Giao diện theo vai trò\n"
        "|   |-- auth/                    # Đăng nhập, Quên MK\n"
        "|   |-- sinh_vien/               # Màn hình Sinh viên\n"
        "|   |-- giang_vien/              # Màn hình Giảng viên\n"
        "|   |-- giao_vu/                 # Màn hình Giáo vụ\n"
        "|   |-- phong_dao_tao/           # Màn hình PĐT\n"
        "|   +-- admin/                   # Màn hình Admin\n"
        "+-- widgets/           # Thành phần UI tái sử dụng"
    )
    p_tree_f = add_p4(frontend_compact_tree)
    for r in p_tree_f.runs:
        r.font.name = 'Courier New'
        r.font.size = Pt(10)

    # 4.3
    add_p4("CÀI ĐẶT CƠ SỞ DỮ LIỆU VÀ CÁC DỊCH VỤ ĐÁM MÂY", style='Heading 2')
    add_p4("Cơ sở dữ liệu Microsoft SQL Server được thiết lập bằng cơ chế Entity Framework Core Migrations, đồng bộ 17 bảng nghiệp vụ cùng các chỉ mục truy vấn và quan hệ khóa ngoại toàn vẹn.")
    add_p4("Bên cạnh SQL Server, hệ thống tích hợp các dịch vụ đám mây chuyên biệt:")
    add_p4("- Firebase Cloud Messaging (FCM): Quản lý đăng ký thiết bị di động và gửi thông báo đẩy thời gian thực.")
    add_p4("- Firebase Firestore: Cơ sở dữ liệu NoSQL phân tán thời gian thực phục vụ kênh chat trao đổi nội bộ của nhóm đồ án.")
    add_p4("- Cloudflare R2 Storage: Kho lưu trữ đối tượng tương thích chuẩn AWS S3 giúp lưu ảnh hồ sơ và tệp báo cáo tiến độ với chi phí băng thông 0 đồng.")
    add_p4("- Google Gemini AI: Tích hợp mô hình Gemini 2.5 Flash thông qua API Key an toàn để hỗ trợ gợi ý và chuẩn hóa đề tài nghiên cứu.")

    # 4.4
    add_p4("HIỆN THỰC HÓA GIAO DIỆN NGƯỜI DÙNG VÀ CÁC LUỒNG CHỨC NĂNG THỰC TẾ", style='Heading 2')
    add_p4("Phần này trình bày 22 giao diện tiêu biểu của hệ thống ProGroup_AI trên thiết bị di động thực tế. Mỗi giao diện được minh họa bằng hình ảnh chụp màn hình trực tiếp cùng đoạn mô tả kỹ thuật súc tích làm rõ tác nhân thao tác, luồng xử lý và kết quả đạt được.")

    def add_figure(img_idx, caption_text, desc_text):
        img_path = f"perfect_screenshots/Hình_4_{img_idx}.png"
        if not os.path.exists(img_path):
            img_path = f"report_screenshots/Hình_4_{img_idx}.png"
        p_img = add_p4('')
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        if os.path.exists(img_path):
            p_img.add_run().add_picture(img_path, width=Inches(3.3))
        add_p4(f"Hình 4.{img_idx}: {caption_text}", style='Caption')
        add_p4(desc_text)

    # 4.4.1
    add_p4("Phân hệ Dùng chung (Đăng nhập & Xác thực tài khoản)", style='Heading 3')
    add_figure(1, "Màn hình Đăng nhập hệ thống",
        "Người dùng nhập Tên đăng nhập (Mã số SV/GV/Cán bộ) và Mật khẩu, sau đó nhấn nút Đăng nhập. Ứng dụng gửi yêu cầu POST đến endpoint /api/Auth/login; Backend kiểm tra mã băm BCrypt trong bảng Users và trả về mã JWT Token kèm thông tin vai trò. Sau khi xác thực thành công, Flutter lưu Token vào SharedPreferences và tự động điều hướng người dùng đến đúng Dashboard chức năng tương ứng."
    )
    add_figure(2, "Màn hình Quên mật khẩu và xác thực mã OTP",
        "Khi người dùng quên mật khẩu, hệ thống yêu cầu nhập Email đã đăng ký để gửi yêu cầu đến endpoint /api/Auth/forgot-password. Backend sinh mã OTP ngẫu nhiên gồm 6 chữ số, lưu vào bộ đệm kèm thời gian sống 5 phút và kích hoạt dịch vụ EmailService gửi mã qua SMTP Gmail. Sau khi người dùng nhập đúng mã OTP trên giao diện, hệ thống chuyển sang bước thiết lập mật khẩu mới và cập nhật trực tiếp vào cơ sở dữ liệu."
    )

    # 4.4.2
    add_p4("Phân hệ Sinh viên & Trưởng nhóm", style='Heading 3')
    add_figure(3, "Trang chủ Sinh viên và danh sách Lớp học phần",
        "Trang chủ sinh viên chào mừng 'Trần Minh An', hiển thị biểu ngữ Cố vấn đề tài thông minh cùng Gemini AI Live và danh sách Lớp học phần của tôi (Trí tuệ nhân tạo - AI-01 do Giảng viên Lê Hoàng Nam phụ trách). Sinh viên có thể xem nhanh trạng thái môn học và hạn chót đăng ký đồ án môn học."
    )
    add_figure(4, "Chi tiết nhóm đồ án và Quản lý danh sách thành viên",
        "Màn hình chi tiết Nhóm Demo 02 hiển thị sĩ số 3/5 sinh viên, danh sách thành viên gồm Trần Minh An (Trưởng nhóm), Lê Hoàng Bình và Phạm Gia Huy. Bên cạnh đó, màn hình thể hiện trạng thái đề tài nghiên cứu đã được giảng viên duyệt và cung cấp lối tắt mở đoạn chat nhóm thời gian thực hoặc truy cập nộp báo cáo tiến độ."
    )
    add_figure(5, "Màn hình Trợ lý AI gợi ý đề tài nghiên cứu",
        "Màn hình Cố vấn Đề tài AI Sinh viên tích hợp Gemini AI Live, cho phép sinh viên lựa chọn lớp học phần đang học và các định hướng công nghệ quan tâm (Web, Mobile, AI, IoT, Thương mại điện tử...) cùng số lượng đề tài mong muốn. Hệ thống gửi prompt chuyên biệt đến /api/Ai/suggest-topics để phân tích và sinh danh mục đề tài nghiên cứu khả thi kèm công nghệ gợi ý."
    )
    add_figure(6, "Giao diện Đề xuất đề tài và AI chuẩn hóa nội dung",
        "Màn hình Khởi tạo ý tưởng đề tài cung cấp form nhập liệu đầy đủ: Tên đề tài, Mô tả chi tiết, Mục tiêu đề tài, Phạm vi thực hiện và Công nghệ sử dụng. Sinh viên có thể nhập ý tưởng thô và nhờ AI chuẩn hóa ngôn ngữ theo chuẩn học thuật trước khi gửi trực tiếp đến Giảng viên hướng dẫn xét duyệt."
    )
    add_figure(7, "Màn hình Chi tiết đề tài và Đăng ký đề tài cho nhóm",
        "Màn hình Chi tiết đề tài hiển thị thông tin toàn diện của đề tài 'Ứng dụng tìm trọ và đánh giá phòng trọ sinh viên' thuộc lớp Lập trình di động (LTDD), bao gồm Giảng viên hướng dẫn Trần Thị Mai Lan, công nghệ yêu cầu (Flutter, ASP.NET Core, Mapbox API, SQL Server), mục tiêu và mô tả chi tiết."
    )
    add_figure(8, "Giao diện Trò chuyện nội bộ nhóm thời gian thực",
        "Phòng trò chuyện nội bộ nhóm 'Nhóm Demo 02' kết nối trực tiếp với Cloud Firestore Realtime qua luồng Stream thời gian thực. Giao diện cho phép các thành viên trong nhóm gửi tin nhắn trao đổi, chia sẻ tài liệu và quản lý duyệt yêu cầu tham gia nhóm tức thì với độ trễ dưới 1 giây mà không cần tải lại trang."
    )
    add_figure(9, "Màn hình Theo dõi và Nộp báo cáo tiến độ đồ án",
        "Màn hình Báo cáo tiến độ đồ án của Nhóm Demo 02 hiển thị danh sách các tuần báo cáo đã nộp kèm điểm số và nhận xét từ giảng viên (Tuần 1: Điểm 9.0/10; Tuần 3: Đã nộp bài). Mỗi đợt báo cáo liên kết trực tiếp với mã nguồn GitHub và tài liệu PDF lưu trữ trên Cloudflare R2, đồng thời tích hợp nút Nộp báo cáo mới."
    )

    # 4.4.3
    add_p4("Phân hệ Giảng viên", style='Heading 3')
    add_figure(10, "Trang chủ Giảng viên và danh sách Lớp học phần hướng dẫn",
        "Trang chủ chào mừng Giảng viên 'Nguyễn Văn Giảng' tổng hợp các chỉ số hoạt động trong học kỳ: 2 Lớp học phần, 8 Nhóm sinh viên, 8 Đề tài hướng dẫn và 2 Đăng ký chờ duyệt. Màn hình bố trí các khối tác vụ nhanh trực quan: Kho đề tài, Duyệt nhóm đăng ký, Ý tưởng của SV và Chấm điểm & nhận xét tiến độ."
    )
    add_figure(11, "Màn hình Quản lý danh mục đề tài của Giảng viên",
        "Màn hình quản lý danh mục đề tài do giảng viên phụ trách, cho phép tạo đề tài mới, cập nhật mục tiêu, công nghệ yêu cầu, số lượng sinh viên tối đa và phân loại đề tài theo đợt đăng ký đồ án tương ứng."
    )
    add_figure(12, "Giao diện Xét duyệt đề tài do sinh viên đề xuất",
        "Giao diện duyệt đề tài đề xuất liệt kê các ý tưởng do các nhóm sinh viên gửi lên kèm theo bản tóm tắt đề cương đã qua AI chuẩn hóa. Giảng viên có thể xem chi tiết, yêu cầu chỉnh sửa hoặc phê duyệt đề tài trực tiếp."
    )
    add_figure(13, "Màn hình Chấm điểm và Nhận xét báo cáo tiến độ",
        "Màn hình chấm điểm báo cáo cho phép giảng viên tải xuống tài liệu báo cáo PDF, xem liên kết GitHub của nhóm, nhập điểm số theo thang điểm 10 và viết nhận xét phản hồi trực tiếp cho từng tuần thực hiện."
    )

    # 4.4.4
    add_p4("Phân hệ Giáo vụ Khoa", style='Heading 3')
    add_figure(14, "Trang tổng quan Dashboard Giáo vụ Khoa",
        "Dashboard tổng quan của Giáo vụ Khoa hiển thị các thống kê tổng thể về số lượng lớp học phần, số đề tài được phân công, tỷ lệ sinh viên đã vào nhóm và tiến độ chung của toàn khoa trong học kỳ."
    )
    add_figure(15, "Màn hình Quản lý danh sách Lớp học phần của Khoa",
        "Màn hình cho phép giáo vụ tra cứu, tạo mới, chỉnh sửa thông tin lớp học phần, gán học kỳ và quy định số lượng nhóm tối đa cho từng lớp đồ án chuyên ngành."
    )
    add_figure(16, "Giao diện Phân công Giảng viên hướng dẫn và phản biện",
        "Giao diện phân công hỗ trợ gán giảng viên phụ trách hướng dẫn chính hoặc giảng viên chấm phản biện cho từng lớp học phần đồ án, đảm bảo cân đối tải giảng dạy giữa các cán bộ trong khoa."
    )
    add_figure(17, "Màn hình Quản lý danh sách Sinh viên và Giảng viên theo Khoa",
        "Màn hình quản lý hồ sơ nhân sự và sinh viên trực thuộc khoa, hỗ trợ tìm kiếm nhanh theo mã số, xem tình trạng tài khoản và lớp sinh hoạt."
    )

    # 4.4.5
    add_p4("Phân hệ Phòng Đào tạo", style='Heading 3')
    add_figure(18, "Trang Dashboard tổng quan Phòng Đào tạo",
        "Dashboard tổng hợp số liệu toàn trường của Phòng Đào tạo, hiển thị biểu đồ phân bố đề tài theo khoa, tiến độ mở đợt đăng ký và các cảnh báo quan trọng."
    )
    add_figure(19, "Màn hình Thiết lập và Quản lý đợt đăng ký đồ án",
        "Màn hình cho phép cán bộ Phòng Đào tạo tạo lập đợt đăng ký mới, thiết lập thời gian bắt đầu, thời gian kết thúc, áp dụng cho các lớp học phần cụ thể và cấu hình số lượng thành viên tối thiểu/tối đa cho mỗi nhóm."
    )
    add_figure(20, "Giao diện Import dữ liệu danh sách đào tạo từ tệp Excel",
        "Giao diện hỗ trợ nhập hàng loạt danh sách sinh viên, giảng viên và lớp học phần từ tệp Excel chuẩn hóa. Hệ thống tự động kiểm tra tính hợp lệ của từng dòng dữ liệu và thông báo chi tiết số bản ghi thành công/thất bại."
    )

    # 4.4.6
    add_p4("Phân hệ Quản trị viên (Admin)", style='Heading 3')
    add_figure(21, "Màn hình Quản trị tài khoản và Phân quyền người dùng",
        "Màn hình dành riêng cho Quản trị viên hệ thống, cung cấp các công cụ quản lý toàn diện danh sách tài khoản, khóa/mở khóa tài khoản, đặt lại mật khẩu và gán quyền theo các vai trò hệ thống."
    )
    add_figure(22, "Giao diện Quản lý Sao lưu và Phục hồi Cơ sở dữ liệu",
        "Giao diện cấu hình lịch sao lưu tự động cơ sở dữ liệu SQL Server và hỗ trợ thực hiện sao lưu thủ công hoặc phục hồi dữ liệu từ bản sao lưu khi có sự cố."
    )

    # 6. INSERT CHAPTER 5 CONTENT BEFORE p_ref
    print("=== 6. INSERTING CHAPTER 5 CONTENT BEFORE REFERENCES ===")
    def add_p5(text, style='Normal'):
        return p_ref.insert_paragraph_before(text, style=style)

    # 5.1
    add_p5("KIỂM THỬ HỆ THỐNG", style='Heading 2')
    add_p5("Để đảm bảo hệ thống ProGroup AI vận hành chính xác, ổn định và đáp ứng đầy đủ các yêu cầu nghiệp vụ đặt ra, nhóm phát triển đã tiến hành kiểm thử toàn diện trên cả hai tầng Backend Web API và Frontend Mobile Application.")

    add_p5("Kiểm thử chức năng (Functional Testing)", style='Heading 3')
    add_p5("Phương pháp kiểm thử hộp đen (Black-box Testing) được áp dụng để kiểm tra từng luồng chức năng của các vai trò người dùng. Bảng 5.1 tổng hợp 12 kịch bản kiểm thử then chốt và kết quả thực nghiệm.")

    add_p5("Bảng 5.1: Bảng tổng hợp kịch bản kiểm thử chức năng hệ thống", style='Caption')

    test_cases_data = [
        ["Mã kịch bản", "Chức năng kiểm thử", "Dữ liệu đầu vào", "Kết quả mong đợi", "Kết quả thực tế", "Đánh giá"],
        ["TC-01", "Đăng nhập hệ thống", "MSSV đúng, Mật khẩu đúng", "Đăng nhập thành công, chuyển đến Dashboard", "Chuyển đúng Dashboard sinh viên", "ĐẠT"],
        ["TC-02", "Đăng nhập sai mật khẩu", "MSSV đúng, Mật khẩu sai", "Hiển thị thông báo sai mật khẩu", "Báo lỗi 'Tài khoản hoặc mật khẩu không đúng'", "ĐẠT"],
        ["TC-03", "Quên mật khẩu qua OTP", "Email hợp lệ đã đăng ký", "Nhận OTP 6 số qua email, đổi MK thành công", "Email nhận OTP sau 3s, đổi MK thành công", "ĐẠT"],
        ["TC-04", "Tạo nhóm đồ án mới", "Tên nhóm, số lượng tối đa 5", "Tạo nhóm thành công, người tạo là Trưởng nhóm", "Nhóm hiển thị trên danh sách, sĩ số 1/5", "ĐẠT"],
        ["TC-05", "Trợ lý AI gợi ý đề tài", "Chọn môn AI, từ khóa 'Mobile, Web'", "AI sinh 3 đề tài kèm mô tả và công nghệ", "Danh sách 3 đề tài chuẩn định dạng xuất hiện", "ĐẠT"],
        ["TC-06", "Sinh viên đề xuất đề tài", "Nhập tên đề tài, nhờ AI chuẩn hóa", "AI viết lại đề cương chuẩn học thuật", "Đề cương được chuẩn hóa và gửi đến GV", "ĐẠT"],
        ["TC-07", "Giảng viên duyệt đề xuất", "Chọn đề xuất của nhóm, nhấn Duyệt", "Trạng thái đề tài chuyển thành 'Đã duyệt'", "Đề tài được duyệt, thông báo gửi đến SV", "ĐẠT"],
        ["TC-08", "Đăng ký đề tài cho nhóm", "Nhóm chọn đề tài còn trống", "Đăng ký thành công, đề tài khóa với nhóm khác", "Đề tài gắn với nhóm, trạng thái đã chọn", "ĐẠT"],
        ["TC-09", "Trò chuyện nhóm realtime", "Gửi tin nhắn văn bản trong nhóm", "Tin nhắn xuất hiện tức thì ở các máy khác", "Đồng bộ qua Firestore < 1 giây", "ĐẠT"],
        ["TC-10", "Nộp báo cáo tiến độ tuần", "Đính kèm link GitHub, tệp PDF", "Lưu link, tải file lên Cloudflare R2", "File tải lên R2 thành công, lưu đường dẫn", "ĐẠT"],
        ["TC-11", "Import sinh viên Excel", "Tệp Excel danh sách 50 sinh viên", "Thêm thành công 50 sinh viên vào CSDL", "50 sinh viên được tạo tài khoản tự động", "ĐẠT"],
        ["TC-12", "Phân công giảng viên", "Chọn lớp học phần, gán giảng viên", "Lưu phân công, hiển thị trên lịch giảng dạy", "Phân công cập nhật tức thì trên Dashboard GV", "ĐẠT"]
    ]

    t51 = doc.add_table(rows=len(test_cases_data), cols=6)
    t51.style = 'Table Grid'
    t51.alignment = WD_TABLE_ALIGNMENT.CENTER
    for r_idx, row_data in enumerate(test_cases_data):
        for c_idx, val in enumerate(row_data):
            t51.rows[r_idx].cells[c_idx].text = val
    set_table_borders(t51)
    p_ref._p.addprevious(t51._tbl)

    # 5.2
    add_p5("TRIỂN KHAI HỆ THỐNG", style='Heading 2')
    add_p5("Triển khai Ứng dụng di động Flutter", style='Heading 3')
    add_p5("Ứng dụng di động Flutter được tối ưu mã nguồn thông qua công cụ ProGuard/R8 với các tham số minifyEnabled và shrinkResources trong tệp android/app/build.gradle nhằm loại bỏ tài nguyên dư thừa và tăng cường bảo mật. Ứng dụng được ký số bảo mật với tệp khóa keystore phát hành. Lệnh đóng gói flutter build apk --release --split-per-abi xuất ra tệp cài đặt APK có dung lượng chỉ 18.2 MB, sẵn sàng triển khai mượt mà trên các thiết bị Android từ phiên bản 8.0 trở lên.")

    add_p5("Triển khai Backend Web API", style='Heading 3')
    add_p5("Tầng xử lý trung tâm ASP.NET Core Web API được đóng gói bằng lệnh dotnet publish ở chế độ Release. Các thông số nhạy cảm như chuỗi kết nối SQL Server, Secret Key JWT, thông tin tài khoản SMTP và API Key Google Gemini được quản lý tách biệt qua Biến môi trường hệ thống. Ứng dụng có thể vận hành ổn định trên máy chủ Kestrel nội bộ kết hợp máy chủ ngược IIS Reverse Proxy hoặc đóng gói thành Docker Image phục vụ triển khai đa nền tảng.")

    add_p5("Triển khai các dịch vụ đám mây vệ tinh", style='Heading 3')
    add_p5("Cơ sở dữ liệu SQL Server được thiết lập cơ chế sao lưu tự động định kỳ hàng ngày; Firebase Cloud Messaging và Cloud Firestore được bảo vệ bằng các quy tắc bảo mật (Security Rules) chỉ cho phép thành viên trong nhóm truy xuất; kho lưu trữ Cloudflare R2 được cấu hình mạng phân phối nội dung (Cloudflare CDN) giúp phân tải hiệu quả và tăng tốc độ tải tài liệu báo cáo.")

    # 5.3
    add_p5("ĐÁNH GIÁ HỆ THỐNG", style='Heading 2')
    add_p5("Ưu điểm của hệ thống", style='Heading 3')
    add_p5("Hệ thống ProGroup_AI sau khi hoàn thiện và thử nghiệm thực tế đã chứng minh được nhiều ưu điểm nổi bật:")
    add_p5("1. Kiến trúc phân quyền chặt chẽ và chuyên biệt hóa cao: Phân định rạch ròi 6 vai trò người dùng (Admin, Phòng Đào tạo, Giáo vụ Khoa, Giảng viên, Sinh viên, Trưởng nhóm), đảm bảo mỗi tác nhân chỉ được tiếp cận đúng các tập dữ liệu và chức năng nghiệp vụ thuộc thẩm quyền của mình.")
    add_p5("2. Ứng dụng Trí tuệ nhân tạo (Generative AI) thiết thực và sáng tạo: Tích hợp mô hình ngôn ngữ lớn Google Gemini để giải quyết bài toán cốt lõi: tự động gợi ý đề tài phù hợp với năng lực công nghệ của từng sinh viên, chuẩn hóa ngôn ngữ đề cương nghiên cứu và phân tích số liệu đào tạo cho cán bộ quản lý.")
    add_p5("3. Trải nghiệm cộng tác thời gian thực vượt trội: Kết hợp linh hoạt giữa Cloud Firestore và Firebase Cloud Messaging (FCM), hỗ trợ sinh viên trao đổi nhóm tức thời và nhận thông báo biến động duyệt đề tài, nộp báo cáo theo thời gian thực mà không có độ trễ.")
    add_p5("4. Hạ tầng lưu trữ đám mây tối ưu chi phí: Ứng dụng Cloudflare R2 với giao thức S3 giúp nhà trường tiết kiệm 100% chi phí băng thông tải về (Zero Egress Fee) khi sinh viên và giảng viên thường xuyên trao đổi các tệp tài liệu báo cáo dung lượng lớn.")
    add_p5("5. Đảm bảo toàn vẹn dữ liệu tiếng Việt đa nền tảng: Chuẩn hóa mã hóa Unicode UTF-8 trên toàn bộ vòng đời truyền tải dữ liệu (từ giao diện Flutter qua Web API đến CSDL SQL Server), loại bỏ hoàn toàn các lỗi font chữ hoặc sai lệch ký tự thường gặp trong các hệ thống thông tin giáo dục tại Việt Nam.")

    add_p5("Hạn chế của hệ thống", style='Heading 3')
    add_p5("Bên cạnh những kết quả đạt được, hệ thống vẫn còn một số hạn chế nhất định:")
    add_p5("- Kết quả gợi ý của AI đôi khi chưa bám sát hoàn toàn danh mục đề tài nghiên cứu chuyên sâu của từng giảng viên trong trường, đòi hỏi phải được tinh chỉnh dữ liệu huấn luyện đặc thù (Fine-tuning hoặc RAG).")
    add_p5("- Hệ thống phụ thuộc vào các dịch vụ bên ngoài như Firebase, Cloudflare R2 và AI API. Khi các nhà cung cấp này gặp sự cố mạng hoặc bảo trì, một số chức năng phụ trợ sẽ bị ảnh hưởng tạm thời.")
    add_p5("- Việc sử dụng dịch vụ Cloud và AI API có thể phát sinh chi phí khi vượt hạn mức miễn phí hoặc lượng truy cập tăng cao.")
    add_p5("- Khả năng chịu tải và hiệu năng khi có nhiều người dùng đồng thời trong những ngày mở cổng đăng ký đề tài quy mô toàn trường chưa được đánh giá đầy đủ.")

    add_p5("Hướng phát triển trong tương lai", style='Heading 3')
    add_p5("Trong tương lai, hệ thống có thể được phát triển theo các hướng trọng tâm sau:")
    add_p5("- Nâng cao độ chính xác và tính kế thừa của AI trong việc tìm kiếm và gợi ý đề tài bằng cách tích hợp mô hình RAG (Retrieval-Augmented Generation) kết nối với kho lưu trữ các khóa luận tốt nghiệp của nhà trường.")
    add_p5("- Bổ sung chức năng theo dõi tiến độ và quản lý công việc nhóm với bảng Kanban tương tác trực tiếp ngay trong ứng dụng di động.")
    add_p5("- Đóng gói và phát hành ứng dụng trên nền tảng Web (Flutter Web) và iOS để phục vụ toàn diện người dùng trong trường học.")
    add_p5("- Tối ưu hiệu năng, bảo mật và khả năng mở rộng hệ thống bằng giải pháp bộ nhớ đệm phân tán Redis tại tầng API.")
    add_p5("- Mở rộng các chức năng thống kê, báo cáo phục vụ công tác quản lý và kết nối đồng bộ dữ liệu với cổng đào tạo chung của nhà trường.")

    # 7. FORMAT ENTIRE DOCUMENT (MAIN BODY, HEADINGS, BULLETS, TABLES)
    print("=== 7. FORMATTING ENTIRE DOCUMENT ACCORDING TO ACADEMIC GUIDELINES ===")
    
    chapter_titles = {
        1: 'GIỚI THIỆU ĐỀ TÀI',
        2: 'CƠ SỞ LÝ THUYẾT',
        3: 'THIẾT KẾ HỆ THỐNG',
        4: 'CÀI ĐẶT HỆ THỐNG',
        5: 'KIỂM THỬ, TRIỂN KHAI VÀ ĐÁNH GIÁ HỆ THỐNG'
    }

    elem_list = [p._element for p in doc.paragraphs]
    main_body_start = elem_list.index(p_ch1._element)
    print(f"Main body starts at paragraph {main_body_start} (Chapter 1: '{p_ch1.text}')")

    # Format Front Matter (0 to main_body_start - 1)
    for i in range(main_body_start):
        p = doc.paragraphs[i]
        st = p.style.name
        for r in p.runs:
            r.font.name = 'Times New Roman'
        # Disconnect any Front Matter headings from list numbering
        if st == 'Heading 1' or 'cThuheading1' in st:
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(18)
            p.paragraph_format.space_after = Pt(12)
            p.paragraph_format.first_line_indent = Cm(0)
            for r in p.runs:
                r.font.size = Pt(18)
                r.font.bold = True
            pPr = p._element.get_or_add_pPr()
            for np in pPr.findall(qn('w:numPr')):
                pPr.remove(np)
            new_np = parse_xml(f'<w:numPr {nsdecls("w")}><w:ilvl w:val="0"/><w:numId w:val="0"/></w:numPr>')
            pPr.append(new_np)
        elif st.startswith('toc') or st.startswith('table of figures'):
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.space_before = Pt(2)
            p.paragraph_format.space_after = Pt(2)
            for r in p.runs:
                r.font.size = Pt(13)

    # Format Main Body Chapters and Paragraphs
    chapter_elements = [p_ch1._element, p_ch2._element, p_ch3._element, p_ch4._element, p_ch5._element]
    for ch_idx, p_elem in enumerate(chapter_elements):
        ch_num = ch_idx + 1
        title = chapter_titles[ch_num]
        print(f"Configuring Chapter {ch_num}: '{title}' with numId={target_numId}")
        # Find matching paragraph
        p_ch = next(p for p in doc.paragraphs if p._element == p_elem)
        p_ch.style = doc.styles['Heading 1']
        p_ch.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_ch.paragraph_format.space_before = Pt(18)
        p_ch.paragraph_format.space_after = Pt(12)
        p_ch.paragraph_format.line_spacing = 1.3
        p_ch.paragraph_format.first_line_indent = Cm(0)
        p_ch.text = title
        for r in p_ch.runs:
            r.font.name = 'Times New Roman'
            r.font.size = Pt(18)
            r.font.bold = True
            r.font.color.rgb = RGBColor(0, 0, 0)
        pPr = p_ch._element.get_or_add_pPr()
        for np in pPr.findall(qn('w:numPr')):
            pPr.remove(np)
        new_np = parse_xml(f'<w:numPr {nsdecls("w")}><w:ilvl w:val="0"/><w:numId w:val="{target_numId}"/></w:numPr>')
        pPr.append(new_np)

    for idx in range(main_body_start, len(doc.paragraphs)):
        p = doc.paragraphs[idx]
        if p._element in chapter_elements:
            continue
        txt = p.text.strip()
        txt_u = txt.upper()
        st = p.style.name

        for r in p.runs:
            r.font.name = 'Times New Roman'

        drawings = p._element.xpath('.//w:drawing | .//w:pict')
        has_real_image = len(drawings) > 0

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

        # HEADING 2
        if st == 'Heading 2':
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.space_before = Pt(12)
            p.paragraph_format.space_after = Pt(6)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)
            clean_text = re.sub(r'^\d+(\.\d+)*\.?\s*', '', txt)
            p.text = clean_text.upper()
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(14)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)
            continue

        # HEADING 3, 4, 5
        if st in ['Heading 3', 'Heading 4', 'Heading 5']:
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.space_before = Pt(6)
            p.paragraph_format.space_after = Pt(6)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)
            clean_text = re.sub(r'^\d+(\.\d+)*\.?\s*', '', txt)
            p.text = clean_text
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(13)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)
            continue

        # CAPTIONS (Figures)
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

        # CAPTIONS (Tables)
        if (st == 'Caption' and txt.startswith('Bảng')) or (txt.startswith('Bảng ') and any(txt.startswith(f'Bảng {k}') for k in range(1, 10))):
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(10)
            p.paragraph_format.space_after = Pt(4)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(12)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)
            continue

        # BULLETS LEVEL 1 (- or –)
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

        # BULLETS LEVEL 2 (+)
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

        # REFERENCES / END MATTER
        if 'TÀI LIỆU THAM KHẢO' in txt_u:
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(18)
            p.paragraph_format.space_after = Pt(12)
            p.paragraph_format.first_line_indent = Cm(0)
            pPr = p._element.get_or_add_pPr()
            for np in pPr.findall(qn('w:numPr')):
                pPr.remove(np)
            new_np = parse_xml(f'<w:numPr {nsdecls("w")}><w:ilvl w:val="0"/><w:numId w:val="0"/></w:numPr>')
            pPr.append(new_np)
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(18)
                r.font.bold = True
            continue

        # BODY PARAGRAPHS
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

    # Format Tables
    print("Formatting Tables...")
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

    # 8. SAVE OUTPUT DIRECTLY
    dest_final = 'ProGroup_AI.docx'
    print(f"Saving final master document to {dest_final}...")
    doc.save(dest_final)
    print(f"Saved {dest_final} ({os.path.getsize(dest_final)} bytes)!")

    # Synchronize to file_coso_v4_chuan_format.docx
    shutil.copy(dest_final, 'file_coso_v4_chuan_format.docx')
    print("Copied to file_coso_v4_chuan_format.docx successfully!")

    if os.path.exists(work_doc_path):
        os.remove(work_doc_path)
    print("=== MASTER DOCUMENT BUILD COMPLETE ===")

if __name__ == '__main__':
    create_master_doc()
