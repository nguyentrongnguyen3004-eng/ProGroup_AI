# 04. BÁO CÁO ĐỘ NHẤT QUÁN API & KHỚP NỐI DỮ LIỆU (API CONSISTENCY AUDIT)

## 1. TỔNG QUAN
Báo cáo này phân tích sự không đồng bộ giữa đặc tả API của Backend (ASP.NET Core) và mã nguồn triệu gọi của Frontend (Flutter), bao gồm:
- Sai lệch HTTP Method (Dẫn đến mã lỗi 405 Method Not Allowed).
- Endpoint không tồn tại trên Backend (Dẫn đến mã lỗi 404 Not Found).
- Bất đồng bộ về quy tắc đặt tên trường dữ liệu (Naming Conventions: PascalCase vs camelCase, tên trường khác nhau).
- Lỗi Nullability và sai kiểu dữ liệu khi parse JSON.

---

## 2. CHI TIẾT CÁC LỖI BẤT ĐỒNG BỘ NGHIÊM TRỌNG

### 2.1. Lỗi HTTP Method: Đổi Mật Khẩu Bị Lỗi 405 Method Not Allowed
- **Vị trí Backend:** `ProGroup_AI.API/Controllers/AuthController.cs`, dòng 122:
  ```csharp
  [Authorize]
  [HttpPut("change-password")]
  public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
  ```
  Backend khai báo route là **`PUT /api/Auth/change-password`**.
- **Vị trí Frontend:**
  - `services/admin_api_service.dart:100`: `ApiService.instance.post('/api/auth/change-password', ...)`
  - `services/governance_api_service.dart:104`: `ApiService.instance.post('/api/auth/change-password', ...)`
  - `services/lecturer_api_service.dart:482`: `ApiService.instance.post('/api/auth/change-password', ...)`
- **Hậu quả:** Khi Admin, Giáo vụ khoa hoặc Giảng viên gọi chức năng đổi mật khẩu từ các service trên, Web API trả về `HTTP 405 Method Not Allowed`. Chức năng hoàn toàn tê liệt!
- **Khắc phục:** Đồng bộ lại sử dụng `PUT` trên toàn bộ Frontend service, hoặc thêm attribute `[HttpPost("change-password")]` trên Backend `AuthController`.

---

### 2.2. Lỗi Endpoint 404: Gọi Endpoint Không Tồn Tại `/api/de-tai/proposals`
- **Vị trí Frontend:** `services/lecturer_api_service.dart`, dòng 389:
  ```dart
  Future<List<TopicModel>> getProposedTopics() async {
    final res = await ApiService.instance.get('/api/de-tai/proposals');
    ...
  }
  ```
- **Vị trí Backend:** Kiểm tra `DeTaiController.cs` và `ProjectsController.cs`:
  - `DeTaiController` chỉ có các route:
    - `GET /api/de-tai`
    - `GET /api/de-tai/cua-toi`
    - `GET /api/de-tai/de-xuat-cua-toi` (cho sinh viên xem đề xuất của mình)
    - `GET /api/de-tai/lecturer-topics`
  - **HOÀN TOÀN KHÔNG CÓ** endpoint `GET /api/de-tai/proposals`!
- **Hậu quả:** Giảng viên khi truy cập màn hình duyệt đề tài đề xuất từ sinh viên sẽ nhận lỗi `HTTP 404 Not Found`.

---

### 2.3. Bất Đồng Bộ Mô Hình Dữ Liệu (DTO & Field Name Mismatches)

| Thực thể / Model | Trường Backend trả về | Trường Frontend mong đợi | Tác động |
|---|---|---|---|
| **AdminAccountModel** | `avatarUrl` (từ `NguoiDung.AvatarUrl`) | `avatar` (trong `admin_account_model.dart:32`) | Avatar của tài khoản luôn bị `null`, hiển thị ảnh placeholder mặc định. |
| **AdminAccountModel** | `trangThai` ("HoatDong" / "BiKhoa") | `isLocked` (kiểu boolean) | Frontend phải parse thủ công `trangThai == 'BiKhoa'`, nếu Backend trả về dạng khác thì logic khóa tài khoản bị đảo ngược. |
| **CourseModel** | `giangVien` (Object `GiangVienDto`) | `giangVienName` (String đơn giản) | Nếu JSON không bóc tách phẳng (flatten), `CourseModel.fromJson` sẽ throw FormatException khiến toàn bộ danh sách lớp crash! |
| **TopicModel** | `maDeTai` ("DT001") | `code` hoặc `id` | Trường mã đề tài bị rỗng trên giao diện chi tiết đề tài. |

---

### 2.4. Rủi Ro Xung Đột Serializer Case-Sensitivity
- Backend cấu hình mặc định camelCase qua `System.Text.Json`, tuy nhiên một số Raw SQL DTO trong `AdminController.cs` và `LopHocPhanController.cs` trả về `anonymous object` với tên thuộc tính viết hoa (PascalCase):
  ```csharp
  // AdminController.cs
  return Ok(new {
      TongSoNguoiDung = totalUsers,
      TyLeHoanThanh = 85.5,
      PhoDiem = ...
  });
  ```
- Nếu frontend đọc `json['tongSoNguoiDung']` sẽ nhận giá trị `null`. Điều này đòi hỏi Frontend phải xử lý parse cả 2 trường hợp `json['TongSoNguoiDung'] ?? json['tongSoNguoiDung']`.
