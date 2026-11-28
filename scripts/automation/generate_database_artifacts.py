import json
import os
import subprocess
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

# Paths
OUTPUT_DIR = os.path.abspath("docs/database/erd")
RAW_META_PATH = os.path.join(OUTPUT_DIR, "raw_metadata.json")
CHECKS_PATH = os.path.join(OUTPUT_DIR, "check_constraints.json")

def load_data():
    with open(RAW_META_PATH, "r", encoding="utf-8-sig") as f:
        meta = json.load(f)
    with open(CHECKS_PATH, "r", encoding="utf-8-sig") as f:
        checks = json.load(f)
    return meta, checks

# Categorize tables into 3 functional modules
MODULE_MAP = {
    # Module 1: Người dùng, Phân quyền & Quản trị Hệ thống
    "VaiTros": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE"),
    "NguoiDungs": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE"),
    "PasswordResetOtps": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE"),
    "ThongBaos": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE"),
    "AIRequests": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE"),
    "DotImports": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE"),
    "LoiImports": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE"),

    # Module 2: Quản lý Đào tạo, Khoa & Lớp Học phần
    "Khoas": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5"),
    "HocKys": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5"),
    "HocPhans": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5"),
    "LopHocPhans": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5"),
    "SinhViens": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5"),
    "GiangViens": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5"),
    "PhanCongGiangViens": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5"),
    "SinhVienLopHocPhans": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5"),

    # Module 3: Đợt Đăng ký, Nhóm & Đề tài Đồ án
    "DotDangKyDoAns": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3"),
    "NhomDoAns": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3"),
    "ThanhVienNhoms": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3"),
    "DeTaiDoAns": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3"),
    "DangKyDeTais": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3"),
    "BaoCaoTienDos": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3"),
}

TABLE_DESCRIPTIONS = {
    "VaiTros": "Danh mục vai trò người dùng trong hệ thống (ADMIN, GIAOVUKHOA, PHONGDAOTAO, GIANGVIEN, SINHVIEN)",
    "NguoiDungs": "Bảng tài khoản người dùng trung tâm, lưu thông tin định danh, mật khẩu hash, email, trạng thái",
    "PasswordResetOtps": "Quản lý mã OTP đặt lại mật khẩu, thời hạn hết hạn và số lần thử của người dùng",
    "ThongBaos": "Lưu thông báo hệ thống, thông báo phân công, duyệt đề tài và các liên kết nghiệp vụ",
    "AIRequests": "Lịch sử tương tác và gọi API AI (Gemini) hỗ trợ gợi ý đề tài, sửa lỗi và xử lý dữ liệu",
    "DotImports": "Quản lý các đợt import dữ liệu danh sách sinh viên, giảng viên, lớp học phần từ Excel/CSV",
    "LoiImports": "Lưu chi tiết các dòng dữ liệu bị lỗi trong từng đợt import để phục vụ đối soát",
    "Khoas": "Danh mục khoa/viện đào tạo trong trường đại học (VD: Khoa CNTT, KTPM, HTTT)",
    "HocKys": "Danh mục học kỳ và năm học đào tạo (VD: Học kỳ 1 2026-2027)",
    "HocPhans": "Danh mục môn học/học phần đồ án chuyên ngành",
    "LopHocPhans": "Danh sách các lớp học phần được mở trong từng học kỳ theo khoa",
    "SinhViens": "Hồ sơ chi tiết của sinh viên (MSSV, ngày sinh, khoa), liên kết 1:1 với NguoiDungs",
    "GiangViens": "Hồ sơ chi tiết của giảng viên (Mã GV, học vị, chuyên môn, khoa), liên kết 1:1 với NguoiDungs",
    "PhanCongGiangViens": "Bảng liên kết N:N phân công giảng viên phụ trách giảng dạy cho từng lớp học phần",
    "SinhVienLopHocPhans": "Bảng liên kết N:N lưu danh sách sinh viên ghi danh theo học từng lớp học phần",
    "DotDangKyDoAns": "Quản lý các đợt mở đăng ký nhóm và đề tài đồ án theo từng lớp học phần",
    "NhomDoAns": "Thông tin nhóm sinh viên thực hiện đồ án, số lượng thành viên và trưởng nhóm",
    "ThanhVienNhoms": "Bảng liên kết N:N lưu các sinh viên tham gia vào nhóm đồ án và vai trò trong nhóm",
    "DeTaiDoAns": "Kho lưu trữ đề tài đồ án môn học (do giảng viên khởi tạo hoặc sinh viên đề xuất)",
    "DangKyDeTais": "Bản ghi nguyện vọng đăng ký đề tài của từng nhóm đồ án và kết quả phê duyệt của giảng viên",
    "BaoCaoTienDos": "Lưu báo cáo tiến độ định kỳ của nhóm đồ án, file tài liệu, link demo, nhận xét và điểm số của giảng viên",
}

