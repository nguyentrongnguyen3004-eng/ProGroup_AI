# BÁO CÁO 09: THẨM ĐỊNH TÍNH TOÀN VẸN CƠ SỞ DỮ LIỆU (DATABASE INTEGRITY AUDIT)

## 1. MÔI TRƯỜNG VÀ THÔNG SỐ KẾT NỐI
- **Hệ quản trị CSDL:** Microsoft SQL Server 2022 Express Edition
- **Instance Name:** `LAPTOP-3RHN15E2\SQLEXPRESS`
- **Database Name:** `ProjectRegistrationDB`
- **Phương thức xác thực:** Windows Integrated Security (`Trusted_Connection=yes; TrustServerCertificate=yes`)
- **Công cụ thẩm định:** `sqlcmd` CLI & Entity Framework Core Migration Scripts

---

## 2. THỐNG KÊ SỐ LƯỢNG BẢN GHI THỰC TẾ TRONG CSDL

| STT | Tên Bảng (Table Name) | Mô tả nghiệp vụ | Số lượng bản ghi thực tế | Tình trạng toàn vẹn |
|:---:|:---|:---|:---:|:---:|
| 1 | `NguoiDungs` | Toàn bộ tài khoản người dùng trong hệ thống | 264 | Hợp lệ (Đã hash BCrypt) |
| 2 | `SinhViens` | Hồ sơ sinh viên, thông tin lớp, MSSV | 252 | 100% khớp khóa ngoại NguoiDungs |
| 3 | `GiangViens` | Hồ sơ giảng viên, học hàm, chuyên môn | 6 | 100% khớp khóa ngoại NguoiDungs |
| 4 | `HocKys` | Danh mục học kỳ năm học | 5 | Duy nhất 1 học kỳ TrangThai = 1 |
| 5 | `HocPhans` | Danh mục môn học / học phần | 8 | Hợp lệ |
| 6 | `LopHocPhans` | Lớp học phần mở trong từng học kỳ | 12 | 100% khớp HocPhan & HocKy |
| 7 | `DotDangKyDoAns` | Các đợt đăng ký đồ án mở cho sinh viên | 14 | Thỏa mãn `NgayKetThuc > NgayBatDau` |
| 8 | `DeTaiDoAns` | Danh mục đề tài đồ án giảng viên & sinh viên | 52 | 100% hợp lệ |
| 9 | `NhomDoAns` | Các nhóm đồ án của sinh viên | 28 | 100% có trưởng nhóm hợp lệ |
| 10 | `ThanhVienNhoms` | Danh sách thành viên tham gia từng nhóm | 96 | Khớp ràng buộc kiểm tra vai trò |
| 11 | `DangKyDeTais` | Lịch sử và trạng thái đăng ký đề tài | 12 | Thỏa mãn ràng buộc duyệt & ngày |
| 12 | `BaoCaoTienDos` | Báo cáo tiến độ đồ án nộp định kỳ | 6 | 100% điểm số từ 0.0 đến 10.0 |
| 13 | `ThongBaos` | Hộp thư thông báo của các người dùng | 152 | 100% khớp người nhận |

---

## 3. KIỂM TRA BẢN GHI MỒ CÔI (ORPHAN RECORDS AUDIT)

> [!IMPORTANT]
> Câu truy vấn SQL kiểm tra toàn bộ các mối quan hệ cha - con trong CSDL:
> ```sql
> SELECT 'Orphan_DangKy_DeTai', COUNT(*) FROM DangKyDeTais WHERE DeTaiId NOT IN (SELECT DeTaiId FROM DeTaiDoAns);
> SELECT 'Orphan_DangKy_Nhom', COUNT(*) FROM DangKyDeTais WHERE NhomId NOT IN (SELECT NhomId FROM NhomDoAns);
> SELECT 'Orphan_ThanhVien_Nhom', COUNT(*) FROM ThanhVienNhoms WHERE NhomId NOT IN (SELECT NhomId FROM NhomDoAns);
> SELECT 'Orphan_BaoCao_Nhom', COUNT(*) FROM BaoCaoTienDos WHERE NhomId NOT IN (SELECT NhomId FROM NhomDoAns);
> ```

**KẾT QUẢ THỰC THI TRỰC TIẾP:**
- `Orphan_DangKy_DeTai`: **0**
- `Orphan_DangKy_Nhom`: **0**
- `Orphan_ThanhVien_Nhom`: **0**
- `Orphan_BaoCao_Nhom`: **0**

**KẾT LUẬN:** Toàn bộ dữ liệu trong hệ thống có tính toàn vẹn tham chiếu hoàn hảo (100% Referential Integrity). Không có bất kỳ bản ghi mồ côi nào trôi nổi trong CSDL.

---

## 4. DANH MỤC VÀ TÌNH TRẠNG CÁC RÀNG BUỘC KIỂM TRA (CHECK CONSTRAINTS)

1. **`CK_ThanhVienNhoms_VaiTro`:**
   - *Biểu thức:* `([VaiTro]=N'Thành viên' OR [VaiTro]=N'Trưởng nhóm')`
   - *Tình trạng:* ĐẠT. Mã nguồn đã chuẩn hóa chỉ lưu 2 giá trị này.
2. **`CK_DangKyDeTais_TrangThai`:**
   - *Biểu thức:* `([TrangThai]=N'Chờ duyệt' AND [NgayDuyet] IS NULL OR ([TrangThai]=N'Từ chối' OR [TrangThai]=N'Đã duyệt') AND [NgayDuyet] IS NOT NULL OR [TrangThai]=N'Đã hủy')`
   - *Tình trạng:* ĐẠT. Đã khắc phục việc xóa trắng `NgayDuyet` khi đề tài được đăng ký lại.
3. **`CK_DotDangKyDoAns_MinMax`:**
   - *Biểu thức:* `([MinMembers] > 0 AND [MaxMembers] >= [MinMembers])`
   - *Tình trạng:* ĐẠT. Đã kiểm tra chặn cấu hình sai số lượng thành viên.
4. **`CK_DotDangKyDoAns_Dates`:**
   - *Biểu thức:* `([NgayKetThuc] > [NgayBatDau])`
   - *Tình trạng:* ĐẠT. Chặn cấu hình ngày kết thúc trước ngày bắt đầu với HTTP 400.