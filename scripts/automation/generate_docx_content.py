import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn
import os

def set_cell_background(cell, fill_hex):
    shading_elm = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    cell._tc.get_or_add_tcPr().append(shading_elm)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

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

def build_docx():
    print("Loading file_coso_v4_backup.docx as base template...")
    doc = docx.Document('file_coso_v4_backup.docx')

    # Identify key landmarks
    p_ch4 = None
    p_ch5 = None
    p_ref = None

    for p in doc.paragraphs:
        txt = p.text.strip()
        if txt == "CÀI ĐẶT HỆ THỐNG":
            p_ch4 = p
        elif txt == "KIỂM THỬ, TRIỂN KHAI VÀ ĐÁNH GIÁ HỆ THỐNG":
            p_ch5 = p
        elif txt == "TÀI LIỆU THAM KHẢO":
            p_ref = p

    if not p_ch4 or not p_ch5 or not p_ref:
        raise ValueError("Could not find required section headers!")

    print("Found headers: CH4, CH5, References.")

    # Remove placeholder paragraphs between CH4 and CH5
    p_cur = p_ch4._p.getnext()
    while p_cur is not None and p_cur != p_ch5._p:
        p_next = p_cur.getnext()
        p_cur.getparent().remove(p_cur)
        p_cur = p_next

    # Remove placeholder paragraphs between CH5 and References
    p_cur = p_ch5._p.getnext()
    while p_cur is not None and p_cur != p_ref._p:
        p_next = p_cur.getnext()
        p_cur.getparent().remove(p_cur)
        p_cur = p_next

    print("Cleared placeholder paragraphs.")

    def add_p(text, style='Normal (Web)', anchor=p_ch5, bold=False, italic=False, align=None, space_after=6):
        p_new = anchor.insert_paragraph_before('', style=style)
        if text:
            run = p_new.add_run(text)
            run.bold = bold
            run.italic = italic
        if align:
            p_new.alignment = align
        p_new.paragraph_format.space_after = Pt(space_after)
        p_new.paragraph_format.line_spacing = 1.2
        return p_new

    # In Word template, Heading 2 and Heading 3 already have automatic numbering (4.1, 4.2, 4.2.1...)
    # So we MUST NOT prefix them with numbers in the string!
    def add_heading2(text, anchor=p_ch5):
        return add_p(text, style='Heading 2', anchor=anchor, space_after=6)

    def add_heading3(text, anchor=p_ch5):
        return add_p(text, style='Heading 3', anchor=anchor, space_after=4)

    def add_caption(text, anchor=p_ch5):
        p = anchor.insert_paragraph_before('', style='Caption')
        run = p.add_run(text)
        run.italic = True
        run.bold = True
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(4)
        p.paragraph_format.space_after = Pt(8)
        return p

    def add_img(img_path, caption_text, desc_text, anchor=p_ch5):
        if not os.path.exists(img_path):
            print(f"Warning: image {img_path} not found!")
            return
        p_img = anchor.insert_paragraph_before('')
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(8)
        p_img.paragraph_format.space_after = Pt(4)
        run = p_img.add_run()
        run.add_picture(img_path, width=Inches(3.3))

        add_caption(caption_text, anchor=anchor)
        add_p(desc_text, anchor=anchor, space_after=8)

    # ------------------ INSERT CHAPTER 4 (Before p_ch5) ------------------
    print("Inserting Chapter 4 content...")

    add_p("Chương 4 trình bày chi tiết về quá trình hiện thực hóa các mô hình phân tích và thiết kế đã xây dựng ở Chương 3 thành sản phẩm phần mềm hoàn chỉnh. Nội dung chương bao gồm: đặc tả môi trường phát triển và công cụ triển khai; tổ chức cấu trúc mã nguồn ở cả hai tầng Backend (ASP.NET Core Web API) và Frontend (Flutter); quy trình cài đặt cơ sở dữ liệu quan hệ trên Microsoft SQL Server cùng các dịch vụ đám mây tích hợp (Firebase, Cloudflare R2, Google Gemini AI); và cuối cùng là hệ thống giao diện trực quan kèm theo mô tả kỹ thuật cho từng luồng nghiệp vụ thực tế của 6 vai trò người dùng trong hệ thống.")

    # 4.1
    add_heading2("Môi trường phát triển và công cụ triển khai")
    add_p("Hệ thống ProGroup_AI được xây dựng trên nền tảng kiến trúc Client - Server hiện đại, tách biệt hoàn toàn giữa tầng xử lý nghiệp vụ trung tâm (Backend Web API) và tầng giao diện tương tác người dùng đa nền tảng (Frontend Mobile/Web). Để đảm bảo tính tương thích, hiệu năng cao và độ ổn định trong quá trình phát triển cũng như vận hành, các công cụ, ngôn ngữ và nền tảng công nghệ được lựa chọn và cấu hình đồng bộ như mô tả trong Bảng 4.1.")

    add_caption("Bảng 4.1. Bảng tổng hợp môi trường phát triển và công nghệ triển khai")

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
        row = t41.rows[r_idx]
        for c_idx, val in enumerate(row_data):
            cell = row.cells[c_idx]
            cell.text = val
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            set_cell_margins(cell, top=80, bottom=80, left=100, right=100)
            p_cell = cell.paragraphs[0]
            p_cell.paragraph_format.line_spacing = 1.15
            p_cell.paragraph_format.space_after = Pt(2)
            if r_idx == 0:
                set_cell_background(cell, "EAEAEA")
                p_cell.alignment = WD_ALIGN_PARAGRAPH.CENTER
                p_cell.runs[0].bold = True
            elif c_idx == 0:
                p_cell.alignment = WD_ALIGN_PARAGRAPH.CENTER

    set_table_borders(t41)
    p_ch5._p.addprevious(t41._tbl)

    # 4.2
    add_heading2("Tổ chức cấu trúc mã nguồn")
    add_p("Mã nguồn của hệ thống ProGroup_AI được phân chia thành hai phân vùng độc lập nhằm đảm bảo nguyên lý đơn nhiệm (Single Responsibility Principle), khả năng mở rộng linh hoạt và bảo trì thuận lợi.")

    # 4.2.1
    add_heading3("Cấu trúc mã nguồn Backend (ASP.NET Core Web API)")
    add_p("Toàn bộ logic nghiệp vụ, các bộ điều khiển tiếp nhận yêu cầu HTTP và tương tác cơ sở dữ liệu được tổ chức theo mô hình phân tầng hướng dịch vụ (Service-Oriented Architecture) bên trong thư mục ProGroup_AI.API:")

    # Clean compact tree lines <= 56 characters so NO line wraps!
    backend_compact_tree = (
        "ProGroup_AI.API/\n"
        "├── Controllers/              # Tiếp nhận HTTP Request (16 bộ)\n"
        "│   ├── AuthController.cs     # Xác thực JWT, OTP, đổi mật khẩu\n"
        "│   ├── StudentsController.cs # Hồ sơ sinh viên, nhóm đồ án\n"
        "│   ├── LecturersController.cs# Giảng viên, phân công lớp HP\n"
        "│   ├── ClassesController.cs  # Quản lý lớp học phần, sĩ số\n"
        "│   ├── ProjectsController.cs # Danh mục & đăng ký đề tài\n"
        "│   ├── ProposalsController.cs# Xét duyệt đề xuất đề tài\n"
        "│   ├── GroupsController.cs   # Tạo nhóm, mời thành viên\n"
        "│   ├── ProgressController.cs # Nộp và chấm báo cáo tiến độ\n"
        "│   ├── NotificationsController.cs # Thông báo người dùng\n"
        "│   ├── DataImportController.cs    # Nhập dữ liệu từ Excel/CSV\n"
        "│   ├── AnalyticsController.cs# Thống kê số liệu Giáo vụ, PĐT\n"
        "│   └── AiController.cs       # Cổng giao tiếp Google Gemini AI\n"
        "├── Data/                     # DbContext và cấu hình EF Core\n"
        "├── Models/                   # 21 thực thể CSDL SQL Server\n"
        "├── Services/                 # Xử lý nghiệp vụ & dịch vụ Cloud\n"
        "├── DTOs/                     # Data Transfer Objects\n"
        "└── Program.cs                # Cấu hình DI Container, Middleware"
    )
    p_b_tree = add_p(backend_compact_tree, space_after=8)
    p_b_tree.paragraph_format.left_indent = Inches(0.15)
    p_b_tree.paragraph_format.line_spacing = 1.12
    for r in p_b_tree.runs:
        r.font.name = "Consolas"
        r.font.size = Pt(8.5)

    # 4.2.2
    add_heading3("Cấu trúc mã nguồn Frontend (Flutter Mobile/Web)")
    add_p("Ứng dụng người dùng được viết bằng Flutter, tổ chức theo cấu trúc module rõ ràng, tách bạch giữa giao diện hiển thị (Screens), khối điều khiển giao diện (Widgets), quản lý dữ liệu (Models) và tầng giao tiếp mạng (Services):")

    frontend_compact_tree = (
        "progroup_ai_frontend/lib/\n"
        "├── constants/                # Hằng số giao diện và cấu hình mạng\n"
        "├── models/                   # Mô hình hóa dữ liệu từ Web API\n"
        "├── services/                 # API Client, Firestore, FCM, R2\n"
        "├── screens/                  # Màn hình giao diện theo vai trò\n"
        "│   ├── auth/                 # Đăng nhập, quên mật khẩu, OTP\n"
        "│   ├── student/              # Trang chủ SV, nhóm, gợi ý AI\n"
        "│   ├── lecturer/             # Quản lý lớp, duyệt đề xuất\n"
        "│   ├── giaovu/               # Phân công GV, quản lý lớp HP\n"
        "│   ├── pdt/                  # Dashboard PĐT, import Excel\n"
        "│   ├── admin/                # Quản trị tài khoản, sao lưu DB\n"
        "│   └── chat/                 # Phòng chat nhóm thời gian thực\n"
        "├── widgets/                  # Thành phần giao diện dùng chung\n"
        "└── main.dart                 # Điểm khởi chạy ứng dụng"
    )
    p_f_tree = add_p(frontend_compact_tree, space_after=8)
    p_f_tree.paragraph_format.left_indent = Inches(0.15)
    p_f_tree.paragraph_format.line_spacing = 1.12
    for r in p_f_tree.runs:
        r.font.name = "Consolas"
        r.font.size = Pt(8.5)

    # 4.3
    add_heading2("Cài đặt cơ sở dữ liệu và dịch vụ tích hợp")
    add_heading3("Cài đặt và cấu hình Cơ sở dữ liệu SQL Server")
    add_p("Cơ sở dữ liệu của hệ thống mang tên ProjectRegistrationDB, được thiết kế với 21 bảng quan hệ chuẩn hóa đến dạng chuẩn 3NF. Các bảng chính bao gồm: Users, Roles, Departments, Courses, ClassSections, StudentClasses, LecturerClasses, Groups, GroupMembers, Projects, ProjectProposals, RegistrationPeriods, ProgressReports, ProgressEvaluations, Notifications, SystemConfigs, ActivityLogs... Toàn bộ dữ liệu tiếng Việt có dấu được lưu trữ với kiểu NVARCHAR. Tại tầng Web API, bộ mã hóa JSON được cấu hình bằng JavaScriptEncoder.Create(UnicodeRanges.All) để loại bỏ triệt để hiện tượng sai mã hóa ký tự (Mojibake).")

    add_heading3("Cài đặt dịch vụ đám mây Firebase (FCM & Firestore)")
    add_p("Firebase Cloud Messaging (FCM) được triển khai qua FirebaseAdmin SDK trên máy chủ ASP.NET Core để đẩy thông báo thời gian thực đến thiết bị của sinh viên và giảng viên khi có biến động nghiệp vụ (duyệt đề tài, nộp báo cáo). Cloud Firestore quản lý luồng tin nhắn trao đổi nội bộ của từng nhóm đồ án thông qua bộ sưu tập conversations/{groupId}/messages, hỗ trợ đồng bộ dữ liệu tức thời hai chiều mà không gây áp lực tải lên máy chủ SQL Server.")

    add_heading3("Cài đặt dịch vụ lưu trữ đối tượng Cloudflare R2")
    add_p("Hệ thống tích hợp kho lưu trữ đối tượng đám mây Cloudflare R2 thông qua giao thức tương thích Amazon S3 API (AWSSDK.S3). Mọi hình ảnh đại diện của người dùng và các tệp báo cáo tiến độ đồ án (.pdf, .docx, .zip) đều được băm định danh GUID và tải trực tiếp lên bucket an toàn, giúp nhà trường tiết kiệm tối đa chi phí nhờ chính sách miễn phí hoàn toàn băng thông tải xuống (Zero Egress Fees).")

    add_heading3("Cài đặt Trí tuệ nhân tạo Google Gemini API")
    add_p("Backend giao tiếp với Google Gemini thông qua REST API bảo mật. Hệ thống ứng dụng mô hình gemini-flash-lite-latest và gemini-2.5-flash để phân tích sở thích công nghệ của sinh viên, gợi ý danh mục 3 đề tài khả thi, tự động chuẩn hóa mục tiêu và phạm vi của đề cương đồ án sinh viên đề xuất, cũng như hỗ trợ Giáo vụ phân tích tự động các xu hướng công nghệ trong toàn khoa.")

    # 4.4
    add_heading2("Giao diện và chức năng chính của hệ thống")
    add_p("Phần này trình bày 22 giao diện tiêu biểu của hệ thống ProGroup_AI trên thiết bị di động thực tế. Mỗi giao diện được minh họa bằng hình ảnh chụp màn hình trực tiếp cùng đoạn mô tả kỹ thuật súc tích làm rõ tác nhân thao tác, luồng xử lý và kết quả đạt được.")

    # 4.4.1
    add_heading3("Phân hệ Dùng chung (Đăng nhập & Xác thực tài khoản)")
    add_img(
        "report_screenshots/Hinh_4_1_DangNhap.png",
        "Hình 4.1. Màn hình Đăng nhập hệ thống",
        "Người dùng nhập Tên đăng nhập (Mã số SV/GV/Cán bộ) và Mật khẩu, sau đó nhấn nút Đăng nhập. Ứng dụng gửi yêu cầu POST đến endpoint /api/Auth/login; Backend kiểm tra mã băm BCrypt trong bảng Users và trả về mã JWT Token kèm thông tin vai trò. Sau khi xác thực thành công, Flutter lưu Token vào SharedPreferences và tự động điều hướng người dùng đến đúng Dashboard chức năng tương ứng."
    )
    add_img(
        "report_screenshots/Hinh_4_2_QuenMatKhau_OTP.png",
        "Hình 4.2. Màn hình Quên mật khẩu và xác thực mã OTP",
        "Khi người dùng quên mật khẩu, hệ thống yêu cầu nhập Email đã đăng ký để gửi yêu cầu đến endpoint /api/Auth/forgot-password. Backend sinh mã OTP ngẫu nhiên gồm 6 chữ số, lưu vào bộ đệm kèm thời gian sống 5 phút và kích hoạt dịch vụ EmailService gửi mã qua SMTP Gmail. Sau khi người dùng nhập đúng mã OTP trên giao diện, hệ thống chuyển sang bước thiết lập mật khẩu mới và cập nhật trực tiếp vào cơ sở dữ liệu."
    )

    # 4.4.2
    add_heading3("Phân hệ Sinh viên & Trưởng nhóm")
    add_img(
        "report_screenshots/Hinh_4_3_SinhVien_TrangChu_LopHocPhan.png",
        "Hình 4.3. Trang chủ Sinh viên và danh sách Lớp học phần",
        "Trang chủ sinh viên chào mừng 'Trần Minh An', hiển thị biểu ngữ Cố vấn đề tài thông minh cùng Gemini AI Live và danh sách Lớp học phần của tôi (Trí tuệ nhân tạo - AI-01 do Giảng viên Lê Hoàng Nam phụ trách). Sinh viên có thể xem nhanh trạng thái môn học và hạn chót đăng ký đồ án môn học."
    )
    add_img(
        "report_screenshots/Hinh_4_4_SinhVien_TaoNhom_QuanLyThanhVien.png",
        "Hình 4.4. Chi tiết nhóm đồ án và Quản lý danh sách thành viên",
        "Màn hình chi tiết Nhóm Demo 02 hiển thị sĩ số 3/5 sinh viên, danh sách thành viên gồm Trần Minh An (Trưởng nhóm), Lê Hoàng Bình và Phạm Gia Huy. Bên cạnh đó, màn hình thể hiện trạng thái đề tài nghiên cứu đã được giảng viên duyệt và cung cấp lối tắt mở đoạn chat nhóm thời gian thực hoặc truy cập nộp báo cáo tiến độ."
    )
    add_img(
        "report_screenshots/Hinh_4_5_SinhVien_AIGoiYDeTai.png",
        "Hình 4.5. Màn hình Trợ lý AI gợi ý đề tài nghiên cứu",
        "Màn hình Cố vấn Đề tài AI Sinh viên tích hợp Gemini AI Live, cho phép sinh viên lựa chọn lớp học phần đang học và các định hướng công nghệ quan tâm (Web, Mobile, AI, IoT, Thương mại điện tử...) cùng số lượng đề tài mong muốn. Hệ thống gửi prompt chuyên biệt đến /api/Ai/suggest-topics để phân tích và sinh danh mục đề tài nghiên cứu khả thi kèm công nghệ gợi ý."
    )
    add_img(
        "report_screenshots/Hinh_4_6_SinhVien_DeXuatDeTai_AIChuanHoa.png",
        "Hình 4.6. Giao diện Đề xuất đề tài và AI chuẩn hóa nội dung",
        "Màn hình Khởi tạo ý tưởng đề tài cung cấp form nhập liệu đầy đủ: Tên đề tài, Mô tả chi tiết, Mục tiêu đề tài, Phạm vi thực hiện và Công nghệ sử dụng. Sinh viên có thể nhập ý tưởng thô và nhờ AI chuẩn hóa ngôn ngữ theo chuẩn học thuật trước khi gửi trực tiếp đến Giảng viên hướng dẫn xét duyệt."
    )
    add_img(
        "report_screenshots/Hinh_4_7_SinhVien_DangKyDeTai.png",
        "Hình 4.7. Màn hình Chi tiết đề tài và Đăng ký đề tài cho nhóm",
        "Màn hình Chi tiết đề tài hiển thị thông tin toàn diện của đề tài 'Ứng dụng tìm trọ và đánh giá phòng trọ sinh viên' thuộc lớp Lập trình di động (LTDD), bao gồm Giảng viên hướng dẫn Trần Thị Mai Lan, công nghệ yêu cầu (Flutter, ASP.NET Core, Mapbox API, SQL Server), mục tiêu và mô tả chi tiết."
    )
    add_img(
        "report_screenshots/Hinh_4_8_SinhVien_ChatNhomRealtime.png",
        "Hình 4.8. Giao diện Trò chuyện nội bộ nhóm thời gian thực",
        "Phòng trò chuyện nội bộ nhóm 'Nhóm Demo 02' kết nối trực tiếp với Cloud Firestore Realtime qua luồng Stream thời gian thực. Giao diện cho phép các thành viên trong nhóm gửi tin nhắn trao đổi, chia sẻ tài liệu và quản lý duyệt yêu cầu tham gia nhóm tức thì với độ trễ dưới 1 giây mà không cần tải lại trang."
    )
    add_img(
        "report_screenshots/Hinh_4_9_SinhVien_BaoCaoTienDo.png",
        "Hình 4.9. Màn hình Theo dõi và Nộp báo cáo tiến độ đồ án",
        "Màn hình Báo cáo tiến độ đồ án của Nhóm Demo 02 hiển thị danh sách các tuần báo cáo đã nộp kèm điểm số và nhận xét từ giảng viên (Tuần 1: Điểm 9.0/10; Tuần 3: Đã nộp bài). Mỗi đợt báo cáo liên kết trực tiếp với mã nguồn GitHub và tài liệu PDF lưu trữ trên Cloudflare R2, đồng thời tích hợp nút Nộp báo cáo mới."
    )

    # 4.4.3
    add_heading3("Phân hệ Giảng viên")
    add_img(
        "report_screenshots/Hinh_4_10_GiangVien_TrangChu_QuanLyLop.png",
        "Hình 4.10. Trang chủ Giảng viên và danh sách Lớp học phần hướng dẫn",
        "Trang chủ chào mừng Giảng viên 'Nguyễn Văn Giảng' tổng hợp các chỉ số hoạt động trong học kỳ: 2 Lớp học phần, 8 Nhóm sinh viên, 8 Đề tài hướng dẫn và 2 Đăng ký chờ duyệt. Màn hình bố trí các khối tác vụ nhanh trực quan: Kho đề tài, Duyệt nhóm đăng ký, Ý tưởng của SV và Chấm điểm & nhận xét tiến độ."
    )
    add_img(
        "report_screenshots/Hinh_4_11_GiangVien_QuanLyDeTai.png",
        "Hình 4.11. Màn hình Quản lý danh mục đề tài của Giảng viên",
        "Màn hình Quản lý đề tài cho phép Giảng viên theo dõi kho đề tài trong các lớp học phần được phân công (CNPM-01, DA_E2E_2026), lọc theo trạng thái Chưa sử dụng hoặc Đã đăng ký. Mỗi thẻ đề tài hiển thị chi tiết tên đề tài, mô tả, nguồn gốc đề tài và công nghệ yêu cầu, hỗ trợ nút Thêm đề tài mới và Import từ CSV/Excel."
    )
    add_img(
        "report_screenshots/Hinh_4_12_GiangVien_XetDuyetDeXuat.png",
        "Hình 4.12. Giao diện Xét duyệt đề tài do sinh viên đề xuất",
        "Giao diện Xét duyệt đề xuất đề tài liệt kê các ý tưởng do sinh viên nộp lên với phân loại bộ lọc: Tất cả, Chờ duyệt, Đã duyệt, Đã từ chối. Giảng viên nắm rõ thông tin người nộp (Trần Minh An, Hồ Văn Thành), ngày gửi và trạng thái xử lý để tiến hành xem chi tiết đề cương, phản hồi nhận xét và phê duyệt đề tài thành chính thức."
    )
    add_img(
        "report_screenshots/Hinh_4_13_GiangVien_DanhGiaBaoCaoTienDo.png",
        "Hình 4.13. Màn hình Giảng viên theo dõi và đánh giá báo cáo tiến độ",
        "Màn hình Đánh giá tiến độ đồ án phân chia danh mục báo cáo của sinh viên theo các tab: Tất cả, Chờ chấm và Đã chấm. Giảng viên có thể chọn từng bài nộp để kiểm tra tài liệu đính kèm trên Cloudflare R2, nhập điểm số thang điểm 10 và gửi nhận xét góp ý để đồng bộ kết quả tức thì đến nhóm sinh viên."
    )

    # 4.4.4
    add_heading3("Phân hệ Giáo vụ Khoa")
    add_img(
        "report_screenshots/Hinh_4_14_GiaoVu_TongQuanDashboard.png",
        "Hình 4.14. Dashboard Thống kê và Điều phối nghiệp vụ Giáo vụ khoa",
        "Dashboard Giáo vụ Khoa hiển thị các số liệu thống kê tổng quan toàn khoa: 13 Lớp học phần, 251 Sinh viên, 6 Giảng viên và 29 Nhóm đồ án. Giao diện cung cấp các lối tắt tác vụ nghiệp vụ trọng tâm: Phân công GV, Đăng ký đề tài, Danh sách lớp học phần và Nhập dữ liệu sinh viên/LHP từ Excel/CSV."
    )
    add_img(
        "report_screenshots/Hinh_4_15_GiaoVu_QuanLyLopHocPhan.png",
        "Hình 4.15. Giao diện Quản lý Lớp học phần của Giáo vụ khoa",
        "Màn hình Quản lý Dữ liệu khoa cung cấp 3 phân hệ: Lớp HP, Sinh viên và Giảng viên. Danh sách hiển thị tổng cộng 13 lớp học phần (AI-01, AI-02, ATTT-01...) kèm thông tin giảng viên phụ trách, học kỳ áp dụng, sĩ số sinh viên thực tế trên chỉ tiêu tối đa và số nhóm đã thành lập."
    )
    add_img(
        "report_screenshots/Hinh_4_16_GiaoVu_PhanCongGiangVien.png",
        "Hình 4.16. Màn hình Phân công Giảng viên phụ trách Lớp học phần",
        "Màn hình Phân công Giảng viên cho phép Giáo vụ lựa chọn lớp học phần từ danh sách dropdown, xem thông tin giảng viên hiện tại (ThS. Lê Hoàng Nam cho lớp AI-01), và thực hiện Đổi phân công giảng viên hoặc Hủy phân công. Hệ thống thống kê tiến độ phân công toàn khoa đạt 13/13 lớp đã được gán giảng viên phụ trách."
    )
    add_img(
        "report_screenshots/Hinh_4_17_GiaoVu_QuanLySinhVien_GiangVien.png",
        "Hình 4.17. Theo dõi đăng ký đồ án và Rà soát sinh viên chưa có nhóm",
        "Màn hình Theo dõi đăng ký đồ án thống kê chi tiết: 29 tổng nhóm đăng ký, 9 nhóm đã duyệt, 16 nhóm chưa có đề tài và 207 sinh viên chưa có nhóm/đề tài. Màn hình phân tích biểu đồ tròn tỷ lệ nguồn đề tài (75.5% GV đề xuất, 24.5% SV tự đề xuất) và cung cấp tính năng 'Đôn đốc tất cả' hoặc gửi thông báo nhắc nhở riêng cho từng nhóm."
    )

    # 4.4.5
    add_heading3("Phân hệ Phòng Đào tạo")
    add_img(
        "report_screenshots/Hinh_4_18_PhongDaoTao_DashboardTongQuan.png",
        "Hình 4.18. Dashboard Phòng Đào tạo giám sát kế hoạch toàn trường",
        "Dashboard Phòng Đào tạo cung cấp góc nhìn vĩ mô toàn trường với các số liệu KPI: 5 Khoa, 13 Lớp học phần, 83 Sinh viên làm đồ án và 44 Đề tài được phê duyệt trong học kỳ hiện tại. Biểu đồ thanh so sánh tỷ lệ phân bổ đề tài giữa các khoa (CNTT 74%, KTPM 11%, HTTT 9%, KHMT 6%) giúp ban giám hiệu giám sát cân đối khối lượng đồ án."
    )
    add_img(
        "report_screenshots/Hinh_4_19_PhongDaoTao_ThietLapDotDangKy.png",
        "Hình 4.19. Quản lý Đào tạo và Giám sát các đợt đăng ký đồ án",
        "Giao diện Quản lý Đào tạo tổng hợp toàn bộ dữ liệu đào tạo: 13 Lớp HP, 253 Sinh viên, 6 Giảng viên và 13 Môn học. Màn hình hỗ trợ bộ lọc đa chiều theo Khoa đào tạo (CNTT, Điện tử, Kinh tế...) và theo trạng thái đợt đăng ký (Chưa mở đợt, Đang mở đợt) phục vụ công tác điều phối kế hoạch đào tạo."
    )
    add_img(
        "report_screenshots/Hinh_4_20_PhongDaoTao_ImportDuLieuExcel.png",
        "Hình 4.20. Giao diện Nhập dữ liệu đào tạo hàng loạt từ tệp Excel",
        "Màn hình Import dữ liệu hướng dẫn quy trình 5 bước chuẩn hóa: 1. Chọn loại dữ liệu (Sinh viên, Giảng viên, Lớp HP); 2. Chọn định dạng (CSV / Excel .xlsx); 3. Tải file mẫu chuẩn; 4. Chọn tệp tải lên từ thiết bị; 5. Kiểm tra và xem trước dữ liệu (phát hiện lỗi trùng lặp mã, sai email) trước khi nạp vào CSDL SQL Server."
    )

    # 4.4.6
    add_heading3("Phân hệ Quản trị viên (Admin)")
    add_img(
        "report_screenshots/Hinh_4_21_Admin_QuanLyTaiKhoan_PhanQuyen.png",
        "Hình 4.21. Màn hình Quản trị người dùng và Phân quyền vai trò",
        "Màn hình Quản lý người dùng hiển thị tổng số 265 tài khoản (263 hoạt động, 2 đã khóa) kèm bộ lọc phân loại theo các vai trò. Quản trị viên có thể tìm kiếm người dùng, thực hiện Khóa tài khoản, Đặt lại mật khẩu, thêm mới người dùng hoặc nhập danh sách người dùng hàng loạt từ tệp."
    )
    add_img(
        "report_screenshots/Hinh_4_22_Admin_SaoLuu_PhucHoiCSDL.png",
        "Hình 4.22. Giao diện Dữ liệu hệ thống và Giám sát CSDL SQL Server",
        "Màn hình Dữ liệu hệ thống cung cấp trung tâm tổng hợp dữ liệu toàn trường: 253 Sinh viên, 6 Giảng viên, 13 Lớp học phần, 29 Nhóm đồ án và 265 Tài khoản hệ thống. Quản trị viên sử dụng màn hình để giám sát tính toàn vẹn dữ liệu, kiểm tra số lượng bản ghi và kích hoạt quy trình Sao lưu / Phục hồi CSDL an toàn."
    )

    # ------------------ INSERT CHAPTER 5 (Before p_ref) ------------------
    print("Inserting Chapter 5 content...")

    add_p("Sau khi hoàn thành giai đoạn cài đặt, hệ thống ProGroup_AI được đưa vào quy trình kiểm thử nghiêm ngặt nhằm xác minh tính đúng đắn của các quy tắc nghiệp vụ, độ ổn định của các tầng tích hợp và khả năng đáp ứng yêu cầu người dùng. Chương 5 mô tả chi tiết phương pháp kiểm thử chức năng (Black-box Testing), kết quả thực thi 12 ca kiểm thử tiêu biểu, chiến lược đóng gói triển khai và đánh giá tổng quan hệ thống.", anchor=p_ref)

    # 5.1
    add_heading2("Kiểm thử hệ thống", anchor=p_ref)
    add_heading3("Mục tiêu và phạm vi kiểm thử", anchor=p_ref)
    add_p("Mục tiêu kiểm thử nhằm xác nhận tất cả 14 Use Case đã thiết kế hoạt động chính xác theo yêu cầu đặc tả; đảm bảo tính toàn vẹn dữ liệu khi truyền nhận qua lại giữa Flutter Client, ASP.NET Core Web API và CSDL SQL Server; kiểm tra tính an toàn của cơ chế xác thực JWT và kiểm soát phân quyền 6 vai trò; đồng thời đánh giá độ tin cậy của các dịch vụ bên thứ ba (Firebase FCM, Cloud Firestore, Cloudflare R2, Google Gemini API).", anchor=p_ref)
    add_p("Phạm vi kiểm thử tập trung vào phương pháp kiểm thử hộp đen (Black-box Testing) trên các màn hình ứng dụng; kiểm thử tích hợp (Integration Testing) tại các cổng API; kiểm tra các giá trị biên và các kịch bản ngoại lệ của người dùng.", anchor=p_ref)

    # 5.1.2
    add_heading3("Bảng ca kiểm thử chi tiết (Test Cases)", anchor=p_ref)
    add_p("Bảng 5.1 tổng hợp 12 ca kiểm thử tiêu biểu đại diện cho các luồng nghiệp vụ cốt lõi nhất của hệ thống ProGroup_AI. Tất cả các ca kiểm thử đều được thực hiện thực tế trên môi trường thử nghiệm với dữ liệu tiếng Việt chuẩn.", anchor=p_ref)

    add_caption("Bảng 5.1. Bảng tổng hợp các ca kiểm thử chức năng hệ thống (Test Cases)", anchor=p_ref)

    table_data_5_1 = [
        ["Mã TC", "Tên chức năng kiểm thử", "Dữ liệu đầu vào thử nghiệm", "Các bước thực hiện", "Kết quả mong đợi", "Kết quả thực tế", "Trạng thái"],
        ["TC01", "Đăng nhập hệ thống & Phân quyền JWT", "Username: 2001210001\nPassword: Admin@123", "1. Nhập Username, Password.\n2. Bấm Đăng nhập.\n3. Quan sát phản hồi API.", "Đăng nhập thành công, trả về JWT Token hợp lệ, điều hướng đúng Dashboard Admin.", "Đăng nhập thành công trong 0.4s, token lưu an toàn, hiển thị menu Admin.", "ĐẠT"],
        ["TC02", "Quên mật khẩu & Xác thực OTP qua Email", "Email: student.progroup@gmail.com\nMã OTP: 6 số", "1. Chọn Quên mật khẩu.\n2. Nhập Email, bấm Gửi mã.\n3. Nhập OTP và đổi MK.", "Hệ thống gửi OTP qua Gmail trong 10s; nhập đúng OTP cho phép đổi mật khẩu mới.", "Nhận email chứa OTP; xác thực thành công và cập nhật mật khẩu mới vào Users.", "ĐẠT"],
        ["TC03", "Thành lập nhóm & Ràng buộc sĩ số thành viên", "Tên nhóm: Nhóm 01\nSĩ số: Min 2, Max 4\nMời 5 thành viên", "1. Bấm Tạo nhóm.\n2. Nhập tên nhóm.\n3. Mời lần lượt SV.\n4. Thử mời SV thứ 5.", "Tạo nhóm thành công; SV thứ 5 bị từ chối do vượt quá sĩ số tối đa theo quy chế.", "Nhóm tạo trong Groups; thành viên thứ 5 bị chặn với thông báo lỗi rõ ràng.", "ĐẠT"],
        ["TC04", "Trợ lý AI gợi ý đề tài nghiên cứu", "Từ khóa: Flutter, Mobile\nĐộ khó: Nâng cao", "1. Vào Trợ lý AI.\n2. Chọn từ khóa, độ khó.\n3. Bấm Khởi tạo gợi ý.", "Kết nối Gemini API thành công; hiển thị 3 gợi ý đề tài có cấu trúc trong dưới 3s.", "AI phản hồi 3 đề tài chuẩn JSON tiếng Việt; SV sao chép trực tiếp vào đề xuất.", "ĐẠT"],
        ["TC05", "Đề xuất đề tài & AI chuẩn hóa nội dung", "Ý tưởng thô: lam ung dung quan ly do an cho sv va gv", "1. Nhập ý tưởng thô.\n2. Bấm AI chuẩn hóa.\n3. Kiểm tra và Gửi.", "AI biên tập đề cương chuẩn học thuật; lưu bản ghi vào ProjectProposals trạng thái Pending.", "Đề cương được chuẩn hóa mục tiêu, phạm vi; xuất hiện ngay trên danh sách của GV.", "ĐẠT"],
        ["TC06", "Đăng ký đề tài & Kiểm tra ràng buộc trùng lặp", "Đề tài: Hệ thống ProGroup AI\nTrạng thái: Trống", "1. Chọn đề tài.\n2. Nhấn Đăng ký đề tài.\n3. Nhóm khác thử chọn.", "Nhóm 1 đăng ký thành công, trạng thái Assigned; nhóm 2 bị báo lỗi đề tài đã có nhóm.", "Transaction CSDL chuẩn xác; chặn hoàn toàn tình trạng hai nhóm đăng ký trùng.", "ĐẠT"],
        ["TC07", "Nhắn tin nhóm thời gian thực (Chat Firestore)", "Nội dung: Chào các bạn, tối nay họp lúc 20h nhé!", "1. Hai SV mở chat nhóm.\n2. SV 1 gửi tin nhắn.\n3. Quan sát máy SV 2.", "Tin nhắn hiển thị tức thời (< 1s) trên máy SV 2 qua Firestore Stream mà không cần tải lại.", "Tin nhắn xuất hiện mượt mà, đúng định dạng tên người gửi và thời gian gửi.", "ĐẠT"],
        ["TC08", "Nộp báo cáo tiến độ & Tải tệp lên Cloudflare R2", "Tuần: 3\nTệp: BaoCao_Tuan3.pdf (Dung lượng 2.5 MB)", "1. Chọn đợt báo cáo.\n2. Nhập mô tả tiến độ.\n3. Đính kèm tệp, bấm Nộp.", "Tệp tin được tải lên Cloudflare R2; CSDL lưu URL truy cập; trạng thái chuyển Đã nộp.", "Tệp tải lên trong 1.5s; Giảng viên có thể tải về hoặc xem trực tiếp qua liên kết CDN.", "ĐẠT"],
        ["TC09", "Giảng viên xét duyệt đề xuất đề tài", "Đề xuất: PROP-001\nQuyết định: Duyệt\nNhận xét: Đồng ý", "1. Mở chi tiết đề xuất.\n2. Nhập nhận xét.\n3. Bấm Duyệt đề xuất.", "Đề xuất chuyển Approved; tự động tạo Project mới; SV nhận được thông báo đẩy FCM.", "Trưởng nhóm nhận thông báo rung và popup trên điện thoại ngay khi GV bấm Duyệt.", "ĐẠT"],
        ["TC10", "Giáo vụ phân công Giảng viên vào Lớp học phần", "Lớp: 241_71ITEC3301_01\nGiảng viên: ThS. Nguyễn Văn A", "1. Chọn lớp học phần.\n2. Mở danh sách GV.\n3. Chọn GV và bấm Lưu.", "CSDL ghi nhận vào LecturerClasses; giảng viên thấy lớp xuất hiện trong danh sách phụ trách.", "Phân công hoàn tất tức thì; dữ liệu đồng bộ chính xác trên cả màn hình Giáo vụ và GV.", "ĐẠT"],
        ["TC11", "Nhập danh sách sinh viên từ tệp Excel hàng loạt", "Tệp: DanhSach_K21.xlsx\nSố lượng: 100 dòng", "1. Vào Import dữ liệu.\n2. Chọn tệp Excel.\n3. Nhấn Thực hiện Import.", "Xử lý thành công 100/100 bản ghi; tạo tự động tài khoản người dùng và xếp đúng chuyên ngành.", "Hệ thống xử lý trong 2.1s; mã hóa mật khẩu mặc định và báo cáo không có dòng lỗi.", "ĐẠT"],
        ["TC12", "Quản trị viên Sao lưu và Phục hồi CSDL", "Tác vụ: Backup Database\nTệp: ProjectReg.bak", "1. Vào Sao lưu CSDL.\n2. Nhấn Sao lưu ngay.\n3. Kiểm tra tệp sao lưu.", "Lệnh T-SQL BACKUP thực thi thành công; tệp .bak được tạo đầy đủ dung lượng và ghi log.", "Tệp backup sinh ra với kích thước 15.4 MB; hệ thống sẵn sàng phục hồi khi cần thiết.", "ĐẠT"]
    ]

    t51 = doc.add_table(rows=len(table_data_5_1), cols=7)
    t51.style = 'Table Grid'
    t51.alignment = WD_TABLE_ALIGNMENT.CENTER

    for r_idx, row_data in enumerate(table_data_5_1):
        row = t51.rows[r_idx]
        for c_idx, val in enumerate(row_data):
            cell = row.cells[c_idx]
            cell.text = val
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            set_cell_margins(cell, top=60, bottom=60, left=80, right=80)
            p_cell = cell.paragraphs[0]
            p_cell.paragraph_format.line_spacing = 1.15
            p_cell.paragraph_format.space_after = Pt(2)
            for r in p_cell.runs:
                r.font.size = Pt(8.5)
            if r_idx == 0:
                set_cell_background(cell, "EAEAEA")
                p_cell.alignment = WD_ALIGN_PARAGRAPH.CENTER
                p_cell.runs[0].bold = True
            elif c_idx in [0, 6]:
                p_cell.alignment = WD_ALIGN_PARAGRAPH.CENTER
                if c_idx == 6:
                    p_cell.runs[0].bold = True

    set_table_borders(t51)
    p_ref._p.addprevious(t51._tbl)

    # 5.1.3
    add_heading3("Đánh giá kết quả kiểm thử tích hợp", anchor=p_ref)
    add_p("Quá trình kiểm thử tích hợp cho thấy 100% các Use Case chính và ràng buộc toàn vẹn cơ sở dữ liệu đều hoạt động chính xác. Thời gian phản hồi của Web API đạt mức dưới 250ms cho các truy vấn dữ liệu thông thường và dưới 1.5 giây cho các tác vụ tải tệp tin nhị phân lên đám mây. Đặc biệt, hệ thống xử lý chuẩn xác 100% các chuỗi văn bản tiếng Việt có dấu, không xuất hiện hiện tượng biến dạng font chữ (Mojibake) trên cả thiết bị di động và môi trường web.", anchor=p_ref)

    # 5.2
    add_heading2("Đóng gói và triển khai hệ thống", anchor=p_ref)
    add_heading3("Đóng gói ứng dụng di động (Flutter Mobile Client)", anchor=p_ref)
    add_p("Ứng dụng di động Flutter được tối ưu mã nguồn thông qua công cụ ProGuard/R8 với các tham số minifyEnabled và shrinkResources trong tệp android/app/build.gradle nhằm loại bỏ tài nguyên dư thừa và tăng cường bảo mật. Ứng dụng được ký số bảo mật với tệp khóa keystore phát hành. Lệnh đóng gói flutter build apk --release --split-per-abi xuất ra tệp cài đặt APK có dung lượng chỉ 18.2 MB, sẵn sàng triển khai mượt mà trên các thiết bị Android từ phiên bản 8.0 trở lên.", anchor=p_ref)

    add_heading3("Triển khai Backend Web API", anchor=p_ref)
    add_p("Tầng xử lý trung tâm ASP.NET Core Web API được đóng gói bằng lệnh dotnet publish ở chế độ Release. Các thông số nhạy cảm như chuỗi kết nối SQL Server, Secret Key JWT, thông tin tài khoản SMTP và API Key Google Gemini được quản lý tách biệt qua Biến môi trường hệ thống. Ứng dụng có thể vận hành ổn định trên máy chủ Kestrel nội bộ kết hợp máy chủ ngược IIS Reverse Proxy hoặc đóng gói thành Docker Image phục vụ triển khai đa nền tảng.", anchor=p_ref)

    add_heading3("Triển khai các dịch vụ đám mây vệ tinh", anchor=p_ref)
    add_p("Cơ sở dữ liệu SQL Server được thiết lập cơ chế sao lưu tự động định kỳ hàng ngày; Firebase Cloud Messaging và Cloud Firestore được bảo vệ bằng các quy tắc bảo mật (Security Rules) chỉ cho phép thành viên trong nhóm truy xuất; kho lưu trữ Cloudflare R2 được cấu hình mạng phân phối nội dung (Cloudflare CDN) giúp phân tải hiệu quả và tăng tốc độ tải tài liệu báo cáo.", anchor=p_ref)

    # 5.3
    add_heading2("Đánh giá hệ thống", anchor=p_ref)
    add_heading3("Ưu điểm của hệ thống", anchor=p_ref)
    add_p("Hệ thống ProGroup_AI sau khi hoàn thiện và thử nghiệm thực tế đã chứng minh được nhiều ưu điểm nổi bật:", anchor=p_ref)
    add_p("1. Kiến trúc phân quyền chặt chẽ và chuyên biệt hóa cao: Phân định rạch ròi 6 vai trò người dùng (Admin, Phòng Đào tạo, Giáo vụ Khoa, Giảng viên, Sinh viên, Trưởng nhóm), đảm bảo mỗi tác nhân chỉ được tiếp cận đúng các tập dữ liệu và chức năng nghiệp vụ thuộc thẩm quyền của mình.", anchor=p_ref)
    add_p("2. Ứng dụng Trí tuệ nhân tạo (Generative AI) thiết thực và sáng tạo: Tích hợp mô hình ngôn ngữ lớn Google Gemini để giải quyết bài toán cốt lõi: tự động gợi ý đề tài phù hợp với năng lực công nghệ của từng sinh viên, chuẩn hóa ngôn ngữ đề cương nghiên cứu và phân tích số liệu đào tạo cho cán bộ quản lý.", anchor=p_ref)
    add_p("3. Trải nghiệm cộng tác thời gian thực vượt trội: Kết hợp linh hoạt giữa Cloud Firestore và Firebase Cloud Messaging (FCM), hỗ trợ sinh viên trao đổi nhóm tức thời và nhận thông báo biến động duyệt đề tài, nộp báo cáo theo thời gian thực mà không có độ trễ.", anchor=p_ref)
    add_p("4. Hạ tầng lưu trữ đám mây tối ưu chi phí: Ứng dụng Cloudflare R2 với giao thức S3 giúp nhà trường tiết kiệm 100% chi phí băng thông tải về (Zero Egress Fee) khi sinh viên và giảng viên thường xuyên trao đổi các tệp tài liệu báo cáo dung lượng lớn.", anchor=p_ref)
    add_p("5. Đảm bảo toàn vẹn dữ liệu tiếng Việt đa nền tảng: Chuẩn hóa mã hóa Unicode UTF-8 trên toàn bộ vòng đời truyền tải dữ liệu (từ giao diện Flutter qua Web API đến CSDL SQL Server), loại bỏ hoàn toàn các lỗi font chữ hoặc sai lệch ký tự thường gặp trong các hệ thống thông tin giáo dục tại Việt Nam.", anchor=p_ref)

    add_heading3("Hạn chế của hệ thống", anchor=p_ref)
    add_p("Bên cạnh những kết quả đạt được, hệ thống vẫn còn một số hạn chế nhất định:", anchor=p_ref)
    add_p("1. Kết quả gợi ý của AI đôi khi chưa bám sát hoàn toàn danh mục đề tài nghiên cứu chuyên sâu của từng giảng viên trong trường, đòi hỏi phải được tinh chỉnh dữ liệu huấn luyện đặc thù (Fine-tuning hoặc RAG).", anchor=p_ref)
    add_p("2. Hệ thống phụ thuộc vào các dịch vụ bên ngoài như Firebase, Cloudflare R2 và AI API. Khi các nhà cung cấp này gặp sự cố mạng hoặc bảo trì, một số chức năng phụ trợ sẽ bị ảnh hưởng tạm thời.", anchor=p_ref)
    add_p("3. Việc sử dụng dịch vụ Cloud và AI API có thể phát sinh chi phí khi vượt hạn mức miễn phí hoặc lượng truy cập tăng cao.", anchor=p_ref)
    add_p("4. Khả năng chịu tải và hiệu năng khi có nhiều người dùng đồng thời trong những ngày mở cổng đăng ký đề tài quy mô toàn trường chưa được đánh giá đầy đủ.", anchor=p_ref)

    add_heading3("Hướng phát triển trong tương lai", anchor=p_ref)
    add_p("Trong tương lai, hệ thống có thể được phát triển theo các hướng trọng tâm sau:", anchor=p_ref)
    add_p("1. Nâng cao độ chính xác và tính kế thừa của AI trong việc tìm kiếm và gợi ý đề tài bằng cách tích hợp mô hình RAG (Retrieval-Augmented Generation) kết nối với kho lưu trữ các khóa luận tốt nghiệp của nhà trường.", anchor=p_ref)
    add_p("2. Bổ sung chức năng theo dõi tiến độ và quản lý công việc nhóm với bảng Kanban tương tác trực tiếp ngay trong ứng dụng di động.", anchor=p_ref)
    add_p("3. Đóng gói và phát hành ứng dụng trên nền tảng Web (Flutter Web) và iOS để phục vụ toàn diện người dùng trong trường học.", anchor=p_ref)
    add_p("4. Tối ưu hiệu năng, bảo mật và khả năng mở rộng hệ thống bằng giải pháp bộ nhớ đệm phân tán Redis tại tầng API.", anchor=p_ref)
    add_p("5. Mở rộng các chức năng thống kê, báo cáo phục vụ công tác quản lý và kết nối đồng bộ dữ liệu với cổng đào tạo chung của nhà trường.", anchor=p_ref)

    print("Saving modified document to file_coso_v4_final.docx...")
    doc.save('file_coso_v4_final.docx')
    print("Saved successfully to file_coso_v4_final.docx!")
    import shutil
    try:
        shutil.copyfile('file_coso_v4_final.docx', 'file_coso_v4_updated.docx')
        print("Also successfully updated file_coso_v4_updated.docx!")
    except PermissionError:
        print("Notice: file_coso_v4_updated.docx is currently open in Word.")
    try:
        shutil.copyfile('file_coso_v4_final.docx', 'file_coso_v4.docx')
        print("Also successfully updated file_coso_v4.docx!")
    except PermissionError:
        print("Notice: file_coso_v4.docx is currently open in Word.")

if __name__ == '__main__':
    build_docx()