COLUMN_DESCRIPTIONS = {
    # NguoiDung / VaiTro
    ("VaiTros", "VaiTroId"): "Khóa chính, mã định danh vai trò",
    ("VaiTros", "MaVaiTro"): "Mã vai trò viết tắt duy nhất (ADMIN, GIAOVUKHOA, ...)",
    ("VaiTros", "TenVaiTro"): "Tên hiển thị đầy đủ của vai trò",
    ("VaiTros", "MoTa"): "Mô tả chi tiết quyền hạn của vai trò",
    ("NguoiDungs", "NguoiDungId"): "Khóa chính, định danh tài khoản",
    ("NguoiDungs", "TenDangNhap"): "Tên đăng nhập duy nhất",
    ("NguoiDungs", "MatKhauHash"): "Chuỗi băm mật khẩu bảo mật (BCrypt/Argon2/HMAC)",
    ("NguoiDungs", "Email"): "Địa chỉ email duy nhất của người dùng",
    ("NguoiDungs", "HoTen"): "Họ và tên đầy đủ của người dùng",
    ("NguoiDungs", "SoDienThoai"): "Số điện thoại liên lạc",
    ("NguoiDungs", "AvatarUrl"): "Đường dẫn ảnh đại diện (Cloudflare R2)",
    ("NguoiDungs", "TrangThai"): "Trạng thái kích hoạt tài khoản (1: Hoạt động, 0: Khóa)",
    ("NguoiDungs", "YeuCauDoiMatKhau"): "Cờ bắt buộc đổi mật khẩu ở lần đăng nhập đầu",
    ("NguoiDungs", "CreatedAt"): "Thời điểm tạo tài khoản",
    ("NguoiDungs", "UpdatedAt"): "Thời điểm cập nhật thông tin lần cuối",
    ("NguoiDungs", "VaiTroId"): "Khóa ngoại tham chiếu VaiTros.VaiTroId",

    # SinhVien / GiangVien
    ("SinhViens", "SinhVienId"): "Khóa chính hồ sơ sinh viên",
    ("SinhViens", "NguoiDungId"): "Khóa ngoại (1:1 Unique) tham chiếu NguoiDungs.NguoiDungId",
    ("SinhViens", "MSSV"): "Mã số sinh viên duy nhất",
    ("SinhViens", "KhoaId"): "Khóa ngoại tham chiếu Khoas.KhoaId",
    ("SinhViens", "NgaySinh"): "Ngày tháng năm sinh",
    ("SinhViens", "GioiTinh"): "Giới tính (Nam, Nữ, Khác)",
    ("SinhViens", "CreatedAt"): "Thời điểm tạo hồ sơ",
    ("GiangViens", "GiangVienId"): "Khóa chính hồ sơ giảng viên",
    ("GiangViens", "NguoiDungId"): "Khóa ngoại (1:1 Unique) tham chiếu NguoiDungs.NguoiDungId",
    ("GiangViens", "MaGiangVien"): "Mã giảng viên duy nhất (VD: GV001)",
    ("GiangViens", "KhoaId"): "Khóa ngoại tham chiếu Khoas.KhoaId",
    ("GiangViens", "HocVi"): "Học vị học hàm (ThS, TS, PGS, GS)",
    ("GiangViens", "ChuyenMon"): "Lĩnh vực chuyên môn nghiên cứu",
    ("GiangViens", "CreatedAt"): "Thời điểm tạo hồ sơ",

    # Dao tao
    ("Khoas", "KhoaId"): "Khóa chính đơn vị khoa",
    ("Khoas", "MaKhoa"): "Mã khoa duy nhất (VD: CNTT, HTTT)",
    ("Khoas", "TenKhoa"): "Tên khoa đầy đủ",
    ("Khoas", "TrangThai"): "Trạng thái hoạt động của khoa",
    ("Khoas", "CreatedAt"): "Thời điểm tạo",
    ("HocKys", "HocKyId"): "Khóa chính học kỳ",
    ("HocKys", "TenHocKy"): "Tên học kỳ (Học kỳ 1, 2, hè)",
    ("HocKys", "NamHoc"): "Năm học (VD: 2026-2027)",
    ("HocKys", "NgayBatDau"): "Ngày bắt đầu học kỳ",
    ("HocKys", "NgayKetThuc"): "Ngày kết thúc học kỳ",
    ("HocKys", "TrangThai"): "Trạng thái học kỳ (1: Đang mở)",
    ("HocKys", "CreatedAt"): "Thời điểm tạo",
    ("HocPhans", "HocPhanId"): "Khóa chính học phần",
    ("HocPhans", "KhoaId"): "Khóa ngoại tham chiếu Khoas.KhoaId",
    ("HocPhans", "MaHocPhan"): "Mã học phần duy nhất (VD: IT001)",
    ("HocPhans", "TenHocPhan"): "Tên học phần đồ án",
    ("HocPhans", "SoTinChi"): "Số tín chỉ học phần",
    ("HocPhans", "MoTa"): "Mô tả đề cương tóm tắt",
    ("HocPhans", "TrangThai"): "Trạng thái học phần",
    ("HocPhans", "CreatedAt"): "Thời điểm tạo",

    # LopHocPhan & PhanCong & SinhVienLHP
    ("LopHocPhans", "LopHocPhanId"): "Khóa chính lớp học phần",
    ("LopHocPhans", "HocPhanId"): "Khóa ngoại tham chiếu HocPhans.HocPhanId",
    ("LopHocPhans", "HocKyId"): "Khóa ngoại tham chiếu HocKys.HocKyId",
    ("LopHocPhans", "KhoaId"): "Khóa ngoại tham chiếu Khoas.KhoaId",
    ("LopHocPhans", "MaLopHocPhan"): "Mã lớp học phần (VD: LTDD-01)",
    ("LopHocPhans", "TenLopHocPhan"): "Tên lớp học phần",
    ("LopHocPhans", "SoLuongToiDa"): "Số lượng sinh viên tối đa",
    ("LopHocPhans", "TrangThai"): "Trạng thái mở lớp (1: Hoạt động)",
    ("LopHocPhans", "CreatedAt"): "Thời điểm tạo",
    ("PhanCongGiangViens", "PhanCongId"): "Khóa chính phân công",
    ("PhanCongGiangViens", "LopHocPhanId"): "Khóa ngoại tham chiếu LopHocPhans.LopHocPhanId",
    ("PhanCongGiangViens", "GiangVienId"): "Khóa ngoại tham chiếu GiangViens.GiangVienId",
    ("PhanCongGiangViens", "VaiTro"): "Vai trò phân công (Giảng viên phụ trách, trợ giảng)",
    ("PhanCongGiangViens", "NgayPhanCong"): "Thời điểm thực hiện phân công",
    ("PhanCongGiangViens", "TrangThai"): "Trạng thái phân công (1: Đang có hiệu lực, 0: Đã hủy)",
    ("SinhVienLopHocPhans", "SinhVienLopHocPhanId"): "Khóa chính ghi danh",
    ("SinhVienLopHocPhans", "SinhVienId"): "Khóa ngoại tham chiếu SinhViens.SinhVienId",
    ("SinhVienLopHocPhans", "LopHocPhanId"): "Khóa ngoại tham chiếu LopHocPhans.LopHocPhanId",
    ("SinhVienLopHocPhans", "NgayThamGia"): "Thời điểm ghi danh vào lớp",
    ("SinhVienLopHocPhans", "TrangThai"): "Trạng thái tham gia (1: Đang học, 0: Rút)",

    # Dot, Nhom, ThanhVien
    ("DotDangKyDoAns", "DotDangKyId"): "Khóa chính đợt đăng ký đồ án",
    ("DotDangKyDoAns", "LopHocPhanId"): "Khóa ngoại tham chiếu LopHocPhans.LopHocPhanId",
    ("DotDangKyDoAns", "TenDot"): "Tên đợt đăng ký",
    ("DotDangKyDoAns", "NgayBatDau"): "Thời điểm mở đợt đăng ký",
    ("DotDangKyDoAns", "NgayKetThuc"): "Thời điểm đóng đợt đăng ký",
    ("DotDangKyDoAns", "MinMembers"): "Số thành viên tối thiểu mỗi nhóm",
    ("DotDangKyDoAns", "MaxMembers"): "Số thành viên tối đa mỗi nhóm",
    ("DotDangKyDoAns", "TrangThai"): "Trạng thái đợt (Chưa mở, Đang mở, Đã đóng)",
    ("DotDangKyDoAns", "CreatedAt"): "Thời điểm tạo đợt",
    ("NhomDoAns", "NhomId"): "Khóa chính nhóm đồ án",
    ("NhomDoAns", "DotDangKyId"): "Khóa ngoại tham chiếu DotDangKyDoAns.DotDangKyId",
    ("NhomDoAns", "TruongNhomId"): "Khóa ngoại tham chiếu SinhViens.SinhVienId (Trưởng nhóm)",
    ("NhomDoAns", "TenNhom"): "Tên nhóm đồ án",
    ("NhomDoAns", "TrangThai"): "Trạng thái nhóm (Đang hoạt động, Đã khóa, Đã hủy)",
    ("NhomDoAns", "CreatedAt"): "Thời điểm tạo nhóm",
    ("ThanhVienNhoms", "ThanhVienNhomId"): "Khóa chính thành viên nhóm",
    ("ThanhVienNhoms", "NhomId"): "Khóa ngoại tham chiếu NhomDoAns.NhomId",
    ("ThanhVienNhoms", "SinhVienId"): "Khóa ngoại tham chiếu SinhViens.SinhVienId",
    ("ThanhVienNhoms", "VaiTro"): "Vai trò trong nhóm (Trưởng nhóm, Thành viên)",
    ("ThanhVienNhoms", "NgayThamGia"): "Thời điểm gia nhập nhóm",
    ("ThanhVienNhoms", "TrangThai"): "Trạng thái (Chờ tham gia, Đã tham gia, Đã rời nhóm)",

    # DeTai, DangKy, BaoCao
    ("DeTaiDoAns", "DeTaiId"): "Khóa chính đề tài đồ án",
    ("DeTaiDoAns", "DotDangKyId"): "Khóa ngoại tham chiếu DotDangKyDoAns.DotDangKyId",
    ("DeTaiDoAns", "TenDeTai"): "Tên đề tài đồ án",
    ("DeTaiDoAns", "MoTa"): "Mô tả chi tiết nội dung đề tài",
    ("DeTaiDoAns", "MucTieu"): "Mục tiêu cần đạt của đề tài",
    ("DeTaiDoAns", "PhamVi"): "Phạm vi nghiên cứu & sản phẩm",
    ("DeTaiDoAns", "CongNgheDuKien"): "Các công nghệ/ngôn ngữ/framework dự kiến áp dụng",
    ("DeTaiDoAns", "NguonDeTai"): "Nguồn gốc đề tài (Giảng viên, Sinh viên đề xuất)",
    ("DeTaiDoAns", "GiangVienId"): "Khóa ngoại (nullable) tham chiếu GiangViens.GiangVienId phụ trách",
    ("DeTaiDoAns", "SinhVienDeXuatId"): "Khóa ngoại (nullable) tham chiếu SinhViens.SinhVienId người đề xuất",
    ("DeTaiDoAns", "TrangThai"): "Trạng thái sử dụng (Chưa sử dụng, Đang hoạt động, Đã khóa, Đã đăng ký)",
    ("DeTaiDoAns", "TrangThaiDuyet"): "Trạng thái phê duyệt (Chờ duyệt, Đã duyệt, Từ chối)",
    ("DeTaiDoAns", "LyDoTuChoi"): "Lý do từ chối nếu không được duyệt",
    ("DeTaiDoAns", "CreatedAt"): "Thời điểm tạo đề tài",
    ("DeTaiDoAns", "UpdatedAt"): "Thời điểm cập nhật",
    ("DangKyDeTais", "DangKyDeTaiId"): "Khóa chính đăng ký đề tài",
    ("DangKyDeTais", "NhomId"): "Khóa ngoại tham chiếu NhomDoAns.NhomId",
    ("DangKyDeTais", "DeTaiId"): "Khóa ngoại tham chiếu DeTaiDoAns.DeTaiId",
    ("DangKyDeTais", "NgayDangKy"): "Thời điểm nhóm gửi đăng ký",
    ("DangKyDeTais", "TrangThai"): "Trạng thái đăng ký (Chờ duyệt, Đã duyệt, Từ chối, Đã hủy)",
    ("DangKyDeTais", "GhiChu"): "Ghi chú bổ sung của nhóm",
    ("DangKyDeTais", "NgayDuyet"): "Thời điểm giảng viên phê duyệt/từ chối",
    ("DangKyDeTais", "GiangVienDuyetId"): "Khóa ngoại tham chiếu GiangViens.GiangVienId người duyệt",
    ("BaoCaoTienDos", "BaoCaoId"): "Khóa chính báo cáo tiến độ",
    ("BaoCaoTienDos", "NhomId"): "Khóa ngoại tham chiếu NhomDoAns.NhomId",
    ("BaoCaoTienDos", "DeTaiId"): "Mã đề tài liên kết (Logical FK tham chiếu DeTaiDoAns.DeTaiId)",
    ("BaoCaoTienDos", "TieuDe"): "Tiêu đề đợt báo cáo tiến độ",
    ("BaoCaoTienDos", "NoiDung"): "Nội dung tóm tắt kết quả hoàn thành",
    ("BaoCaoTienDos", "FileUrl"): "Đường dẫn file tài liệu/báo cáo",
    ("BaoCaoTienDos", "GithubUrl"): "Đường dẫn repository mã nguồn GitHub",
    ("BaoCaoTienDos", "DemoUrl"): "Đường dẫn video/link demo ứng dụng",
    ("BaoCaoTienDos", "TuanBaoCao"): "Số thứ tự tuần báo cáo",
    ("BaoCaoTienDos", "NgayNop"): "Thời điểm sinh viên nộp báo cáo",
    ("BaoCaoTienDos", "TrangThai"): "Trạng thái nộp (Đã nộp, Chờ chấm, Đã chấm)",
    ("BaoCaoTienDos", "NhanXetGiangVien"): "Nhận xét, đánh giá của giảng viên hướng dẫn",
    ("BaoCaoTienDos", "Diem"): "Điểm đánh giá tiến độ (thang điểm 10.0)",
    ("BaoCaoTienDos", "GiangVienId"): "Mã giảng viên chấm (Logical FK tham chiếu GiangViens.GiangVienId)",
    ("BaoCaoTienDos", "NgayNhanXet"): "Thời điểm giảng viên chấm điểm & nhận xét",

    # Phu tro
    ("PasswordResetOtps", "OtpId"): "Khóa chính bản ghi OTP",
    ("PasswordResetOtps", "NguoiDungId"): "Khóa ngoại tham chiếu NguoiDungs.NguoiDungId",
    ("PasswordResetOtps", "OtpCodeHash"): "Mã OTP đã được mã hóa bảo mật",
    ("PasswordResetOtps", "ExpiredAt"): "Thời điểm hết hạn của OTP",
    ("PasswordResetOtps", "IsUsed"): "Cờ đánh dấu OTP đã được sử dụng hay chưa",
    ("PasswordResetOtps", "SoLanThu"): "Số lần đã nhập sai",
    ("PasswordResetOtps", "CreatedAt"): "Thời điểm phát sinh OTP",
    ("AIRequests", "AIRequestId"): "Khóa chính bản ghi yêu cầu AI",
    ("AIRequests", "NguoiDungId"): "Khóa ngoại tham chiếu NguoiDungs.NguoiDungId",
    ("AIRequests", "ChucNangAI"): "Tên tính năng AI sử dụng (Gợi ý đề tài, Phân tích nhóm, ...)",
    ("AIRequests", "Prompt"): "Câu lệnh/nội dung gửi lên AI",
    ("AIRequests", "Response"): "Nội dung phản hồi từ mô hình AI",
    ("AIRequests", "TrangThai"): "Trạng thái xử lý (Đang xử lý, Thành công, Thất bại)",
    ("AIRequests", "CreatedAt"): "Thời điểm gọi AI",
    ("DotImports", "DotImportId"): "Khóa chính đợt import",
    ("DotImports", "NguoiImportId"): "Khóa ngoại tham chiếu NguoiDungs.NguoiDungId người thực hiện",
    ("DotImports", "LoaiDuLieu"): "Loại thực thể import (SinhVien, GiangVien, LopHocPhan)",
    ("DotImports", "TenFile"): "Tên file tài liệu gốc tải lên",
    ("DotImports", "TongSoDong"): "Tổng số dòng dữ liệu trong file",
    ("DotImports", "SoDongThanhCong"): "Số dòng xử lý thành công",
    ("DotImports", "SoDongLoi"): "Số dòng dữ liệu lỗi bị bỏ qua",
    ("DotImports", "TrangThai"): "Trạng thái tiến trình import",
    ("DotImports", "CreatedAt"): "Thời điểm thực hiện",
    ("LoiImports", "LoiImportId"): "Khóa chính chi tiết lỗi",
    ("LoiImports", "DotImportId"): "Khóa ngoại tham chiếu DotImports.DotImportId",
    ("LoiImports", "SoDong"): "Số thứ tự dòng bị lỗi trong file",
    ("LoiImports", "TenCot"): "Tên cột dữ liệu không hợp lệ",
    ("LoiImports", "NoiDungLoi"): "Thông điệp chi tiết nguyên nhân lỗi",
    ("LoiImports", "CreatedAt"): "Thời điểm ghi nhận",
    ("ThongBaos", "ThongBaoId"): "Khóa chính thông báo",
    ("ThongBaos", "NguoiDungId"): "Khóa ngoại tham chiếu NguoiDungs.NguoiDungId người nhận",
    ("ThongBaos", "TieuDe"): "Tiêu đề thông báo",
    ("ThongBaos", "NoiDung"): "Nội dung chi tiết thông báo",
    ("ThongBaos", "LoaiThongBao"): "Phân loại thông báo (Hệ thống, Phân công, Duyệt đề tài, ...)",
    ("ThongBaos", "DaDoc"): "Cờ đánh dấu đã đọc (1: Đã đọc, 0: Chưa đọc)",
    ("ThongBaos", "LienKetId"): "ID thực thể liên kết (Polymorphic ID)",
    ("ThongBaos", "LoaiLienKet"): "Loại thực thể liên kết (LopHocPhan, DeTai, Nhom, ...)",
    ("ThongBaos", "CreatedAt"): "Thời điểm gửi thông báo",
}

