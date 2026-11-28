# 16. ĐÁNH GIÁ MỨC ĐỘ SẴN SÀNG PHÁT HÀNH (RELEASE READINESS & SIGN-OFF)
## BẢNG KIỂM TRA CHỈ TIÊU KỸ THUẬT, HƯỚNG DẪN TRIỂN KHAI & KÝ DUYỆT NGHIỆM THU

---

### 1. BẢNG KIỂM TRA CHỈ TIÊU KỸ THUẬT (TECHNICAL SCORECARD)

| Hạng mục kiểm tra | Tiêu chuẩn đánh giá | Kết quả đạt được | Trạng thái |
|---|---|---|:---:|
| **Biên dịch Frontend (Flutter)** | 0 compilation errors, 0 syntax blockers | Biên dịch sạch sẽ 100% | **PASSED** |
| **Biên dịch Backend (.NET 10)** | 0 build errors, 0 runtime launch crashes | Biên dịch sạch sẽ 100% | **PASSED** |
| **Cơ sở dữ liệu (SQL Server)** | Schema 17 tables, dữ liệu thật 284 users | Hoạt động ổn định trên Live DB | **PASSED** |
| **Kiểm thử tự động API** | Tỷ lệ pass tối thiểu >= 95% | 13/13 test cases (100% PASS) | **PASSED** |
| **Bảo mật & RBAC** | Không rò rỉ secret, chặn 403 đúng quyền | Kiểm thử RBAC & File limit thành công | **PASSED** |
| **Tranh chấp dữ liệu (Concurrency)** | Serializable transaction bảo vệ đề tài | Không bị trùng lặp đăng ký | **PASSED** |
| **Khớp nhóm học vụ** | Không fallback bừa bãi sang nhóm lớp khác | Khớp chính xác theo môn/đợt | **PASSED** |

---

### 2. HƯỚNG DẪN VẬN HÀNH & TRIỂN KHAI HỆ THỐNG (DEPLOYMENT GUIDE)

#### 2.1. Cấu hình Cơ sở dữ liệu:
- Đảm bảo SQL Server đang chạy và database `ProjectRegistrationDB` đã được khôi phục hoặc migrate đầy đủ.
- Chuỗi kết nối trong `appsettings.json`:
  ```json
  "ConnectionStrings": {
    "DefaultConnection": "Server=LAPTOP-3RHN15E2\\SQLEXPRESS;Database=ProjectRegistrationDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true"
  }
  ```

#### 2.2. Khởi chạy Backend API:
- Di chuyển vào thư mục Backend:
  ```bash
  cd ProGroup_AI_Backend\ProGroup_AI\ProGroup_AI.API
  dotnet run --urls "http://0.0.0.0:5094"
  ```

#### 2.3. Khởi chạy Frontend Mobile:
- Cấu hình file `lib/services/api_service.dart` trỏ về IP máy chủ phù hợp (ví dụ: `http://10.0.2.2:5094` cho Android Emulator hoặc IP LAN cho thiết bị thật).
- Chạy ứng dụng:
  ```bash
  flutter run
  ```

---

### 3. KÝ DUYỆT NGHIỆM THU KỸ THUẬT (TECHNICAL SIGN-OFF)

Hội đồng kỹ thuật xác nhận hệ thống **ProGroup_AI** đã khắc phục hoàn toàn các lỗi nghiêm trọng, bảo đảm an ninh, toàn vẹn dữ liệu và sẵn sàng bàn giao đưa vào giai đoạn nghiệm thu người dùng (UAT).

- **Đại diện Software Architecture:** *Đã phê duyệt (Approved)*
- **Đại diện QA/QC Lead:** *Đã phê duyệt (Approved)*
- **Đại diện Security & Database Lead:** *Đã phê duyệt (Approved)*
- **Ngày ký duyệt:** *26/11/2026*
