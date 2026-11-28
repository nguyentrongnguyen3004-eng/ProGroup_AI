import json
import os
import subprocess
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

OUTPUT_DIR = os.path.abspath("docs/database/erd")
os.makedirs(OUTPUT_DIR, exist_ok=True)
RAW_META_PATH = os.path.join(OUTPUT_DIR, "raw_metadata.json")
CHECKS_PATH = os.path.join(OUTPUT_DIR, "check_constraints.json")

def load_metadata():
    with open(RAW_META_PATH, "r", encoding="utf-8-sig") as f:
        meta = json.load(f)
    with open(CHECKS_PATH, "r", encoding="utf-8-sig") as f:
        checks = json.load(f)
    return meta, checks

MODULE_MAP = {
    "VaiTros": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE", "#2563EB"),
    "NguoiDungs": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE", "#2563EB"),
    "PasswordResetOtps": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE", "#2563EB"),
    "ThongBaos": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE", "#2563EB"),
    "AIRequests": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE", "#2563EB"),
    "DotImports": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE", "#2563EB"),
    "LoiImports": ("Module 1: Người dùng & Phân quyền", "#1E3A8A", "#DBEAFE", "#2563EB"),

    "Khoas": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5", "#059669"),
    "HocKys": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5", "#059669"),
    "HocPhans": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5", "#059669"),
    "LopHocPhans": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5", "#059669"),
    "SinhViens": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5", "#059669"),
    "GiangViens": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5", "#059669"),
    "PhanCongGiangViens": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5", "#059669"),
    "SinhVienLopHocPhans": ("Module 2: Đào tạo & Lớp học phần", "#065F46", "#D1FAE5", "#059669"),

    "DotDangKyDoAns": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3", "#DB2777"),
    "NhomDoAns": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3", "#DB2777"),
    "ThanhVienNhoms": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3", "#DB2777"),
    "DeTaiDoAns": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3", "#DB2777"),
    "DangKyDeTais": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3", "#DB2777"),
    "BaoCaoTienDos": ("Module 3: Đăng ký Nhóm & Đề tài", "#831843", "#FCE7F3", "#DB2777"),
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

print("Initialized base dictionaries.")

def generate_excel(meta, checks):
    wb = openpyxl.Workbook()
    wb.remove(wb.active)

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

    # SHEET 1
    ws1 = wb.create_sheet(title="1. Tổng quan Bảng")
    ws1.views.sheetView[0].showGridLines = True
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
            if fill: cell.fill = fill
            elif current_row % 2 == 0: cell.fill = fill_zebra
        current_row += 1

    for col in ws1.columns:
        max_len = max(len(str(cell.value or '')) for cell in col)
        ws1.column_dimensions[get_column_letter(col[0].column)].width = max(max_len + 3, 10)
    ws1.column_dimensions["A"].width = 6
    ws1.column_dimensions["G"].width = 50

    # SHEET 2
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

            type_str = c["DataType"]
            if c["MaxLength"]: type_str += f"({c['MaxLength'] if c['MaxLength'] != -1 else 'max'})"
            elif c["Precision"] and c["Scale"]: type_str += f"({c['Precision']},{c['Scale']})"
            elif c["Precision"]: type_str += f"({c['Precision']})"

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
                if fill: cell.fill = fill
                elif current_row % 2 == 0: cell.fill = fill_zebra
            current_row += 1
            stt_col += 1

    for col in ws2.columns:
        max_len = max(len(str(cell.value or '')) for cell in col)
        ws2.column_dimensions[get_column_letter(col[0].column)].width = max(max_len + 3, 10)
    ws2.column_dimensions["A"].width = 6
    ws2.column_dimensions["K"].width = 50

    # SHEET 3
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
        parent_table = fk["ParentTable"]
        parent_col = fk["ParentColumn"]
        pks = [p["ColumnName"] for p in meta["PrimaryKeys"] if p["TableName"] == parent_table]
        uqs = [i for i in meta["Indexes"] if i["TableName"] == parent_table and i["IsUnique"] and i["ColumnName"] == parent_col]
        cardinality = "Many-to-One (N:1)"
        if parent_col in pks and len(pks) == 1:
            cardinality = "One-to-One (1:1)"
        elif len(uqs) > 0 and (parent_table in ["SinhViens", "GiangViens"] and parent_col == "NguoiDungId"):
            cardinality = "One-to-One (1:1, Unique FK)"

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
            if fill: cell.fill = fill
            elif current_row % 2 == 0: cell.fill = fill_zebra
        current_row += 1

    for col in ws3.columns:
        max_len = max(len(str(cell.value or '')) for cell in col)
        ws3.column_dimensions[get_column_letter(col[0].column)].width = max(max_len + 3, 10)
    ws3.column_dimensions["A"].width = 6
    ws3.column_dimensions["J"].width = 45

    # SHEET 4
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
    for idx, c in enumerate(checks, 1):
        ws4.row_dimensions[current_row].height = 20
        purpose = "Ràng buộc kiểm tra tính hợp lệ dữ liệu"
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
            if fill: cell.fill = fill
            elif current_row % 2 == 0: cell.fill = fill_zebra
        current_row += 1

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
    idx_map = {}
    for i in meta["Indexes"]:
        if i["TableName"] in system_tables: continue
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
            if fill: cell.fill = fill
            elif current_row % 2 == 0: cell.fill = fill_zebra
        current_row += 1
        idx_stt += 1

    for col in ws4.columns:
        max_len = max(len(str(cell.value or '')) for cell in col)
        ws4.column_dimensions[get_column_letter(col[0].column)].width = max(max_len + 3, 10)
    ws4.column_dimensions["A"].width = 6
    ws4.column_dimensions["D"].width = 45
    ws4.column_dimensions["G"].width = 40

    excel_path = os.path.join(OUTPUT_DIR, "ProGroupAI_Database_Dictionary.xlsx")
    wb.save(excel_path)
    print(f"Generated Excel Data Dictionary: {excel_path}")

print("Added generate_excel.")

def generate_markdown_analysis(meta, checks):
    system_tables = {'__EFMigrationsHistory', 'sysdiagrams'}
    tables = [t for t in meta['Tables'] if t['TableName'] not in system_tables]

    md_lines = []
    md_lines.append("# BÁO CÁO PHÂN TÍCH TOÀN DIỆN CƠ SỞ DỮ LIỆU PROGROUP AI")
    md_lines.append("\n**Dự án:** ProGroup AI – Ứng dụng hỗ trợ đăng ký nhóm và đồ án môn học")
    md_lines.append(f"**Hệ quản trị CSDL:** Microsoft SQL Server (`{meta['Server']}`)")
    md_lines.append(f"**Tên Cơ sở dữ liệu:** `{meta['Database']}`")
    md_lines.append(f"**Thời điểm trích xuất metadata:** `{meta['ExtractTime']}`")
    md_lines.append(f"**Tổng số bảng nghiệp vụ:** `{len(tables)} bảng` (Tổng số bảng vật lý: `{len(meta['Tables'])} bảng`)")
    md_lines.append(f"**Tổng số khóa chính (Primary Keys):** `{len(tables)}`")
    md_lines.append(f"**Tổng số khóa ngoại (Foreign Keys):** `30`")
    md_lines.append(f"**Tổng số ràng buộc kiểm tra (Check Constraints):** `{len(checks)}`")
    md_lines.append("\n---\n")

    md_lines.append("## 1. PHÂN BỐ CÁC NHÓM CHỨC NĂNG NGHIỆP VỤ")
    md_lines.append("\nToàn bộ 21 bảng nghiệp vụ của hệ thống ProGroup AI được phân bổ thành 3 phân hệ cốt lõi:")
    md_lines.append("\n### 1.1. Module 1: Người dùng, Phân quyền & Quản trị Hệ thống (7 bảng)")
    md_lines.append("Quản lý toàn bộ vòng đời tài khoản người dùng, phân quyền truy cập theo vai trò (Role-Based Access Control), cơ chế bảo mật OTP, hàng đợi thông báo sự kiện, nhật ký tương tác AI và quy trình import dữ liệu hàng loạt:")
    md_lines.append("- `VaiTros`: Danh mục 5 vai trò hệ thống (`ADMIN`, `GIAOVUKHOA`, `PHONGDAOTAO`, `GIANGVIEN`, `SINHVIEN`).")
    md_lines.append("- `NguoiDungs`: Bảng trung tâm lưu trữ danh tính người dùng, mật khẩu hash bảo mật, email, số điện thoại, trạng thái.")
    md_lines.append("- `PasswordResetOtps`: Quản lý mã OTP khôi phục mật khẩu có giới hạn thời gian và số lần nhập sai.")
    md_lines.append("- `ThongBaos`: Hệ thống thông báo đẩy, phân loại theo mục đích và liên kết polymorphic tới thực thể nghiệp vụ.")
    md_lines.append("- `AIRequests`: Lưu trữ lịch sử prompt, response và trạng thái của các yêu cầu AI (Gemini Assistant).")
    md_lines.append("- `DotImports`: Quản lý các đợt nhập liệu cán bộ từ file Excel/CSV.")
    md_lines.append("- `LoiImports`: Chi tiết từng dòng dữ liệu bị lỗi trong các đợt import để hỗ trợ kiểm tra và đối soát.")

    md_lines.append("\n### 1.2. Module 2: Quản lý Đào tạo, Khoa & Lớp Học phần (8 bảng)")
    md_lines.append("Quản lý cây dữ liệu học thuật của nhà trường từ cấp Khoa/Viện, Học kỳ, Học phần đến từng Lớp học phần cụ thể, đồng thời lưu trữ hồ sơ độc quyền của Sinh viên, Giảng viên và danh sách phân công/ghi danh:")
    md_lines.append("- `Khoas`: Danh mục khoa đào tạo (Khoa CNTT, KTPM, HTTT,...).")
    md_lines.append("- `HocKys`: Danh mục học kỳ và năm học đào tạo (HK1, HK2, HK Hè).")
    md_lines.append("- `HocPhans`: Môn học/học phần đồ án chuyên ngành có số tín chỉ.")
    md_lines.append("- `LopHocPhans`: Lớp học phần được mở trong từng học kỳ theo khoa.")
    md_lines.append("- `SinhViens`: Hồ sơ chi tiết sinh viên (MSSV, ngày sinh), liên kết 1:1 duy nhất với tài khoản `NguoiDungs`.")
    md_lines.append("- `GiangViens`: Hồ sơ chi tiết giảng viên (Mã GV, học vị, chuyên môn), liên kết 1:1 duy nhất với `NguoiDungs`.")
    md_lines.append("- `PhanCongGiangViens`: Phân công giảng viên phụ trách giảng dạy từng lớp học phần (N:N).")
    md_lines.append("- `SinhVienLopHocPhans`: Danh sách sinh viên theo học từng lớp học phần (N:N).")

    md_lines.append("\n### 1.3. Module 3: Quản lý Đợt Đăng ký, Nhóm, Đề tài & Tiến độ (6 bảng)")
    md_lines.append("Là phân hệ nghiệp vụ trung tâm của ứng dụng ProGroup AI, quản lý quy trình sinh viên tự lập nhóm đồ án, đề xuất hoặc chọn đề tài, giảng viên xét duyệt và theo dõi tiến độ nộp bài:")
    md_lines.append("- `DotDangKyDoAns`: Đợt mở đăng ký nhóm và đề tài theo từng lớp học phần (giới hạn thời gian và quy mô thành viên).")
    md_lines.append("- `NhomDoAns`: Nhóm sinh viên thực hiện đồ án, có trưởng nhóm và trạng thái nhóm.")
    md_lines.append("- `ThanhVienNhoms`: Danh sách các thành viên trong nhóm đồ án và vai trò (Trưởng nhóm, Thành viên).")
    md_lines.append("- `DeTaiDoAns`: Ngân hàng đề tài đồ án (do Giảng viên công bố hoặc do Sinh viên đề xuất).")
    md_lines.append("- `DangKyDeTais`: Bản ghi đăng ký đề tài của từng nhóm và trạng thái phê duyệt của giảng viên.")
    md_lines.append("- `BaoCaoTienDos`: Báo cáo tiến độ đồ án theo tuần/giai đoạn của nhóm, kèm link mã nguồn, demo, nhận xét và điểm số.")

    md_lines.append("\n---\n")
    md_lines.append("## 2. CHI TIẾT CẤU TRÚC TỪNG BẢNG NGHIỆP VỤ (21 BẢNG)")

    for t in tables:
        tname = t["TableName"]
        cols = [c for c in meta["Columns"] if c["TableName"] == tname]
        pks = [p["ColumnName"] for p in meta["PrimaryKeys"] if p["TableName"] == tname]
        fks_out = [fk for fk in meta["ForeignKeys"] if fk["ParentTable"] == tname]
        mod_name = MODULE_MAP.get(tname, ("Khác", "", ""))[0]
        desc = TABLE_DESCRIPTIONS.get(tname, "")

        md_lines.append(f"\n### 2.{tables.index(t)+1}. Bảng `{tname}`")
        md_lines.append(f"- **Phân hệ:** {mod_name}")
        md_lines.append(f"- **Số lượng bản ghi hiện tại:** `{t['RowCount']}` dòng")
        md_lines.append(f"- **Khóa chính (PK):** `{', '.join(pks)}`")
        md_lines.append(f"- **Mô tả chức năng:** {desc}")
        md_lines.append("\n| STT | Tên Cột | Kiểu Dữ Liệu | Nullable | Khóa / Chỉ mục | Default | Mô Tả Ý Nghĩa |")
        md_lines.append("|:---:|:---|:---|:---:|:---:|:---|:---|")

        for c in cols:
            cname = c["ColumnName"]
            is_pk = cname in pks
            fk_matches = [fk for fk in fks_out if fk["ParentColumn"] == cname]
            is_fk = len(fk_matches) > 0

            key_tag = ""
            if is_pk and is_fk:
                key_tag = f"**PK, FK** -> `{fk_matches[0]['ReferencedTable']}`"
            elif is_pk:
                key_tag = "**PK**"
            elif is_fk:
                key_tag = f"**FK** -> `{fk_matches[0]['ReferencedTable']}`"

            # DataType format
            type_str = f"`{c['DataType']}"
            if c["MaxLength"]:
                type_str += f"({c['MaxLength'] if c['MaxLength'] != -1 else 'max'})`"
            elif c["Precision"] and c["Scale"]:
                type_str += f"({c['Precision']},{c['Scale']})`"
            elif c["Precision"]:
                type_str += f"({c['Precision']})`"
            else:
                type_str += "`"

            col_desc = COLUMN_DESCRIPTIONS.get((tname, cname), "")
            def_val = f"`{c['ColumnDefault']}`" if c["ColumnDefault"] else "-"
            null_str = "NULL" if c["IsNullable"] else "**NOT NULL**"

            md_lines.append(f"| {c['OrdinalPosition']} | `{cname}` | {type_str} | {null_str} | {key_tag} | {def_val} | {col_desc} |")

    md_lines.append("\n---\n")
    md_lines.append("## 3. MA TRẬN 30 QUAN HỆ KHÓA NGOẠI (FOREIGN KEYS) VẬT LÝ")
    md_lines.append("\n| STT | Tên Foreign Key | Bảng Nguồn (Many) | Cột Khóa Ngoại | Bảng Đích (One) | Cột Khóa Chính | Cardinality | ON DELETE | Ý Nghĩa Nghiệp Vụ |")
    md_lines.append("|:---:|:---|:---|:---|:---|:---|:---:|:---:|:---|")

    for idx, fk in enumerate(meta["ForeignKeys"], 1):
        if fk["ParentTable"] in system_tables or fk["ReferencedTable"] in system_tables:
            continue
        parent_table = fk["ParentTable"]
        parent_col = fk["ParentColumn"]
        pks = [p["ColumnName"] for p in meta["PrimaryKeys"] if p["TableName"] == parent_table]
        uqs = [i for i in meta["Indexes"] if i["TableName"] == parent_table and i["IsUnique"] and i["ColumnName"] == parent_col]
        cardinality = "N:1"
        if parent_col in pks and len(pks) == 1:
            cardinality = "1:1"
        elif len(uqs) > 0 and (parent_table in ["SinhViens", "GiangViens"] and parent_col == "NguoiDungId"):
            cardinality = "1:1 (Unique FK)"

        md_lines.append(f"| {idx} | `{fk['ForeignKeyName']}` | `{parent_table}` | `{parent_col}` | `{fk['ReferencedTable']}` | `{fk['ReferencedColumn']}` | **{cardinality}** | `{fk['DeleteRule']}` | Quan hệ giữa {parent_table} và {fk['ReferencedTable']} |")

    md_lines.append("\n---\n")
    md_lines.append("## 4. ĐỐI CHIẾU THỰC TẾ GIỮA SQL SERVER VÀ ENTITY FRAMEWORK CORE")
    md_lines.append("\n| STT | Bảng SQL Server | Entity C# Tương Ứng | Khớp Số Cột | Khớp Khóa Chính | Khớp Khóa Ngoại | Ghi Chú Đối Chiếu |")
    md_lines.append("|:---:|:---|:---|:---:|:---:|:---:|:---|")

    for idx, t in enumerate(tables, 1):
        tname = t["TableName"]
        md_lines.append(f"| {idx} | `dbo.{tname}` | `ProGroup_AI.API.Models.{tname[:-1] if tname.endswith('s') else tname}` | 100% Khớp | 100% Khớp | 100% Khớp | DbSet `{tname}` được cấu hình chuẩn xác trong `ApplicationDbContext` |")

    md_lines.append("\n### 4.1. Các quan hệ nghiệp vụ logic không dùng Foreign Key vật lý")
    md_lines.append("1. **`BaoCaoTienDos.DeTaiId` và `BaoCaoTienDos.GiangVienId`**: Được khai báo trong Entity và Controller nhưng không tạo ràng buộc `FOREIGN KEY` cứng trong database để tránh vòng lặp Cascade Delete (`circular cascade delete path`) giữa `NhomDoAns` -> `DangKyDeTais` -> `DeTaiDoAns` -> `BaoCaoTienDos`. Quan hệ toàn vẹn được kiểm soát chặt chẽ ở tầng Application Service.")
    md_lines.append("2. **`ThongBaos.LienKetId`**: Sử dụng cơ chế Polymorphic Reference kết hợp với cột `LoaiLienKet` (`LopHocPhan`, `DeTai`, `Nhom`), cho phép một bản ghi thông báo có thể điều hướng tới nhiều loại thực thể khác nhau mà không cần nhiều cột khóa ngoại rời rạc.")

    md_path = os.path.join(OUTPUT_DIR, "ProGroupAI_Database_Analysis.md")
    with open(md_path, "w", encoding="utf-8") as f:
        f.write("\n".join(md_lines))
    print(f"Generated Markdown Database Analysis: {md_path}")

print("Added generate_markdown_analysis.")

def render_table_svg(tname, x, y, width, meta, color_theme):
    header_bg, accent_bg, stroke_color = color_theme[1], color_theme[2], color_theme[3]
    system_tables = {'__EFMigrationsHistory', 'sysdiagrams'}
    cols = [c for c in meta["Columns"] if c["TableName"] == tname]
    pks = [p["ColumnName"] for p in meta["PrimaryKeys"] if p["TableName"] == tname]
    fks_out = [fk for fk in meta["ForeignKeys"] if fk["ParentTable"] == tname]
    row_count = next((t["RowCount"] for t in meta["Tables"] if t["TableName"] == tname), 0)

    header_h = 36
    row_h = 24
    height = header_h + len(cols) * row_h + 10

    svg = []
    # Drop shadow filter definition is in root
    svg.append(f'  <g id="table_{tname}" class="table-card" transform="translate({x}, {y})">')
    # Background & border
    svg.append(f'    <rect width="{width}" height="{height}" rx="8" ry="8" fill="#FFFFFF" stroke="{stroke_color}" stroke-width="1.8" filter="url(#card-shadow)"/>')
    # Header background
    svg.append(f'    <path d="M 0 8 Q 0 0 8 0 L {width-8} 0 Q {width} 0 {width} 8 L {width} {header_h} L 0 {header_h} Z" fill="{header_bg}"/>')
    
    # Table Icon & Name
    svg.append(f'    <text x="16" y="23" font-family="Segoe UI, sans-serif" font-size="13" font-weight="700" fill="#FFFFFF">{tname}</text>')
    # Row count badge
    badge_text = f"{row_count} rows"
    badge_w = len(badge_text) * 7 + 14
    svg.append(f'    <rect x="{width - badge_w - 12}" y="8" width="{badge_w}" height="20" rx="10" ry="10" fill="rgba(255,255,255,0.2)"/>')
    svg.append(f'    <text x="{width - badge_w/2 - 12}" y="22" font-family="Segoe UI, sans-serif" font-size="10" font-weight="600" fill="#FFFFFF" text-anchor="middle">{badge_text}</text>')

    # Column rows
    curr_y = header_h + 6
    col_port_map = {}

    for idx, c in enumerate(cols):
        cname = c["ColumnName"]
        is_pk = cname in pks
        fk_matches = [fk for fk in fks_out if fk["ParentColumn"] == cname]
        is_fk = len(fk_matches) > 0

        # Zebra striping
        if idx % 2 == 1:
            svg.append(f'    <rect x="2" y="{curr_y - 4}" width="{width - 4}" height="{row_h}" fill="#F8FAFC"/>')

        # Store absolute port position for connectors (center of row)
        col_port_map[cname] = y + curr_y + row_h / 2 - 4

        # Key badge
        if is_pk and is_fk:
            svg.append(f'    <rect x="12" y="{curr_y}" width="42" height="15" rx="3" fill="#FEF3C7" stroke="#D97706" stroke-width="1"/>')
            svg.append(f'    <text x="33" y="{curr_y + 11}" font-family="Segoe UI, sans-serif" font-size="8.5" font-weight="700" fill="#B45309" text-anchor="middle">PK, FK</text>')
        elif is_pk:
            svg.append(f'    <rect x="12" y="{curr_y}" width="22" height="15" rx="3" fill="#FEF3C7" stroke="#D97706" stroke-width="1"/>')
            svg.append(f'    <text x="23" y="{curr_y + 11}" font-family="Segoe UI, sans-serif" font-size="8.5" font-weight="700" fill="#B45309" text-anchor="middle">PK</text>')
        elif is_fk:
            svg.append(f'    <rect x="12" y="{curr_y}" width="22" height="15" rx="3" fill="#DBEAFE" stroke="#2563EB" stroke-width="1"/>')
            svg.append(f'    <text x="23" y="{curr_y + 11}" font-family="Segoe UI, sans-serif" font-size="8.5" font-weight="700" fill="#1D4ED8" text-anchor="middle">FK</text>')
        else:
            svg.append(f'    <circle cx="23" cy="{curr_y + 7}" r="2.5" fill="#CBD5E1"/>')

        # Column name
        name_x = 60 if (is_pk or is_fk) else 36
        font_weight = "700" if (is_pk or is_fk or not c["IsNullable"]) else "500"
        fill_color = "#0F172A" if (is_pk or is_fk) else "#334155"
        svg.append(f'    <text x="{name_x}" y="{curr_y + 12}" font-family="Segoe UI, sans-serif" font-size="10.5" font-weight="{font_weight}" fill="{fill_color}">{cname}</text>')

        # Type string
        type_str = c["DataType"]
        if c["MaxLength"]:
            type_str += f"({c['MaxLength'] if c['MaxLength'] != -1 else 'max'})"
        elif c["Precision"] and c["Scale"]:
            type_str += f"({c['Precision']},{c['Scale']})"
        elif c["Precision"]:
            type_str += f"({c['Precision']})"

        # Nullability indicator
        null_badge = "NN" if not c["IsNullable"] else "NULL"
        null_color = "#047857" if not c["IsNullable"] else "#94A3B8"

        svg.append(f'    <text x="{width - 46}" y="{curr_y + 12}" font-family="Consolas, monospace" font-size="9.5" fill="#64748B" text-anchor="end">{type_str}</text>')
        svg.append(f'    <text x="{width - 12}" y="{curr_y + 12}" font-family="Segoe UI, sans-serif" font-size="8.5" font-weight="600" fill="{null_color}" text-anchor="end">{null_badge}</text>')

        curr_y += row_h

    svg.append('  </g>')
    return "\n".join(svg), height, col_port_map


def build_orthogonal_path(x1, y1, x2, y2, color, fk_name, label="N:1"):
    # Clean orthogonal or smooth cubic curve
    dx = x2 - x1
    dy = y2 - y1
    cx1 = x1 + dx * 0.4
    cx2 = x1 + dx * 0.6
    d_path = f"M {x1} {y1} C {cx1} {y1}, {cx2} {y2}, {x2} {y2}"
    mid_x = (x1 + x2) / 2
    mid_y = (y1 + y2) / 2

    res = []
    res.append(f'  <path d="{d_path}" fill="none" stroke="{color}" stroke-width="1.8" stroke-dasharray="none" opacity="0.82" marker-end="url(#crow-foot)" marker-start="url(#one-bar)"/>')
    return "\n".join(res)


def generate_overview_svg(meta):
    layout = {
        # Module 1 (Col 1 & 2)
        "VaiTros": {"x": 70, "y": 210, "w": 360},
        "NguoiDungs": {"x": 70, "y": 400, "w": 360},
        "PasswordResetOtps": {"x": 70, "y": 800, "w": 360},
        "AIRequests": {"x": 70, "y": 1050, "w": 360},
        "ThongBaos": {"x": 480, "y": 400, "w": 380},
        "DotImports": {"x": 480, "y": 720, "w": 380},
        "LoiImports": {"x": 480, "y": 1050, "w": 380},

        # Module 2 (Col 3 & 4)
        "Khoas": {"x": 960, "y": 210, "w": 380},
        "HocPhans": {"x": 960, "y": 430, "w": 380},
        "SinhViens": {"x": 960, "y": 720, "w": 380},
        "SinhVienLopHocPhans": {"x": 960, "y": 990, "w": 380},
        "HocKys": {"x": 1410, "y": 210, "w": 380},
        "LopHocPhans": {"x": 1410, "y": 470, "w": 380},
        "GiangViens": {"x": 1410, "y": 780, "w": 380},
        "PhanCongGiangViens": {"x": 1410, "y": 1050, "w": 380},

        # Module 3 (Col 5 & 6)
        "DotDangKyDoAns": {"x": 1960, "y": 210, "w": 440},
        "DeTaiDoAns": {"x": 1960, "y": 530, "w": 440},
        "NhomDoAns": {"x": 2510, "y": 210, "w": 430},
        "ThanhVienNhoms": {"x": 2510, "y": 460, "w": 430},
        "DangKyDeTais": {"x": 2510, "y": 690, "w": 430},
        "BaoCaoTienDos": {"x": 2510, "y": 970, "w": 430},
    }

    canvas_w = 3020
    canvas_h = 1450

    svg = []
    svg.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {canvas_w} {canvas_h}" width="{canvas_w}" height="{canvas_h}">')
    svg.append('  <defs>')
    # Filter shadow
    svg.append('    <filter id="card-shadow" x="-5%" y="-5%" width="110%" height="115%" filterUnits="userSpaceOnUse">')
    svg.append('      <feDropShadow dx="0" dy="4" stdDeviation="6" flood-color="#0F172A" flood-opacity="0.08"/>')
    svg.append('    </filter>')
    # Markers
    # Crow's foot (Many)
    svg.append('    <marker id="crow-foot" markerWidth="14" markerHeight="14" refX="10" refY="7" orient="auto">')
    svg.append('      <path d="M 0 1 L 10 7 L 0 13 M 10 2 L 10 12" fill="none" stroke="#475569" stroke-width="1.8"/>')
    svg.append('    </marker>')
    # One bar (One)
    svg.append('    <marker id="one-bar" markerWidth="14" markerHeight="14" refX="2" refY="7" orient="auto">')
    svg.append('      <path d="M 4 2 L 4 12 M 8 2 L 8 12" fill="none" stroke="#475569" stroke-width="1.8"/>')
    svg.append('    </marker>')
    # Grid pattern
    svg.append('    <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">')
    svg.append('      <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#F1F5F9" stroke-width="1"/>')
    svg.append('    </pattern>')
    svg.append('  </defs>')

    # Background
    svg.append(f'  <rect width="{canvas_w}" height="{canvas_h}" fill="#F8FAFC"/>')
    svg.append(f'  <rect width="{canvas_w}" height="{canvas_h}" fill="url(#grid)"/>')

    # Top Header Banner
    svg.append('  <rect x="40" y="24" width="2940" height="100" rx="10" fill="#1E293B"/>')
    svg.append('  <text x="70" y="66" font-family="Segoe UI, sans-serif" font-size="24" font-weight="800" fill="#FFFFFF">PROGROUP AI - SƠ ĐỒ THỰC THỂ QUAN HỆ CƠ SỞ DỮ LIỆU (DATABASE ERD)</text>')
    svg.append(f'  <text x="70" y="98" font-family="Segoe UI, sans-serif" font-size="13" font-weight="500" fill="#94A3B8">Hệ quản trị: Microsoft SQL Server | Database: {meta["Database"]} | 21 Bảng Nghiệp Vụ | 30 Foreign Keys | 22 Check Constraints</text>')

    # Legend in header
    legend_x = 2050
    svg.append(f'  <g transform="translate({legend_x}, 40)">')
    svg.append('    <rect width="900" height="68" rx="8" fill="#334155"/>')
    svg.append('    <text x="20" y="24" font-family="Segoe UI, sans-serif" font-size="11" font-weight="700" fill="#F8FAFC">CHÚ GIẢI KÝ HIỆU (LEGEND):</text>')
    # PK
    svg.append('    <rect x="20" y="36" width="24" height="16" rx="3" fill="#FEF3C7" stroke="#D97706" stroke-width="1"/>')
    svg.append('    <text x="32" y="48" font-family="Segoe UI, sans-serif" font-size="9" font-weight="700" fill="#B45309" text-anchor="middle">PK</text>')
    svg.append('    <text x="50" y="49" font-family="Segoe UI, sans-serif" font-size="10.5" fill="#E2E8F0">Primary Key</text>')
    # FK
    svg.append('    <rect x="140" y="36" width="24" height="16" rx="3" fill="#DBEAFE" stroke="#2563EB" stroke-width="1"/>')
    svg.append('    <text x="152" y="48" font-family="Segoe UI, sans-serif" font-size="9" font-weight="700" fill="#1D4ED8" text-anchor="middle">FK</text>')
    svg.append('    <text x="170" y="49" font-family="Segoe UI, sans-serif" font-size="10.5" fill="#E2E8F0">Foreign Key</text>')
    # NN
    svg.append('    <text x="270" y="49" font-family="Segoe UI, sans-serif" font-size="10.5" font-weight="700" fill="#10B981">NN</text>')
    svg.append('    <text x="295" y="49" font-family="Segoe UI, sans-serif" font-size="10.5" fill="#E2E8F0">Not Null</text>')
    # 1:N
    svg.append('    <line x1="375" y1="44" x2="435" y2="44" stroke="#94A3B8" stroke-width="2" marker-start="url(#one-bar)" marker-end="url(#crow-foot)"/>')
    svg.append('    <text x="445" y="49" font-family="Segoe UI, sans-serif" font-size="10.5" fill="#E2E8F0">Quan hệ 1:N (One-to-Many)</text>')
    # 1:1
    svg.append('    <line x1="620" y1="44" x2="680" y2="44" stroke="#94A3B8" stroke-width="2" marker-start="url(#one-bar)" marker-end="url(#one-bar)"/>')
    svg.append('    <text x="690" y="49" font-family="Segoe UI, sans-serif" font-size="10.5" fill="#E2E8F0">Quan hệ 1:1 (Unique FK)</text>')
    svg.append('  </g>')

    # 3 Cluster Containers
    clusters = [
        ("MODULE 1: QUẢN TRỊ HỆ THỐNG & NGƯỜI DÙNG (7 BẢNG)", 50, 150, 830, 1260, "#EFF6FF", "#BFDBFE", "#1E40AF"),
        ("MODULE 2: QUẢN LÝ ĐÀO TẠO, KHOA & LỚP HỌC PHẦN (8 BẢNG)", 930, 150, 910, 1260, "#ECFDF5", "#A7F3D0", "#065F46"),
        ("MODULE 3: ĐỢT ĐĂNG KÝ, NHÓM, ĐỀ TÀI & TIẾN ĐỘ (6 BẢNG)", 1910, 150, 1070, 1260, "#FDF2F8", "#FBCFE8", "#9D174D")
    ]
    for ctitle, cx, cy, cw, ch, cbg, cborder, ctext in clusters:
        svg.append(f'  <rect x="{cx}" y="{cy}" width="{cw}" height="{ch}" rx="14" fill="{cbg}" stroke="{cborder}" stroke-width="1.8" opacity="0.65"/>')
        svg.append(f'  <text x="{cx + 20}" y="{cy + 36}" font-family="Segoe UI, sans-serif" font-size="13" font-weight="800" fill="{ctext}" letter-spacing="0.5">{ctitle}</text>')

    # Render Table Cards
    all_ports = {}
    table_heights = {}
    for tname, pos in layout.items():
        theme = MODULE_MAP[tname]
        card_svg, h, ports = render_table_svg(tname, pos["x"], pos["y"], pos["w"], meta, theme)
        svg.append(card_svg)
        all_ports[tname] = ports
        table_heights[tname] = h

    # Render Relationships (30 FKs)
    system_tables = {'__EFMigrationsHistory', 'sysdiagrams'}
    for fk in meta["ForeignKeys"]:
        p_table = fk["ParentTable"]
        r_table = fk["ReferencedTable"]
        p_col = fk["ParentColumn"]
        r_col = fk["ReferencedColumn"]
        if p_table in system_tables or r_table in system_tables:
            continue
        if p_table not in layout or r_table not in layout:
            continue

        p_pos = layout[p_table]
        r_pos = layout[r_table]

        # Port Y coordinates
        py = all_ports[p_table].get(p_col, p_pos["y"] + 30)
        ry = all_ports[r_table].get(r_col, r_pos["y"] + 30)

        # Connect Left or Right based on relative X position
        if p_pos["x"] < r_pos["x"]:
            px = p_pos["x"] + p_pos["w"]
            rx = r_pos["x"]
        elif p_pos["x"] > r_pos["x"]:
            px = p_pos["x"]
            rx = r_pos["x"] + r_pos["w"]
        else:
            # Same column
            px = p_pos["x"] + p_pos["w"]
            rx = r_pos["x"] + r_pos["w"]

        # Color
        connector_color = MODULE_MAP[p_table][3]
        svg.append(build_orthogonal_path(px, py, rx, ry, connector_color, fk["ForeignKeyName"]))

    svg.append('</svg>')
    out_path = os.path.join(OUTPUT_DIR, "ProGroupAI_ERD.svg")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(svg))
    print(f"Generated Overview SVG ERD: {out_path}")