print("Loaded module configurations and dictionary mappings.")

def generate_excel_dictionary(meta, checks):
    wb = openpyxl.Workbook()
    # Remove default sheet
    wb.remove(wb.active)

    # Styles
    font_title = Font(name="Segoe UI", size=16, bold=True, color="1E3A8A")
    font_subtitle = Font(name="Segoe UI", size=10, italic=True, color="4B5563")
    font_section = Font(name="Segoe UI", size=12, bold=True, color="1E3A8A")
    font_header = Font(name="Segoe UI", size=10, bold=True, color="FFFFFF")
    font_bold = Font(name="Segoe UI", size=9, bold=True, color="111827")
    font_regular = Font(name="Segoe UI", size=9, color="1F2937")
    font_code = Font(name="Consolas", size=9, color="111827")
    font_muted = Font(name="Segoe UI", size=8.5, color="6B7280")
    font_pk = Font(name="Segoe UI", size=9, bold=True, color="B45309")
    font_fk = Font(name="Segoe UI", size=9, bold=True, color="1D4ED8")

    fill_header_main = PatternFill(start_color="1E3A8A", end_color="1E3A8A", fill_type="solid")
    fill_header_sec = PatternFill(start_color="3B82F6", end_color="3B82F6", fill_type="solid")
    fill_zebra = PatternFill(start_color="F9FAFB", end_color="F9FAFB", fill_type="solid")
    fill_pk = PatternFill(start_color="FEF3C7", end_color="FEF3C7", fill_type="solid")
    fill_fk = PatternFill(start_color="DBEAFE", end_color="DBEAFE", fill_type="solid")

    thin_border_side = Side(border_style="thin", color="E5E7EB")
    border_cell = Border(left=thin_border_side, right=thin_border_side, top=thin_border_side, bottom=thin_border_side)
    thick_bottom = Side(border_style="medium", color="1E3A8A")
    border_header = Border(left=thin_border_side, right=thin_border_side, top=thin_border_side, bottom=thick_bottom)

    align_center = Alignment(horizontal="center", vertical="center")
    align_left = Alignment(horizontal="left", vertical="center")
    align_right = Alignment(horizontal="right", vertical="center")

    system_tables = {'__EFMigrationsHistory', 'sysdiagrams'}
    tables = [t for t in meta['Tables'] if t['TableName'] not in system_tables]

    # =========================================================================
    # SHEET 1: Danh Sách Bảng (Tables)
    # =========================================================================
    ws1 = wb.create_sheet(title="1. Tổng quan Bảng")
    ws1.views.sheetView[0].showGridLines = True

    # Title block
    ws1.merge_cells("A1:G1")
    ws1["A1"] = "HỆ THỐNG PROGROUP AI - TỪ ĐIỂN CƠ SỞ DỮ LIỆU (DATABASE DICTIONARY)"
    ws1["A1"].font = font_title
    ws1["A1"].alignment = align_left

    ws1.merge_cells("A2:G2")
    ws1["A2"] = f"Server: {meta['Server']} | Database: {meta['Database']} | Trích xuất: {meta['ExtractTime']} | Tổng số bảng: {len(tables)}"
    ws1["A2"].font = font_subtitle
    ws1["A2"].alignment = align_left

    headers1 = ["STT", "Nhóm Chức Năng", "Tên Bảng (Physical)", "Số Cột", "Số Dòng Thực Tế", "Khóa Chính (PK)", "Mô Tả Nghiệp Vụ"]
    ws1.row_dimensions[4].height = 26
    for col_idx, h in enumerate(headers1, 1):
        cell = ws1.cell(row=4, column=col_idx, value=h)
        cell.font = font_header
        cell.fill = fill_header_main
        cell.alignment = align_center
        cell.border = border_header

    current_row = 5
    for idx, t in enumerate(tables, 1):
        tname = t["TableName"]
        cols = [c for c in meta["Columns"] if c["TableName"] == tname]
        pks = [p["ColumnName"] for p in meta["PrimaryKeys"] if p["TableName"] == tname]
        mod_name = MODULE_MAP.get(tname, ("Khác", "", ""))[0]
        desc = TABLE_DESCRIPTIONS.get(tname, "")

        ws1.row_dimensions[current_row].height = 20
        row_data = [
            (idx, align_center, font_regular, None),
            (mod_name, align_left, font_bold, None),
            (tname, align_left, font_code, None),
            (len(cols), align_center, font_regular, None),
            (t["RowCount"], align_right, font_bold, None),
            (", ".join(pks), align_left, font_pk, fill_pk),
            (desc, align_left, font_regular, None)
        ]

        for col_idx, (val, aln, fnt, fill) in enumerate(row_data, 1):
            cell = ws1.cell(row=current_row, column=col_idx, value=val)
            cell.font = fnt
            cell.alignment = aln
            cell.border = border_cell
            if fill:
                cell.fill = fill
            elif current_row % 2 == 0:
                cell.fill = fill_zebra

        current_row += 1

    # Auto-fit columns
    for col in ws1.columns:
        max_len = max(len(str(cell.value or '')) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws1.column_dimensions[col_letter].width = max(max_len + 3, 10)
    ws1.column_dimensions["A"].width = 6
    ws1.column_dimensions["G"].width = 50

    # =========================================================================
    # SHEET 2: Từ Điển Cột (Columns Dictionary)
    # =========================================================================
    ws2 = wb.create_sheet(title="2. Từ điển Cột")
    ws2.views.sheetView[0].showGridLines = True

    ws2.merge_cells("A1:K1")
    ws2["A1"] = "CHI TIẾT CẤU TRÚC TẤT CẢ CÁC CỘT TRONG CƠ SỞ DỮ LIỆU"
    ws2["A1"].font = font_title
    ws2["A1"].alignment = align_left

    ws2.merge_cells("A2:K2")
    ws2["A2"] = "Toàn bộ thông tin: Kiểu dữ liệu, độ dài, khóa chính, khóa ngoại, nullability, giá trị mặc định, identity và mô tả nghiệp vụ"
    ws2["A2"].font = font_subtitle
    ws2["A2"].alignment = align_left

    headers2 = ["STT", "Nhóm Chức Năng", "Tên Bảng", "Tên Cột", "Thứ Tự", "Kiểu Dữ Liệu SQL", "Nullable", "Khóa (Key)", "Identity", "Giá Trị Mặc Định", "Mô Tả & Ý Nghĩa Nghiệp Vụ"]
    ws2.row_dimensions[4].height = 26
    for col_idx, h in enumerate(headers2, 1):
        cell = ws2.cell(row=4, column=col_idx, value=h)
        cell.font = font_header
        cell.fill = fill_header_main
        cell.alignment = align_center
        cell.border = border_header

    current_row = 5
    stt_col = 1
    for t in tables:
        tname = t["TableName"]
        cols = [c for c in meta["Columns"] if c["TableName"] == tname]
        pks = [p["ColumnName"] for p in meta["PrimaryKeys"] if p["TableName"] == tname]
        fks_out = [fk for fk in meta["ForeignKeys"] if fk["ParentTable"] == tname]
        mod_name = MODULE_MAP.get(tname, ("Khác", "", ""))[0]

        for c in cols:
            cname = c["ColumnName"]
            is_pk = cname in pks
            fk_matches = [fk for fk in fks_out if fk["ParentColumn"] == cname]
            is_fk = len(fk_matches) > 0
            
            key_str = ""
            key_font = font_regular
            key_fill = None
            if is_pk and is_fk:
                key_str = f"PK, FK -> {fk_matches[0]['ReferencedTable']}"
                key_font = font_bold
                key_fill = fill_pk
            elif is_pk:
                key_str = "PK (Primary Key)"
                key_font = font_pk
                key_fill = fill_pk
            elif is_fk:
                key_str = f"FK -> {fk_matches[0]['ReferencedTable']}.{fk_matches[0]['ReferencedColumn']}"
                key_font = font_fk
                key_fill = fill_fk

            # Format data type
            type_str = c["DataType"]
            if c["MaxLength"]:
                type_str += f"({c['MaxLength'] if c['MaxLength'] != -1 else 'max'})"
            elif c["Precision"] and c["Scale"]:
                type_str += f"({c['Precision']},{c['Scale']})"
            elif c["Precision"]:
                type_str += f"({c['Precision']})"

            desc = COLUMN_DESCRIPTIONS.get((tname, cname), "")

            ws2.row_dimensions[current_row].height = 19
            row_data = [
                (stt_col, align_center, font_regular, None),
                (mod_name, align_left, font_muted, None),
                (tname, align_left, font_bold, None),
                (cname, align_left, font_code, None),
                (c["OrdinalPosition"], align_center, font_regular, None),
                (type_str, align_left, font_code, None),
                ("NULL" if c["IsNullable"] else "NOT NULL", align_center, font_bold if not c["IsNullable"] else font_muted, None),
                (key_str, align_left, key_font, key_fill),
                ("YES" if c["IsIdentity"] else "-", align_center, font_bold if c["IsIdentity"] else font_muted, None),
                (c["ColumnDefault"] or "-", align_left, font_code if c["ColumnDefault"] else font_muted, None),
                (desc, align_left, font_regular, None),
            ]

            for col_idx, (val, aln, fnt, fill) in enumerate(row_data, 1):
                cell = ws2.cell(row=current_row, column=col_idx, value=val)
                cell.font = fnt
                cell.alignment = aln
                cell.border = border_cell
                if fill:
                    cell.fill = fill
                elif current_row % 2 == 0:
                    cell.fill = fill_zebra

            current_row += 1
            stt_col += 1

    for col in ws2.columns:
        max_len = max(len(str(cell.value or '')) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws2.column_dimensions[col_letter].width = max(max_len + 3, 10)
    ws2.column_dimensions["A"].width = 6
    ws2.column_dimensions["K"].width = 50

    # =========================================================================
    # SHEET 3: Khóa Ngoại & Quan Hệ (Foreign Keys)
    # =========================================================================
    ws3 = wb.create_sheet(title="3. Khóa Ngoại & Quan Hệ")
    ws3.views.sheetView[0].showGridLines = True

    ws3.merge_cells("A1:J1")
    ws3["A1"] = "DANH SÁCH KHÓA NGOẠI VÀ QUAN HỆ VẬT LÝ TRONG SQL SERVER"
    ws3["A1"].font = font_title
    ws3["A1"].alignment = align_left

    ws3.merge_cells("A2:J2")
    ws3["A2"] = "Tổng cộng 30 Foreign Keys vật lý được kiểm soát và thực thi bởi SQL Server Engine"
    ws3["A2"].font = font_subtitle
    ws3["A2"].alignment = align_left

    headers3 = ["STT", "Tên Ràng Buộc (FK Name)", "Bảng Nguồn (Parent)", "Cột Khóa Ngoại", "Bảng Đích (Referenced)", "Cột Khóa Chính Đích", "Bản Số (Cardinality)", "ON DELETE", "ON UPDATE", "Ý Nghĩa Quan Hệ Nghiệp Vụ"]
    ws3.row_dimensions[4].height = 26
    for col_idx, h in enumerate(headers3, 1):
        cell = ws3.cell(row=4, column=col_idx, value=h)
        cell.font = font_header
        cell.fill = fill_header_main
        cell.alignment = align_center
        cell.border = border_header

    current_row = 5
    for idx, fk in enumerate(meta["ForeignKeys"], 1):
        if fk["ParentTable"] in system_tables or fk["ReferencedTable"] in system_tables:
            continue

        # Determine cardinality
        # Check if parent column has a unique constraint or is PK (making it 1:1)
        parent_table = fk["ParentTable"]
        parent_col = fk["ParentColumn"]
        pks = [p["ColumnName"] for p in meta["PrimaryKeys"] if p["TableName"] == parent_table]
        uqs = [i for i in meta["Indexes"] if i["TableName"] == parent_table and i["IsUnique"] and i["ColumnName"] == parent_col]
        
        cardinality = "Many-to-One (N:1)"
        if parent_col in pks and len(pks) == 1:
            cardinality = "One-to-One (1:1)"
        elif len(uqs) > 0 and (parent_table in ["SinhViens", "GiangViens"] and parent_col == "NguoiDungId"):
            cardinality = "One-to-One (1:1, Unique FK)"

        # Meaning
        meaning = f"Mỗi bản ghi {parent_table} liên kết trực tiếp với một {fk['ReferencedTable']}"
        if parent_table == "NguoiDungs" and parent_col == "VaiTroId":
            meaning = "Mỗi người dùng thuộc về 1 vai trò xác định"
        elif parent_table == "SinhViens" and parent_col == "NguoiDungId":
            meaning = "Quan hệ 1:1 độc quyền giữa tài khoản và hồ sơ sinh viên"
        elif parent_table == "GiangViens" and parent_col == "NguoiDungId":
            meaning = "Quan hệ 1:1 độc quyền giữa tài khoản và hồ sơ giảng viên"
        elif parent_table == "PhanCongGiangViens":
            meaning = "Bảng trung gian giải quyết quan hệ N:N giữa Lớp học phần và Giảng viên"
        elif parent_table == "SinhVienLopHocPhans":
            meaning = "Bảng trung gian giải quyết quan hệ N:N giữa Sinh viên và Lớp học phần"
        elif parent_table == "ThanhVienNhoms":
            meaning = "Bảng trung gian giải quyết quan hệ N:N giữa Nhóm đồ án và Sinh viên"
        elif parent_table == "DangKyDeTais":
            meaning = "Bảng đăng ký nguyện vọng đề tài của nhóm đồ án (N:N giữa Nhóm và Đề tài)"

        ws3.row_dimensions[current_row].height = 20
        row_data = [
            (idx, align_center, font_regular, None),
            (fk["ForeignKeyName"], align_left, font_code, None),
            (fk["ParentTable"], align_left, font_bold, None),
            (fk["ParentColumn"], align_left, font_code, fill_fk),
            (fk["ReferencedTable"], align_left, font_bold, None),
            (fk["ReferencedColumn"], align_left, font_code, fill_pk),
            (cardinality, align_center, font_bold if "1:1" in cardinality else font_regular, None),
            (fk["DeleteRule"], align_center, font_code, None),
            (fk["UpdateRule"], align_center, font_code, None),
            (meaning, align_left, font_regular, None),
        ]

        for col_idx, (val, aln, fnt, fill) in enumerate(row_data, 1):
            cell = ws3.cell(row=current_row, column=col_idx, value=val)
            cell.font = fnt
            cell.alignment = aln
            cell.border = border_cell
            if fill:
                cell.fill = fill
            elif current_row % 2 == 0:
                cell.fill = fill_zebra

        current_row += 1

    for col in ws3.columns:
        max_len = max(len(str(cell.value or '')) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws3.column_dimensions[col_letter].width = max(max_len + 3, 10)
    ws3.column_dimensions["A"].width = 6
    ws3.column_dimensions["J"].width = 45

    # =========================================================================
    # SHEET 4: Ràng buộc & Index (Constraints & Indexes)
    # =========================================================================
    ws4 = wb.create_sheet(title="4. Ràng buộc & Index")
    ws4.views.sheetView[0].showGridLines = True

    ws4.merge_cells("A1:G1")
    ws4["A1"] = "DANH SÁCH CHECK CONSTRAINTS, UNIQUE INDEXES VÀ NON-CLUSTERED INDEXES"
    ws4["A1"].font = font_title
    ws4["A1"].alignment = align_left

    ws4.merge_cells("A2:G2")
    ws4["A2"] = "Các ràng buộc toàn vẹn miền giá trị (Domain Integrity) và tối ưu truy vấn trong SQL Server"
    ws4["A2"].font = font_subtitle
    ws4["A2"].alignment = align_left

    # Part A: Check Constraints
    ws4.cell(row=4, column=1, value="A. DANH SÁCH CHECK CONSTRAINTS (22 RÀNG BUỘC)").font = font_section
    headers4_a = ["STT", "Bảng Áp Dụng", "Tên Ràng Buộc (Constraint Name)", "Biểu Thức Kiểm Tra SQL (Definition)", "Mục Đích Bảo Vệ Dữ Liệu"]
    ws4.row_dimensions[5].height = 24
    for col_idx, h in enumerate(headers4_a, 1):
        cell = ws4.cell(row=5, column=col_idx, value=h)
        cell.font = font_header
        cell.fill = PatternFill(start_color="047857", end_color="047857", fill_type="solid")
        cell.alignment = align_center
        cell.border = border_header

    current_row = 6
    check_purposes = {
        "CK_AIRequests_TrangThai": "Giới hạn trạng thái xử lý AI trong tập ('Đang xử lý', 'Thành công', 'Thất bại')",
        "CK_BaoCaoTienDos_Diem": "Khống chế điểm số báo cáo tiến độ nằm trong khoảng [0.0, 10.0]",
        "CK_DangKyDeTais_NgayDuyet": "Đảm bảo tính nhất quán giữa trạng thái duyệt và ngày phê duyệt",
        "CK_DangKyDeTais_TrangThai": "Giới hạn trạng thái đăng ký đề tài ('Chờ duyệt', 'Đã duyệt', 'Từ chối', 'Đã hủy')",
        "CK_DeTaiDoAns_Nguon": "Giới hạn nguồn đề tài ('Giảng viên', 'Sinh viên đề xuất')",
        "CK_DeTaiDoAns_TrangThai": "Giới hạn trạng thái đề tài ('Chưa sử dụng', 'Đang hoạt động', 'Tạm khóa', ...)",
        "CK_DeTaiDoAns_TrangThaiDuyet": "Giới hạn trạng thái phê duyệt đề tài ('Chờ duyệt', 'Đã duyệt', 'Từ chối')",
        "CK_DotDangKyDoAns_Ngay": "Bắt buộc ngày kết thúc đợt đăng ký phải lớn hơn ngày bắt đầu",
        "CK_DotDangKyDoAns_ThanhVien": "Đảm bảo số thành viên Min > 0 và Max >= Min",
        "CK_DotDangKyDoAns_TrangThai": "Giới hạn trạng thái đợt đăng ký ('Chưa mở', 'Đang mở', 'Đã đóng')",
        "CK_DotImports_SoDong": "Toàn vẹn số lượng dòng import (Thành công + Lỗi <= Tổng số dòng)",
        "CK_DotImports_TrangThai": "Giới hạn trạng thái đợt import ('Đang xử lý', 'Hoàn thành', ...)",
        "CK_HocKys_Ngay": "Bắt buộc ngày kết thúc học kỳ phải lớn hơn ngày bắt đầu",
        "CK_HocPhans_SoTinChi": "Bắt buộc số tín chỉ học phần phải lớn hơn 0",
        "CK_LoiImports_SoDong": "Số thứ tự dòng lỗi trong file phải lớn hơn 0",
        "CK_LopHocPhans_SoLuong": "Số lượng sinh viên tối đa của lớp học phần phải lớn hơn 0",
        "CK_NguoiDungs_SoDienThoai": "Ràng buộc số điện thoại từ 9-11 chữ số và không chứa ký tự lạ",
        "CK_NhomDoAns_TrangThai": "Giới hạn trạng thái nhóm ('Đang hoạt động', 'Đã khóa', 'Đã hủy')",
        "CK_PasswordResetOtps_ExpiredAt": "Thời điểm hết hạn OTP phải lớn hơn thời điểm tạo",
        "CK_PasswordResetOtps_SoLanThu": "Số lần thử OTP không được âm (>= 0)",
        "CK_ThanhVienNhoms_TrangThai": "Giới hạn trạng thái thành viên ('Chờ tham gia', 'Đã tham gia', 'Đã rời nhóm')",
        "CK_ThanhVienNhoms_VaiTro": "Giới hạn vai trò trong nhóm ('Trưởng nhóm', 'Thành viên')",
    }

    for idx, c in enumerate(checks, 1):
        ws4.row_dimensions[current_row].height = 20
        purpose = check_purposes.get(c["ConstraintName"], "Ràng buộc kiểm tra tính hợp lệ dữ liệu")
        row_data = [
            (idx, align_center, font_regular, None),
            (c["TableName"], align_left, font_bold, None),
            (c["ConstraintName"], align_left, font_code, None),
            (c["Definition"], align_left, font_code, fill_zebra),
            (purpose, align_left, font_regular, None),
        ]
        for col_idx, (val, aln, fnt, fill) in enumerate(row_data, 1):
            cell = ws4.cell(row=current_row, column=col_idx, value=val)
            cell.font = fnt
            cell.alignment = aln
            cell.border = border_cell
            if fill:
                cell.fill = fill
            elif current_row % 2 == 0:
                cell.fill = fill_zebra
        current_row += 1

    # Part B: Indexes
    current_row += 2
    ws4.cell(row=current_row, column=1, value="B. DANH SÁCH INDEXES VÀ UNIQUE CONSTRAINTS").font = font_section
    current_row += 1

    headers4_b = ["STT", "Bảng Áp Dụng", "Tên Index", "Loại Index", "Tính Duy Nhất (Unique)", "Cột Đánh Index", "Mục Đích"]
    ws4.row_dimensions[current_row].height = 24
    for col_idx, h in enumerate(headers4_b, 1):
        cell = ws4.cell(row=current_row, column=col_idx, value=h)
        cell.font = font_header
        cell.fill = fill_header_main
        cell.alignment = align_center
        cell.border = border_header
    current_row += 1

    idx_stt = 1
    # Group indexes
    idx_map = {}
    for i in meta["Indexes"]:
        if i["TableName"] in system_tables:
            continue
        key = (i["TableName"], i["IndexName"])
        if key not in idx_map:
            idx_map[key] = {
                "TableName": i["TableName"],
                "IndexName": i["IndexName"],
                "IndexType": i["IndexType"],
                "IsUnique": i["IsUnique"],
                "IsPrimaryKey": i["IsPrimaryKey"],
                "Columns": []
            }
        idx_map[key]["Columns"].append(i["ColumnName"])

    for (tname, iname), idata in idx_map.items():
        ws4.row_dimensions[current_row].height = 19
        cols_str = ", ".join(idata["Columns"])
        uq_str = "UNIQUE" if idata["IsUnique"] else "NON-UNIQUE"
        purpose = "Khóa chính Clustered Index" if idata["IsPrimaryKey"] else ("Đảm bảo không trùng lặp (Unique Key)" if idata["IsUnique"] else "Tối ưu tốc độ tìm kiếm và liên kết Foreign Key")

        row_data = [
            (idx_stt, align_center, font_regular, None),
            (tname, align_left, font_bold, None),
            (iname, align_left, font_code, None),
            (idata["IndexType"], align_center, font_regular, None),
            (uq_str, align_center, font_bold if idata["IsUnique"] else font_muted, fill_pk if idata["IsUnique"] else None),
            (cols_str, align_left, font_code, None),
            (purpose, align_left, font_regular, None),
        ]
        for col_idx, (val, aln, fnt, fill) in enumerate(row_data, 1):
            cell = ws4.cell(row=current_row, column=col_idx, value=val)
            cell.font = fnt
            cell.alignment = aln
            cell.border = border_cell
            if fill:
                cell.fill = fill
            elif current_row % 2 == 0:
                cell.fill = fill_zebra
        current_row += 1
        idx_stt += 1

    for col in ws4.columns:
        max_len = max(len(str(cell.value or '')) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws4.column_dimensions[col_letter].width = max(max_len + 3, 10)
    ws4.column_dimensions["A"].width = 6
    ws4.column_dimensions["D"].width = 45
    ws4.column_dimensions["G"].width = 40

    excel_path = os.path.join(OUTPUT_DIR, "ProGroupAI_Database_Dictionary.xlsx")
    wb.save(excel_path)
    print(f"Successfully generated Excel Database Dictionary: {excel_path}")

print("Defined generate_excel_dictionary function.")
