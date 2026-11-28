# 08. BÁO CÁO THỰC THI SỬA LỖI (BUG FIX IMPLEMENTATION)
## NHẬT KÝ CHI TIẾT CÁC THAY ĐỔI MÃ NGUỒN, ROOT CAUSE & DIFF CODE

---

### 1. BUG 1: LỖI CHỌN SAI NHÓM ĐỒ ÁN KHI ĐĂNG KÝ ĐỀ TÀI (CRITICAL - P0)
- **Tệp chỉnh sửa:**
  - [topic_detail_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/topic/topic_detail_screen.dart)
  - [topic_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/topic/topic_screen.dart)
- **Nguyên nhân gốc (Root Cause):** Đoạn mã Flutter sử dụng toán tử `foundGroup ?? myGroups.first` để gán nhóm đại diện cho đề tài. Nếu sinh viên có một nhóm cũ ở học phần khác (ví dụ: "Nhóm Demo 02"), nó luôn bị gán làm nhóm đại diện cho đề tài môn mới thay vì nhóm "t".
- **Khắc phục:**
  ```dart
  // TRƯỚC KHI SỬA:
  final myGroup = foundGroup ?? (myGroups.isNotEmpty ? myGroups.first : null);

  // SAU KHI SỬA:
  // Chỉ chọn nhóm thỏa mãn đồng thời: sinh viên là trưởng nhóm VÀ thuộc cùng lớp học phần / đợt đăng ký
  NhomDoAn? validGroup;
  try {
    validGroup = myGroups.firstWhere(
      (g) => g.dotDangKyId == widget.topic.dotDangKyId && g.isLeader,
    );
  } catch (_) {
    validGroup = null;
  }
  ```

---

### 2. BUG 2: RACE CONDITION / TRANSACTIONS TRONG ĐĂNG KÝ ĐỀ TÀI (CRITICAL - P0)
- **Tệp chỉnh sửa:** [DeTaiController.cs](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/DeTaiController.cs)
- **Nguyên nhân gốc:** Thiếu transaction cô lập và thiếu kiểm tra trùng lặp bản ghi đăng ký đang chờ duyệt trong DB.
- **Khắc phục:**
  ```csharp
  // Bổ sung mức cô lập Serializable và kiểm tra tồn tại đăng ký
  using var transaction = await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
  
  var existingActiveRegistration = await _db.DangKyDeTais.AnyAsync(r =>
      r.DeTaiId == request.DeTaiId &&
      (r.TrangThai == "Chờ duyệt" || r.TrangThai == "Đã duyệt"));

  if (existingActiveRegistration)
  {
      await transaction.RollbackAsync();
      return Conflict(new { message = "Đề tài này đã có nhóm đăng ký và đang được xử lý." });
  }
  ```

---

### 3. BUG 3: LỖ HỔNG KÍCH THƯỚC AVATAR UPLOAD (HIGH - P1)
- **Tệp chỉnh sửa:** [ProfileController.cs](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/Controllers/ProfileController.cs)
- **Nguyên nhân gốc:** Kiểm tra kích thước chuỗi base64 thay vì kích thước byte nhị phân thực tế sau khi giải mã.
- **Khắc phục:**
  ```csharp
  byte[] imageBytes = Convert.FromBase64String(cleanBase64);
  if (imageBytes.Length > 10 * 1024 * 1024)
  {
      return BadRequest(new { message = "Ảnh đại diện không được vượt quá 10MB." });
  }
  ```

---

### 4. BUG 4: LỖI BIÊN DỊCH VÀ THIẾU THÀNH VIÊN TRONG FRONTEND (HIGH - P1)
- **Tệp chỉnh sửa:**
  - [training_add_form_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/training_department/training_add_form_screen.dart)
  - [api_service.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/api_service.dart)
- **Khắc phục:**
  - Sửa `void _save()` thành `Future<void> _save() async`.
  - Thêm hằng số `static const String currentCloudflareUrl = 'https://pub-394dab3d868e4d68b09fbd3349573541.r2.dev';`.

---

### 5. BUG 5: CẬP NHẬT SỐ ĐIỆN THOẠI TRONG PROFILE SCREEN (MEDIUM - P2)
- **Tệp chỉnh sửa:** [profile_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/profile/profile_screen.dart)
- **Khắc phục:** Thêm dialog chỉnh sửa số điện thoại và gọi API `PUT /api/profile`.

---

### 6. BUG 6: ÁNH XẠ DỮ LIỆU STATS TRONG ADMIN OVERVIEW (MEDIUM - P2)
- **Tệp chỉnh sửa:** [admin_overview_screen.dart](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/admin/admin_overview_screen.dart)
- **Khắc phục:** Chuẩn hóa ánh xạ role key từ API (`ADMIN`, `SINHVIEN`, `GIANGVIEN`).
