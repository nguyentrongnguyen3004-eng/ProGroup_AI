# -*- coding: utf-8 -*-
import os
import csv
import zipfile
import io
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

OUT_DIR = os.path.abspath("sample_import_files")
os.makedirs(OUT_DIR, exist_ok=True)

# Clean out old files in local dir
for f in os.listdir(OUT_DIR):
    if f.endswith(".csv") or f.endswith(".xlsx"):
        os.remove(os.path.join(OUT_DIR, f))

TEMPLATES = {
    "sinh_vien": {
        "headers": ["MSSV", "Họ tên", "Email", "Lớp", "Trạng thái"],
        "rows": [
            ["2001216016", "Nguyễn Trọng Nguyên", "2001216016@hufi.edu.vn", "12DHTH01", "Đang học"],
            ["2001216315", "Lâm Phượng Vĩ", "2001216315@hufi.edu.vn", "12DHTH01", "Đang học"],
            ["2001215001", "Trần Quốc Bảo", "2001215001@hufi.edu.vn", "12DHTH02", "Đang học"],
            ["2001215002", "Lê Thị Mai", "2001215002@hufi.edu.vn", "12DHTH02", "Đang học"],
            ["2001215003", "Phạm Văn An", "2001215003@hufi.edu.vn", "12DHTH03", "Đang học"],
            ["2001215004", "Hoàng Kim Ngân", "2001215004@hufi.edu.vn", "12DHTH03", "Đang học"],
            ["2001215005", "Đặng Minh Tuấn", "2001215005@hufi.edu.vn", "12DHTH04", "Đang học"],
            ["2001215006", "Vũ Bích Hạnh", "2001215006@hufi.edu.vn", "12DHTH04", "Đang học"]
        ]
    },
    "giang_vien": {
        "headers": ["Mã giảng viên", "Họ tên", "Email", "Khoa", "Bộ môn", "Trạng thái"],
        "rows": [
            ["GV001", "TS. Nguyễn Văn A", "gv.nguyenvana@hufi.edu.vn", "Công nghệ thông tin", "Công nghệ phần mềm", "Đang công tác"],
            ["GV002", "ThS. Trần Thị B", "gv.tranthib@hufi.edu.vn", "Công nghệ thông tin", "Hệ thống thông tin", "Đang công tác"],
            ["GV003", "TS. Lê Hoàng C", "gv.lehoangc@hufi.edu.vn", "Công nghệ thông tin", "Mạng máy tính", "Đang công tác"],
            ["GV004", "ThS. Phạm Ngọc D", "gv.phamngocd@hufi.edu.vn", "Công nghệ thông tin", "Khoa học máy tính", "Đang công tác"],
            ["GV005", "TS. Vũ Đình E", "gv.vudinhe@hufi.edu.vn", "Công nghệ thông tin", "Trí tuệ nhân tạo", "Đang công tác"]
        ]
    },
    "lop_hoc_phan": {
        "headers": ["Mã lớp học phần", "Mã học phần", "Tên học phần", "Mã giảng viên (không bắt buộc)", "Học kỳ", "Trạng thái"],
        "rows": [
            ["241_0101_01", "0101", "Phát triển ứng dụng di động", "GV001", "Học kỳ 1 (2026-2027)", "Đang mở"],
            ["241_0102_01", "0102", "Phát triển ứng dụng Web nâng cao", "GV002", "Học kỳ 1 (2026-2027)", "Đang mở"],
            ["241_0103_01", "0103", "Chuyên đề Trí tuệ nhân tạo", "GV003", "Học kỳ 1 (2026-2027)", "Đang mở"],
            ["241_0104_01", "0104", "Kiến trúc và Thiết kế phần mềm", "GV004", "Học kỳ 1 (2026-2027)", "Đang mở"],
            ["241_0105_01", "0105", "Điện toán đám mây và DevOps", "GV005", "Học kỳ 1 (2026-2027)", "Đang mở"]
        ]
    },
    "hoc_phan": {
        "headers": ["Mã học phần", "Tên học phần", "Số tín chỉ", "Bộ môn", "Trạng thái"],
        "rows": [
            ["0101", "Phát triển ứng dụng di động", "3", "Công nghệ phần mềm", "Đang giảng dạy"],
            ["0102", "Phát triển ứng dụng Web nâng cao", "3", "Công nghệ phần mềm", "Đang giảng dạy"],
            ["0103", "Chuyên đề Trí tuệ nhân tạo", "3", "Khoa học máy tính", "Đang giảng dạy"],
            ["0104", "Kiến trúc và Thiết kế phần mềm", "3", "Công nghệ phần mềm", "Đang giảng dạy"],
            ["0105", "Điện toán đám mây và DevOps", "3", "Hệ thống thông tin", "Đang giảng dạy"],
            ["0106", "An toàn và Bảo mật hệ thống thông tin", "3", "Mạng máy tính", "Đang giảng dạy"]
        ]
    },
    "nguoi_dung": {
        "headers": ["Tên đăng nhập", "Mật khẩu", "Họ và tên", "Email", "Số điện thoại", "Vai trò", "Trạng thái"],
        "rows": [
            ["sinhvien_demo01", "Pass@123", "Trần Quang Khải", "khai.tq@hufi.edu.vn", "0901234501", "SINHVIEN", "Hoạt động"],
            ["sinhvien_demo02", "Pass@123", "Nguyễn Thảo My", "my.nt@hufi.edu.vn", "0901234502", "SINHVIEN", "Hoạt động"],
            ["sinhvien_demo03", "Pass@123", "Phạm Quốc Tuấn", "tuan.pq@hufi.edu.vn", "0901234503", "SINHVIEN", "Hoạt động"],
            ["giangvien_demo01", "Pass@123", "ThS. Dương Thanh Bình", "binh.dt@hufi.edu.vn", "0912345601", "GIANGVIEN", "Hoạt động"],
            ["giangvien_demo02", "Pass@123", "TS. Lê Quỳnh Chi", "chi.lq@hufi.edu.vn", "0912345602", "GIANGVIEN", "Hoạt động"],
            ["giaovu_demo01", "Pass@123", "Cô Nguyễn Thanh Trúc", "truc.nt@hufi.edu.vn", "0923456701", "GIAOVUKHOA", "Hoạt động"],
            ["pdt_demo01", "Pass@123", "Thầy Hoàng Trọng Nghĩa", "nghia.ht@hufi.edu.vn", "0934567801", "PHONGDAOTAO", "Hoạt động"]
        ]
    },
    "de_tai": {
        "headers": ["Tên đề tài", "Mô tả", "Mục tiêu", "Phạm vi", "Công nghệ sử dụng", "Nguồn đề xuất"],
        "rows": [
            [
                "Hệ thống nhận diện biển số xe thông minh",
                "Xây dựng ứng dụng di động và hệ thống tự động quét nhận diện biển số xe tự động qua camera",
                "Đạt độ chính xác nhận diện trên 95% trong điều kiện ánh sáng tiêu chuẩn",
                "Khuôn viên bãi giữ xe thông minh của trường đại học",
                "YOLOv8, Python FastAPI, Flutter, SQL Server",
                "Giảng viên"
            ],
            [
                "Ứng dụng theo dõi sức khỏe và gợi ý dinh dưỡng AI",
                "Ứng dụng di động phân tích hình ảnh bữa ăn và đề xuất thực đơn dinh dưỡng cá nhân hóa",
                "Hỗ trợ người dùng theo dõi lượng calo nạp vào và đưa ra gợi ý rèn luyện khoa học",
                "Dành cho người dùng cá nhân và sinh viên",
                "Flutter, Google Gemini API, Node.js, MongoDB",
                "Giảng viên"
            ],
            [
                "Nền tảng học trực tuyến và thi trắc nghiệm tự động",
                "Cổng quản lý khóa học trực tuyến tích hợp tính năng thi trắc nghiệm và chấm bài tự động",
                "Tối ưu hóa quy trình tổ chức kiểm tra và đánh giá kết quả học tập",
                "Áp dụng cho các môn cơ sở ngành Công nghệ thông tin",
                "ASP.NET Core, Flutter Web/Mobile, SQL Server, Docker",
                "Giảng viên"
            ],
            [
                "Hệ thống quản lý chuỗi cung ứng nông sản với Blockchain",
                "Truy xuất nguồn gốc xuất xứ nông sản sạch từ nông trại đến bàn ăn",
                "Đảm bảo tính minh bạch và chống giả mạo thông tin nguồn hàng",
                "Hợp tác xã nông nghiệp và chuỗi siêu thị bán lẻ",
                "Ethereum Smart Contract, Solidity, Flutter, Spring Boot",
                "Giảng viên"
            ],
            [
                "Ứng dụng tìm trọ và đánh giá phòng trọ sinh viên",
                "Hệ thống kết nối chủ trọ và sinh viên với bản đồ định vị và đánh giá trực quan",
                "Giúp sinh viên tìm kiếm phòng trọ an toàn, giá tốt và thông tin minh bạch",
                "Khu vực xung quanh các trường đại học tại TP. Hồ Chí Minh",
                "Flutter, Google Maps API, ASP.NET Core, Cloudflare R2",
                "Giảng viên"
            ]
        ]
    }
}