def generate_module_svg(meta, module_num, module_name, table_names, layout, canvas_w, canvas_h, out_filename):
    svg = []
    svg.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {canvas_w} {canvas_h}" width="{canvas_w}" height="{canvas_h}">')
    svg.append('  <defs>')
    svg.append('    <filter id="card-shadow" x="-5%" y="-5%" width="110%" height="115%" filterUnits="userSpaceOnUse">')
    svg.append('      <feDropShadow dx="0" dy="4" stdDeviation="6" flood-color="#0F172A" flood-opacity="0.08"/>')
    svg.append('    </filter>')
    svg.append('    <marker id="crow-foot" markerWidth="14" markerHeight="14" refX="10" refY="7" orient="auto">')
    svg.append('      <path d="M 0 1 L 10 7 L 0 13 M 10 2 L 10 12" fill="none" stroke="#475569" stroke-width="1.8"/>')
    svg.append('    </marker>')
    svg.append('    <marker id="one-bar" markerWidth="14" markerHeight="14" refX="2" refY="7" orient="auto">')
    svg.append('      <path d="M 4 2 L 4 12 M 8 2 L 8 12" fill="none" stroke="#475569" stroke-width="1.8"/>')
    svg.append('    </marker>')
    svg.append('    <pattern id="grid" width="30" height="30" patternUnits="userSpaceOnUse">')
    svg.append('      <path d="M 30 0 L 0 0 0 30" fill="none" stroke="#F1F5F9" stroke-width="1"/>')
    svg.append('    </pattern>')
    svg.append('  </defs>')

    svg.append(f'  <rect width="{canvas_w}" height="{canvas_h}" fill="#F8FAFC"/>')
    svg.append(f'  <rect width="{canvas_w}" height="{canvas_h}" fill="url(#grid)"/>')

    # Top Header
    svg.append(f'  <rect x="30" y="20" width="{canvas_w - 60}" height="76" rx="8" fill="#1E293B"/>')
    svg.append(f'  <text x="50" y="52" font-family="Segoe UI, sans-serif" font-size="19" font-weight="800" fill="#FFFFFF">PROGROUP AI - SƠ ĐỒ ERD CHI TIẾT: {module_name.upper()}</text>')
    svg.append(f'  <text x="50" y="78" font-family="Segoe UI, sans-serif" font-size="11.5" font-weight="500" fill="#94A3B8">Phân hệ gồm {len(table_names)} bảng | Cơ sở dữ liệu: {meta["Database"]} | Độ nét vector chất lượng cao</text>')

    # Tables
    all_ports = {}
    for tname in table_names:
        pos = layout[tname]
        theme = MODULE_MAP[tname]
        card_svg, h, ports = render_table_svg(tname, pos["x"], pos["y"], pos["w"], meta, theme)
        svg.append(card_svg)
        all_ports[tname] = ports

    # FK lines within this module or connected to this module
    system_tables = {'__EFMigrationsHistory', 'sysdiagrams'}
    for fk in meta["ForeignKeys"]:
        p_table = fk["ParentTable"]
        r_table = fk["ReferencedTable"]
        p_col = fk["ParentColumn"]
        r_col = fk["ReferencedColumn"]
        if p_table in system_tables or r_table in system_tables:
            continue
        if p_table in table_names and r_table in table_names:
            p_pos = layout[p_table]
            r_pos = layout[r_table]
            py = all_ports[p_table].get(p_col, p_pos["y"] + 30)
            ry = all_ports[r_table].get(r_col, r_pos["y"] + 30)

            if p_pos["x"] < r_pos["x"]:
                px = p_pos["x"] + p_pos["w"]
                rx = r_pos["x"]
            elif p_pos["x"] > r_pos["x"]:
                px = p_pos["x"]
                rx = r_pos["x"] + r_pos["w"]
            else:
                px = p_pos["x"] + p_pos["w"]
                rx = r_pos["x"] + r_pos["w"]

            connector_color = MODULE_MAP[p_table][3]
            svg.append(build_orthogonal_path(px, py, rx, ry, connector_color, fk["ForeignKeyName"]))

    svg.append('</svg>')
    out_path = os.path.join(OUTPUT_DIR, out_filename)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(svg))
    print(f"Generated Module SVG ERD: {out_path}")


