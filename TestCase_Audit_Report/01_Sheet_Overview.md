# 01. BÁO CÁO TỔNG QUAN TẤT CẢ CÁC SHEET TEST CASE

## 1.1. Bảng Thống Kê Theo Sheet

| STT | Tên Sheet | Nhóm chức năng | Tổng số TC | FIXED | PARTIALLY FIXED | NOT FIXED | BLOCKED | Tỷ lệ Đạt |
|---|---|---|---|---|---|---|---|---|
| 1 | 1. Tổng quan & Dashboard | Trang bìa, Kiến trúc, Môi trường kiểm thử | 34 dòng metadata | - | - | - | - | **Dashboard & Meta** |
| 2 | 2. Xác thực & Hệ thống | Xác thực & Hệ thống | 28 | 28 | 0 | 0 | 0 | **100.0%** |
| 3 | 3. Phân hệ Sinh viên | Phân hệ Sinh viên | 57 | 57 | 0 | 0 | 0 | **100.0%** |
| 4 | 4. Phân hệ Giảng viên | Phân hệ Giảng viên | 30 | 30 | 0 | 0 | 0 | **100.0%** |
| 5 | 5. Giáo vụ khoa | Giáo vụ khoa | 25 | 19 | 0 | 6 | 0 | **76.0%** |
| 6 | 6. Phòng đào tạo | Phòng đào tạo | 20 | 9 | 0 | 11 | 0 | **45.0%** |
| 7 | 7. Quản trị hệ thống | Quản trị hệ thống | 24 | 24 | 0 | 0 | 0 | **100.0%** |
| 8 | 8. Phi chức năng & Bảo mật | Phi chức năng & Bảo mật | 16 | 16 | 0 | 0 | 0 | **100.0%** |
| **TỔNG** | **8 Sheets** | **Toàn bộ hệ thống** | **200** | **183** | **0** | **17** | **0** | **91.5%** |

## 1.2. Nhận Xét Chuyên Môn Của QA Lead

1. **Độ bao phủ kiểm thử**: Đạt 100% đối chiếu (200/200 Test Cases từ Google Sheets chính thức).
2. **Chất lượng các phân hệ lõi**:
   - *Xác thực & Hệ thống*: 100% FIXED (28/28 TCs), hỗ trợ phục hồi kết nối và khóa tài khoản tức thì.
   - *Phân hệ Sinh viên*: 100% FIXED (57/57 TCs), giải quyết triệt để lỗi đăng ký nhầm nhóm chéo môn học, stream chat thời gian thực, upload avatar và nộp báo cáo.
   - *Phân hệ Giảng viên*: 100% FIXED (30/30 TCs), bảo vệ thang điểm 0-10, ngăn chọn ngày quá khứ, hiển thị link tài liệu đính kèm.
   - *Quản trị hệ thống*: 100% FIXED (24/24 TCs), hoàn thiện dashboard phân bổ 5 vai trò chuẩn 100% và validation SĐT.
   - *Giáo vụ khoa & Phòng đào tạo*: Đã hoàn thiện các tính năng cốt lõi (xem LHP, phân công giảng viên, danh mục toàn trường, cập nhật thông tin cá nhân và avatar cô lập). 17 test case còn lại thuộc về các module AI dự báo học vụ và biểu đồ phân tích chuyên sâu nâng cao.