header_font = Font(name="Calibri", size=11, bold=True, color="FFFFFF")
header_fill = PatternFill(start_color="1E40AF", end_color="1E40AF", fill_type="solid")
header_align = Alignment(horizontal="center", vertical="center", wrap_text=True)

data_font = Font(name="Calibri", size=10)
data_align = Alignment(horizontal="left", vertical="center")

thin_border = Border(
    left=Side(style='thin', color='D1D5DB'),
    right=Side(style='thin', color='D1D5DB'),
    top=Side(style='thin', color='D1D5DB'),
    bottom=Side(style='thin', color='D1D5DB')
)

created_files = []

def fix_xlsx_for_dart_excel(xlsx_path):
    zin = zipfile.ZipFile(xlsx_path, 'r')
    buf = io.BytesIO()
    zout = zipfile.ZipFile(buf, 'w')
    for item in zin.infolist():
        content = zin.read(item.filename)
        if item.filename == 'xl/_rels/workbook.xml.rels':
            content = content.replace(b'Target="/xl/', b'Target="')
        zout.writestr(item, content)
    zin.close()
    zout.close()
    with open(xlsx_path, 'wb') as f:
        f.write(buf.getvalue())

for key, data in TEMPLATES.items():
    headers = data["headers"]
    rows = data["rows"]

    csv_filename = f"{key}.csv"
    csv_path = os.path.join(OUT_DIR, csv_filename)
    with open(csv_path, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(rows)
    created_files.append(csv_path)

    xlsx_filename = f"{key}.xlsx"
    xlsx_path = os.path.join(OUT_DIR, xlsx_filename)
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Dữ liệu mẫu"

    ws.append(headers)
    ws.row_dimensions[1].height = 28

    for col_idx in range(1, len(headers) + 1):
        cell = ws.cell(row=1, column=col_idx)
        cell.font = header_font
        cell.fill = header_fill
        cell.alignment = header_align
        cell.border = thin_border

    for r_idx, row in enumerate(rows, start=2):
        ws.append(row)
        ws.row_dimensions[r_idx].height = 22
        for col_idx in range(1, len(row) + 1):
            cell = ws.cell(row=r_idx, column=col_idx)
            cell.font = data_font
            cell.alignment = data_align
            cell.border = thin_border

    for col_idx in range(1, len(headers) + 1):
        max_len = len(str(headers[col_idx - 1]))
        for row in rows:
            if col_idx - 1 < len(row):
                val_str = str(row[col_idx - 1])
                max_len = max(max_len, len(val_str))
        col_letter = get_column_letter(col_idx)
        ws.column_dimensions[col_letter].width = max(max_len + 4, 15)

    wb.save(xlsx_path)
    fix_xlsx_for_dart_excel(xlsx_path)
    created_files.append(xlsx_path)

print(f"Successfully generated {len(created_files)} template files in {OUT_DIR}:")
for f in created_files:
    print(" -", os.path.basename(f), f"({os.path.getsize(f)} bytes)")