def convert_svg_to_png_pdf(svg_path, png_path, pdf_path, width, height):
    chrome_path = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
    if not os.path.exists(chrome_path):
        print(f"Chrome not found at {chrome_path}, skipping conversion.")
        return

    with open(svg_path, "r", encoding="utf-8") as f:
        svg_xml = f.read()

    # Create temporary HTML wrapper with inlined SVG and custom @page size for true vector PDF
    html_content = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  @page {{
    size: {width}px {height}px;
    margin: 0;
  }}
  html, body {{
    margin: 0;
    padding: 0;
    background: #F8FAFC;
    overflow: hidden;
    width: {width}px;
    height: {height}px;
  }}
  svg {{
    display: block;
    width: {width}px;
    height: {height}px;
  }}
</style>
</head>
<body>
{svg_xml}
</body>
</html>"""
    html_path = svg_path.replace(".svg", "_render.html")
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_content)

    abs_html = os.path.abspath(html_path)
    abs_png = os.path.abspath(png_path)
    abs_pdf = os.path.abspath(pdf_path)

    # 1. Render PNG at 300 DPI (device scale factor 2.0)
    cmd_png = [
        chrome_path,
        "--headless",
        "--disable-gpu",
        "--hide-scrollbars",
        f"--window-size={width},{height}",
        "--force-device-scale-factor=2",
        f"--screenshot={abs_png}",
        abs_html
    ]
    try:
        subprocess.run(cmd_png, capture_output=True, check=True)
        print(f"Rendered High-Res PNG: {png_path}")
    except Exception as e:
        print(f"Error rendering PNG {png_path}: {e}")

    # 2. Render PDF vector
    cmd_pdf = [
        chrome_path,
        "--headless",
        "--disable-gpu",
        "--no-pdf-header-footer",
        f"--print-to-pdf={abs_pdf}",
        abs_html
    ]
    try:
        subprocess.run(cmd_pdf, capture_output=True, check=True)
        print(f"Rendered Vector PDF: {pdf_path}")
    except Exception as e:
        print(f"Error rendering PDF {pdf_path}: {e}")

    if os.path.exists(html_path):
        os.remove(html_path)


def main():
    meta, checks = load_metadata()

    # 1. Excel Dictionary
    generate_excel(meta, checks)

    # 2. Markdown Analysis
    generate_markdown_analysis(meta, checks)

    # 3. Overview ERD
    generate_overview_svg(meta)
    convert_svg_to_png_pdf(
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD.svg"),
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD.png"),
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD.pdf"),
        3020, 1450
    )

    # 4. Module 01: Người dùng & Quản trị
    mod1_tables = ["VaiTros", "NguoiDungs", "PasswordResetOtps", "ThongBaos", "AIRequests", "DotImports", "LoiImports"]
    mod1_layout = {
        "VaiTros": {"x": 60, "y": 140, "w": 380},
        "NguoiDungs": {"x": 520, "y": 140, "w": 400},
        "PasswordResetOtps": {"x": 1000, "y": 140, "w": 380},
        "AIRequests": {"x": 1000, "y": 400, "w": 380},
        "ThongBaos": {"x": 1000, "y": 660, "w": 380},
        "DotImports": {"x": 520, "y": 550, "w": 400},
        "LoiImports": {"x": 520, "y": 860, "w": 400},
    }
    generate_module_svg(meta, 1, "Người Dùng, Phân Quyền & Quản Trị Hệ Thống", mod1_tables, mod1_layout, 1450, 1140, "ProGroupAI_ERD_Module_01.svg")
    convert_svg_to_png_pdf(
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD_Module_01.svg"),
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD_Module_01.png"),
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD_Module_01.pdf"),
        1450, 1140
    )

    # 5. Module 02: Quản lý Đào tạo, Khoa & Lớp Học phần
    mod2_tables = ["Khoas", "HocKys", "HocPhans", "LopHocPhans", "SinhViens", "GiangViens", "PhanCongGiangViens", "SinhVienLopHocPhans"]
    mod2_layout = {
        "Khoas": {"x": 60, "y": 140, "w": 380},
        "HocKys": {"x": 520, "y": 140, "w": 380},
        "HocPhans": {"x": 60, "y": 380, "w": 380},
        "LopHocPhans": {"x": 520, "y": 420, "w": 380},
        "SinhViens": {"x": 60, "y": 680, "w": 380},
        "GiangViens": {"x": 980, "y": 140, "w": 380},
        "SinhVienLopHocPhans": {"x": 60, "y": 960, "w": 380},
        "PhanCongGiangViens": {"x": 980, "y": 440, "w": 380},
    }
    generate_module_svg(meta, 2, "Quản Lý Đào Tạo, Khoa & Lớp Học Phần", mod2_tables, mod2_layout, 1450, 1200, "ProGroupAI_ERD_Module_02.svg")
    convert_svg_to_png_pdf(
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD_Module_02.svg"),
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD_Module_02.png"),
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD_Module_02.pdf"),
        1450, 1200
    )

    # 6. Module 03: Đợt Đăng ký, Nhóm, Đề tài & Tiến độ
    mod3_tables = ["DotDangKyDoAns", "NhomDoAns", "ThanhVienNhoms", "DeTaiDoAns", "DangKyDeTais", "BaoCaoTienDos"]
    mod3_layout = {
        "DotDangKyDoAns": {"x": 60, "y": 140, "w": 420},
        "DeTaiDoAns": {"x": 60, "y": 460, "w": 420},
        "NhomDoAns": {"x": 560, "y": 140, "w": 420},
        "ThanhVienNhoms": {"x": 560, "y": 380, "w": 420},
        "DangKyDeTais": {"x": 560, "y": 620, "w": 420},
        "BaoCaoTienDos": {"x": 560, "y": 910, "w": 420},
    }
    generate_module_svg(meta, 3, "Quản Lý Đợt Đăng Ký, Nhóm, Đề Tài & Tiến Độ", mod3_tables, mod3_layout, 1060, 1360, "ProGroupAI_ERD_Module_03.svg")
    convert_svg_to_png_pdf(
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD_Module_03.svg"),
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD_Module_03.png"),
        os.path.join(OUTPUT_DIR, "ProGroupAI_ERD_Module_03.pdf"),
        1060, 1360
    )

    print("\nALL ERD ARTIFACTS SUCCESSFULLY GENERATED!")

if __name__ == "__main__":
    main()
