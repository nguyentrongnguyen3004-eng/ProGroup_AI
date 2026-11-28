# 04. Kiểm toán Hiệu năng Microsoft SQL Server

**Instance:** `LAPTOP-3RHN15E2\SQLEXPRESS`  
**Database:** `ProjectRegistrationDB`

---

## 1. Quy mô Dữ liệu Thực tế (Row Counts)

Dữ liệu hiện tại là dữ liệu thật của hệ thống với tổng số dòng chính:

| Bảng | Số dòng | Bảng | Số dòng |
| --- | ---: | --- | ---: |
| `SinhVienLopHocPhans` | 451 | `HocPhans` | 7 |
| `NguoiDungs` | 264 | `BaoCaoTienDos` | 6 |
| `SinhViens` | 252 | `GiangViens` | 6 |
| `ThongBaos` | 104 | `HocKys` | 6 |
| `ThanhVienNhoms` | 96 | `Khoas` | 5 |
| `DeTaiDoAns` | 52 | `VaiTros` | 5 |
| `NhomDoAns` | 28 | `DotImports` | 4 |
| `DotDangKyDoAns` | 14 | `AIRequests` | 2 |
| `PhanCongGiangViens` | 13 | `LoiImports` | 2 |
| `LopHocPhans` | 12 | `PasswordResetOtps` | 2 |
| `DangKyDeTais` | 12 | | |

> Nhận xét quan trọng: Với quy mô dưới 500 dòng/bảng, toàn bộ các bảng đều rất nhỏ — bất kỳ độ trễ nào lên tới **14–25 giây** đều là **bất thường nghiêm trọng về tài nguyên / Memory Grant**, không phải do lượng dữ liệu lớn.

---

## 2. Cấu hình Bộ nhớ & Bằng chứng `RESOURCE_SEMAPHORE`

### Tình trạng Bộ nhớ Hệ điều hành & SQL Server
- RAM vật lý máy host: `HostTotalMB = 15676`
- RAM khả dụng tại thời điểm audit: `HostAvailMB = 775`
- Bộ nhớ SQL Server đang sử dụng: `SqlMemInUseMB = 104`
- Trạng thái áp lực bộ nhớ trong `sys.dm_os_process_memory`: **`process_physical_memory_low = 1`**, `process_virtual_memory_low = 0`.

### Bằng chứng từ `sys.dm_exec_query_resource_semaphores`
- Trước/sau khi phát sinh nghẽn:
  - `resource_semaphore_id = 0`: `target_memory_kb` bị OS memory pressure ép xuống **`8,040 KB` (~7.85 MB)** và hiện tại là **`8,160 KB` (~7.97 MB)** (trong khi `max_target_memory_kb = 262,200 KB`).
  - `forced_grant_count = 29` (tăng lên `30` trong lúc chạy stress trước khi sửa `DeTaiController`, sau khi sửa và chạy lại toàn bộ benchmark + integration tests vẫn giữ nguyên `30`).

### Bằng chứng từ `sys.dm_os_wait_stats` (Tổng hợp cộng dồn trên instance)

| `wait_type` | `waiting_tasks_count` | `wait_time_ms` | `max_wait_time_ms` |
| --- | ---: | ---: | ---: |
| `RESOURCE_SEMAPHORE` | 83 | 1,430,892 | **25,015** |
| `PAGEIOLATCH_SH` | 21,650 | 9,405 | 45 |
| `SOS_SCHEDULER_YIELD` | 6,398 | 3,969 | 300 |
| `ASYNC_NETWORK_IO` | 22,709 | 2,004 | 99 |
| `WRITELOG` | 1,623 | 348 | 23 |
| `LCK_M_X` | 167 | 168 | 13 |
| `BACKUPIO` | 994 | 161 | 2 |
| `LCK_M_S` | 34 | 142 | 63 |

`RESOURCE_SEMAPHORE` chiếm tới **1,430.89 giây** chờ tích lũy và đỉnh **`25,015 ms` (25 giây)** cho một truy vấn — khớp chính xác với thời gian cold call `25,093.56 ms` của `GET /api/student/groups` và `25,077.34 ms` từng gặp ở `GET /api/de-tai`.

---

## 3. Phân tích Query Plan & Thiếu Chỉ mục

1. **Toán tử `Sort` với `AvgRowSize = 15,756 bytes` (`DeTaiDoAns`):**  
   Khi chạy `SET STATISTICS PROFILE ON` cho truy vấn danh sách đề tài có `ORDER BY CreatedAt DESC`, SQL Server ước lượng kích thước dòng trung bình **`15,756 bytes`** do kéo theo các cột `NVARCHAR(MAX)` (`MoTa`, `MucTieu`, `YeuCauKetQua`, `CongNgheGoiY`). Toán tử `Sort` yêu cầu Memory Grant nhiều MB cho buffer sắp xếp; khi `target_memory_kb` của semaphore chỉ có ~8 MB, chỉ cần 1–2 truy vấn đồng thời là truy vấn sau bị treo chờ `RESOURCE_SEMAPHORE` tới 25 giây (`timeout` của resource semaphore trước khi ép cấp `forced_grant`).
2. **Thiếu Composite Covering Indexes cho các filter/sort phổ biến:**  
   Trước tối ưu, các bảng chỉ có index đơn trên khóa ngoại (do EF Core tạo tự động), chưa có composite index theo cặp `(KhoaNgoai, TrangThai)` hoặc `(NguoiDungId, LoaiLienKet, CreatedAt)` cho:
   - `ThongBaos`: lọc theo `(NguoiDungId, LoaiLienKet, CreatedAt)` + `INCLUDE (DaDoc)`.
   - `ThanhVienNhoms`: lọc đồng thời `(SinhVienId, TrangThai)` và `(NhomId, TrangThai)`.
   - `DangKyDeTais`: lọc theo `TrangThai` + `INCLUDE (NhomId, DeTaiId, NgayDangKy)`.
   - `DeTaiDoAns`: sắp xếp/truy vấn theo `CreatedAt`.
   - `DotDangKyDoAns`: lọc theo `(LopHocPhanId, TrangThai)`.
   - `SinhVienLopHocPhans`: lọc theo `(SinhVienId, TrangThai)`.
   - `PhanCongGiangViens`: lọc theo `(GiangVienId, TrangThai)`.
