# -*- coding: utf-8 -*-
"""
Script to generate PROGROUP_AI_WORD_CORRECTIONS.md
"""

corrections_content = """# HƯỚNG DẪN HIỆU CHỈNH CHI TIẾT FILE BÁO CÁO WORD
## DỰ ÁN: PROGROUP AI (FILE: `file_coso_v4_updated.docx`)

Tài liệu này cung cấp các chỉ dẫn hiệu chỉnh chi tiết "trước và sau" (Before & After), vị trí cụ thể và đoạn văn bản thay thế hoàn chỉnh nhằm đưa báo cáo đồ án đạt độ chuẩn xác 100% so với mã nguồn thực tế.

---

## 1. KHẮC PHỤC LỖI LẶP SỐ HIỆU TIÊU ĐỀ (HEADING NUMBERING)

### Hiện tượng lỗi
Tại các trang Chương 4 và Chương 5, người đọc nhìn thấy:
- `4.2. 4.2. Tổ chức cấu trúc mã nguồn`
- `4.2.1. 4.2.1. Cấu trúc mã nguồn Backend (ASP.NET Core Web API)`
- `4.2.2. 4.2.2. Cấu trúc mã nguồn Frontend (Flutter Mobile/Web)`
- `4.3. 4.3. Cài đặt cơ sở dữ liệu và dịch vụ tích hợp`
- `4.3.1. 4.3.1. Cài đặt và cấu hình Cơ sở dữ liệu SQL Server`
- `4.3.2. 4.3.2. Cài đặt dịch vụ đám mây Firebase (FCM & Firestore)`
- `4.3.3. 4.3.3. Cài đặt dịch vụ lưu trữ đối tượng Cloudflare R2`
- `4.4. 4.4. Giao diện và chức năng chính của hệ thống`
- `5.1. 5.1. Kiểm thử hệ thống`
- `5.2. 5.2. Đóng gói và triển khai hệ thống`
- `5.3. 5.3. Đánh giá hệ thống`

### Nguyên nhân kỹ thuật
Style `Heading 2` và `Heading 3` trong mẫu Word đã được cấu hình tính năng đánh số tự động đa cấp (Multilevel List). Khi chèn đoạn văn bản, nếu nội dung truyền vào đã có sẵn tiền tố số gõ tay (ví dụ `"4.2. Tổ chức cấu trúc..."`), Word sẽ tự động ghép số tự động của Style vào đằng trước, dẫn đến việc số hiệu bị hiển thị lặp hai lần (`4.2. 4.2.`).

### Cách xử lý
- **Trong Microsoft Word:** Bôi đen tiêu đề $\rightarrow$ Xóa chuỗi số gõ tay ở đầu dòng, chỉ giữ lại phần tên tiêu đề. Hoặc chọn tiêu đề $\rightarrow$ Trên thanh công cụ Paragraph, click vào biểu tượng **Multilevel List** $\rightarrow$ chọn **None** nếu muốn tự gõ số thủ công.
- **Văn bản chuẩn hóa:**
  - `4.2. Tổ chức cấu trúc mã nguồn`
  - `4.2.1. Cấu trúc mã nguồn Backend (ASP.NET Core Web API)`
  - `4.2.2. Cấu trúc mã nguồn Frontend (Flutter Mobile/Web)`
  - `4.3. Cài đặt cơ sở dữ liệu và dịch vụ tích hợp`
  - `4.3.1. Cài đặt và cấu hình Cơ sở dữ liệu SQL Server`
  - `4.3.2. Cài đặt dịch vụ đám mây Firebase (FCM & Firestore)`
  - `4.3.3. Cài đặt dịch vụ lưu trữ đối tượng Cloudflare R2`
  - `4.3.4. Cài đặt Trí tuệ nhân tạo Google Gemini API`
  - `4.4. Giao diện và chức năng chính của hệ thống`
  - `4.4.1. Phân hệ Dùng chung (Đăng nhập & Xác thực tài khoản)`
  - `4.4.2. Phân hệ Sinh viên & Trưởng nhóm`
  - `4.4.3. Phân hệ Giảng viên`
  - `4.4.4. Phân hệ Giáo vụ Khoa`
  - `4.4.5. Phân hệ Phòng Đào tạo`
  - `4.4.6. Phân hệ Quản trị viên (Admin)`
  - `5.1. Kiểm thử hệ thống`
  - `5.1.1. Mục tiêu và phạm vi kiểm thử`
  - `5.1.2. Bảng ca kiểm thử chi tiết (Test Cases)`
  - `5.1.3. Đánh giá kết quả kiểm thử tích hợp`
  - `5.2. Đóng gói và triển khai hệ thống`
  - `5.2.1. Đóng gói ứng dụng di động (Flutter Mobile Client)`
  - `5.2.2. Triển khai Backend Web API`
  - `5.2.3. Triển khai các dịch vụ đám mây vệ tinh`
  - `5.3. Đánh giá hệ thống`
  - `5.3.1. Ưu điểm của hệ thống`
  - `5.3.2. Hạn chế của hệ thống`
  - `5.3.3. Hướng phát triển trong tương lai`

---

## 2. KHẮC PHỤC LỖI CẤU TRÚC THƯ MỤC BỊ RỚT DÒNG (DIRECTORY TREE WRAPPING)

### Hiện tượng lỗi
Trong khung mã nguồn Mục 4.2.1 và 4.2.2, các dòng chú thích quá dài làm rớt từ đơn xuống dòng mới (`điểm`, `viên`, `Excel/CSV`, `Core`, `ba`), gây xô lệch bố cục và tạo cảm giác thiếu chuyên nghiệp. Ngoài ra, tên các file trong sơ đồ hiện tại là tên giả định bằng tiếng Anh không trùng với mã nguồn thực tế.

### Quy tắc định dạng chuẩn
1. Phông chữ: **Consolas** hoặc **Courier New**, kích thước **8.5 pt**.
2. Giãn dòng: **Single (1.0)** hoặc **1.1**.
3. Khoảng lùi lề trái: **0.1 inch (2.5 mm)**.
4. Độ dài tối đa mỗi dòng: **Không vượt quá 52 ký tự**.

### Nội dung thay thế cho Mục 4.2.1 (Backend)
```text
ProGroup_AI.API/
|-- Controllers/          # 17 bộ điều hướng Web API
|   |-- AuthController.cs        # Xác thực JWT, OTP
|   |-- StudentController.cs     # Sinh viên, nhóm, điểm
|   |-- LecturerController.cs    # Giảng viên, duyệt đề tài
|   |-- LopHocPhanController.cs  # Lớp học phần, phân công
|   |-- DangKyDeTaiController.cs # Đăng ký, xét duyệt đồ án
|   |-- BaoCaoTienDoController.cs# Báo cáo tiến độ nhóm
|   |-- AiController.cs          # Tích hợp Gemini AI
|   |-- AdminController.cs       # Quản trị hệ thống, backup
|-- Data/
|   |-- ApplicationDbContext.cs  # DbContext Entity Framework
|-- Entities/             # 21 lớp thực thể CSDL
|   |-- NguoiDung.cs, VaiTro.cs, Khoa.cs, HocPhan.cs...
|-- Services/             # Xử lý nghiệp vụ chuyên biệt
|   |-- AuthService.cs, JwtService.cs, EmailService.cs
|   |-- FirebaseNotificationService.cs (FCM push)
|   |-- CloudflareR2Service.cs (Quản lý avatar cá nhân)
|   |-- DatabaseAutoBackupService.cs (Sao lưu CSDL)
|-- Program.cs            # Dependency Injection & Pipeline
```

### Nội dung thay thế cho Mục 4.2.2 (Frontend)
```text
progroup_ai_frontend/lib/
|-- constants/            # Hằng số giao diện & API URL
|-- models/               # Model ánh xạ JSON từ Web API
|-- services/             # Lớp dịch vụ mạng & lưu trữ
|   |-- api_service.dart         # HTTP Client kèm JWT Bearer
|   |-- auth_service.dart        # Lưu phiên SharedPreferences
|   |-- chat_storage_service.dart# Firestore lắng nghe tin nhắn
|   |-- firebase_service.dart    # Khởi tạo FCM notification
|   |-- gemini_service.dart      # Gọi API chuẩn hóa đề xuất
|-- screens/              # 80 màn hình theo phân hệ
|   |-- auth/                    # Đăng nhập, quên mật khẩu
|   |-- sinh_vien/               # Đề tài, nhóm, nộp báo cáo
|   |-- giang_vien/              # Phụ trách lớp, chấm đồ án
|   |-- giao_vu/                 # Phân công GV, quản lý LHP
|   |-- phong_dao_tao/           # Đợt đăng ký, Import Excel
|   |-- admin/                   # Phân quyền, Backup CSDL
|   |-- common/                  # Hồ sơ cá nhân, đổi mật khẩu
|-- main.dart             # Điểm khởi chạy ứng dụng
```

---

## 3. LOẠI BỎ 8 BẢNG USE CASE NHÂN BẢN DƯ THỪA TRONG CHƯƠNG 3

### Vị trí lỗi
Chương 3, Mục 3.2.3. Bảng 23 đến Bảng 30 là bản sao chép y hệt của Bảng 15 đến Bảng 22.

### Thao tác xử lý
- Xóa bỏ toàn bộ Bảng 23 đến Bảng 30 và các đoạn văn dẫn nhập lặp lại ở giữa.
- Danh sách 8 bảng giữ lại (Bảng 15 đến Bảng 22):
  - **Bảng 15:** Đặc tả Use Case Xét duyệt đề tài (Giảng viên)
  - **Bảng 16:** Đặc tả Use Case Quản lý sinh viên và giảng viên (Giáo vụ)
  - **Bảng 17:** Đặc tả Use Case Quản lý lớp học phần (Giáo vụ)
  - **Bảng 18:** Đặc tả Use Case Quản lý đợt đăng ký đồ án (Phòng Đào tạo)
  - **Bảng 19:** Đặc tả Use Case Quản lý ngân hàng đề tài (Giảng viên)
  - **Bảng 20:** Đặc tả Use Case Quản lý và Nhập dữ liệu đào tạo (Phòng Đào tạo)
  - **Bảng 21:** Đặc tả Use Case Thống kê và Báo cáo tổng hợp (Giáo vụ & Phòng Đào tạo)
  - **Bảng 22:** Đặc tả Use Case Quản lý tài khoản và Phân quyền người dùng (Admin)

---

## 4. BỔ SUNG BẢNG PHÂN CÔNG CÔNG VIỆC NHÓM (TRANG 6, BẢNG 2)

### Vị trí
Trang 6, Bảng 2: "Bảng theo dõi tiến độ và phân công công việc". Cột "Công việc đảm nhận" và "Mức độ hoàn thành (%)" hiện đang để trống.

### Nội dung điền thay thế

| STT | Họ và tên | MSSV | Công việc đảm nhận | Mức độ hoàn thành (%) | Chữ ký |
| :---: | :--- | :---: | :--- | :---: | :---: |
| 1 | **Nguyễn Trọng Nguyên** | 2001216016 | **Trưởng nhóm:**<br>- Thiết kế kiến trúc tổng thể Client-Server hệ thống ProGroup AI.<br>- Thiết kế lược đồ CSDL SQL Server (chuẩn hóa 21 thực thể).<br>- Lập trình toàn bộ tầng Backend ASP.NET Core 10 Web API (17 Controllers, EF Core ORM).<br>- Cài đặt bảo mật xác thực JWT, mã hóa mật khẩu BCrypt.<br>- Tích hợp các dịch vụ đám mây: Cloudflare R2 (lưu trữ avatar), Firebase FCM (thông báo đẩy) và Google Gemini API.<br>- Viết nội dung báo cáo Chương 3, 4, 5. | 100% | |
| 2 | **Lâm Phượng Vĩ** | 2001216315 | **Thành viên:**<br>- Lập trình toàn bộ ứng dụng di động Frontend bằng Flutter (80 màn hình giao diện).<br>- Xây dựng UI phân hệ Sinh viên, Giảng viên, Giáo vụ Khoa, Phòng Đào tạo và Admin.<br>- Cài đặt phòng chat nhóm thời gian thực qua Cloud Firestore.<br>- Xử lý nghiệp vụ phân tích và đọc tệp Excel/CSV trên thiết bị.<br>- Thực hiện kiểm thử giao diện và quy trình người dùng (E2E testing).<br>- Viết nội dung báo cáo Chương 1, 2. | 100% | |

---

## 5. THAY THẾ CÁC ĐOẠN VĂN LỜI NHẮC BIÊN TẬP (P344, P345, P355)

### Vị trí
Chương 3, Mục 3.2.1 (Mô hình kiến trúc hệ thống).

### Đoạn văn cũ cần xóa
- *P344: "Trình bày mô hình Client - Server của hệ thống ProGroup AI..."*
- *P345: "Nên mô tả rõ các vai trò: - Phân hệ Client: Ứng dụng di động (Flutter) cho Sinh viên... - Phân hệ Server: ASP.NET Core Web API... - Phân hệ Cơ sở dữ liệu: SQL Server..."*
- *P355: "Sơ đồ nên thể hiện 5 thành phần chính: Flutter, ASP.NET Core Web API, SQL Server, Firebase và AI API..."*

### Đoạn văn thay thế hoàn chỉnh
> *"Hệ thống ProGroup AI được xây dựng theo mô hình phân tầng hướng dịch vụ (Service-Oriented Client-Server Architecture). Trong mô hình này, các thành phần được phân định trách nhiệm rõ ràng nhằm tối ưu hóa khả năng mở rộng, bảo trì và bảo mật:
> 
> 1. **Phân hệ Client (Flutter Mobile Application):** Ứng dụng di động đa nền tảng đóng vai trò là giao diện tương tác trực tiếp của người dùng. Ứng dụng tiếp nhận các thao tác từ 5 nhóm tác nhân chính (Sinh viên, Giảng viên, Giáo vụ khoa, Phòng đào tạo và Quản trị viên), thực hiện xác thực và đóng gói yêu cầu gửi về máy chủ thông qua giao thức HTTPS.
> 2. **Phân hệ Server (ASP.NET Core 10 Web API):** Đóng vai trò là cổng xử lý nghiệp vụ trung tâm. Máy chủ Web API tiếp nhận các HTTP Request, giải mã và thẩm định Token JWT, thực thi logic nghiệp vụ, đồng thời điều phối việc truy xuất dữ liệu tới CSDL và các dịch vụ đám mây bên ngoài.
> 3. **Phân hệ Cơ sở dữ liệu (Microsoft SQL Server):** Lưu trữ toàn bộ dữ liệu giao dịch nghiệp vụ cốt lõi có cấu trúc của hệ thống, bao gồm thông tin người dùng, lớp học phần, đề tài đồ án và đợt đăng ký.
> 4. **Các dịch vụ đám mây tích hợp:** Bao gồm Google Firebase Cloud Firestore (quản lý tin nhắn phòng chat nhóm thời gian thực), Firebase Cloud Messaging (phát thông báo đẩy đa kênh tới thiết bị di động), Cloudflare R2 (lưu trữ tệp đa phương tiện với chi phí tối ưu) và Google Gemini API (trợ lý trí tuệ nhân tạo hỗ trợ chuẩn hóa cấu trúc đề tài đồ án)."*

---

## 6. CHUẨN HÓA MỤC 4.3.1 (CƠ SỞ DỮ LIỆU SQL SERVER VÀ ENTITIES)

### Vị trí
Mục 4.3.1 (Trang 80).

### Nội dung cũ cần sửa
Tài liệu cũ mô tả các bảng bằng tiếng Anh: `Users, Roles, Departments, Courses, ClassSections, StudentClasses, LecturerClasses, Groups, GroupMembers, Projects, ProjectProposals, RegistrationPeriods, ProgressReports...` và tên DbContext là `ProjectRegistrationDbContext`.

### Nội dung chuẩn hóa thay thế
> *"Cơ sở dữ liệu của hệ thống mang tên `ProjectRegistrationDB`, được xây dựng trên Microsoft SQL Server và quản trị thông qua ORM Entity Framework Core 10 với lớp ngữ cảnh `ApplicationDbContext`. Hệ thống bao gồm chính xác 21 lớp thực thể (Entities) được chuẩn hóa tiếng Việt, tương ứng với 21 bảng dữ liệu:
> 
> - **Nhóm Quản lý Người dùng & Phân quyền:** `NguoiDung`, `VaiTro`, `PasswordResetOtp`.
> - **Nhóm Đơn vị & Đào tạo:** `Khoa`, `HocKy`, `HocPhan`, `LopHocPhan`, `SinhVien`, `GiangVien`, `PhanCongGiangVien`, `SinhVienLopHocPhan`.
> - **Nhóm Đồ án & Đăng ký:** `DotDangKyDoAn`, `NhomDoAn`, `ThanhVienNhom`, `DeTaiDoAn`, `DangKyDeTai`, `BaoCaoTienDo`.
> - **Nhóm Trí tuệ nhân tạo & Dịch vụ:** `AIRequest`, `ThongBao`, `DotImport`, `LoiImport`.
> 
> Toàn bộ các cột dữ liệu chuỗi có dấu tiếng Việt đều được khai báo kiểu `NVARCHAR` trên CSDL và được cấu hình bộ mã hóa JSON `JavaScriptEncoder.Create(UnicodeRanges.All)` trên Web API để loại bỏ triệt để hiện tượng sai mã hóa ký tự (Mojibake)."*

---

## 7. HIỆU CHỈNH MỤC 2.2.3 VÀ 4.3.3 (DỊCH VỤ CLOUDFLARE R2)

### Vị trí 1: Mục 2.2.3 (P310)
- **Chuỗi cũ:** *"Firebase Cloudflare R2 là dịch vụ lưu trữ đối tượng đám mây..."*
- **Chuỗi sửa:** *"Cloudflare R2 là dịch vụ lưu trữ đối tượng đám mây (Cloud Object Storage) tương thích chuẩn giao thức Amazon S3..."*

### Vị trí 2: Mục 4.3.3 (Cài đặt dịch vụ lưu trữ đối tượng Cloudflare R2)
- **Nội dung chuẩn hóa thay thế:**
> *"Hệ thống tích hợp dịch vụ lưu trữ đám mây Cloudflare R2 thông qua thư viện chuẩn AWSSDK.S3 trên nền tảng ASP.NET Core (`CloudflareR2Service.cs`). Dịch vụ chuyên trách tiếp nhận và quản lý hình ảnh đại diện (Avatar) của người dùng trong toàn hệ thống. Mọi tệp ảnh tải lên đều được tự động băm định danh GUID duy nhất, lưu trữ an toàn trong bucket `progroup-avatars` và phân phối tốc độ cao qua mạng phân phối nội dung (CDN) của Cloudflare với chi phí băng thông 0 đồng (Zero Egress Fees). Đối với các sản phẩm báo cáo đồ án của sinh viên, hệ thống hỗ trợ liên kết trực tiếp tới các nền tảng mã nguồn mở (GitHub/GitLab) và tài liệu trực tuyến của nhóm."*

---

## 8. SỬA CÁC LỖI CHÍNH TẢ VÀ THUẬT NGỮ CỤC BỘ

1. **Đoạn P49 (Lời cảm ơn):**
   - *Cũ:* `Cuối cùng, chúng em xin cảm gia đình, bạn bè và người thân...`
   - *Sửa:* `Cuối cùng, chúng em xin cảm ơn gia đình, bạn bè và người thân...`
2. **Đoạn P204 (Phạm vi đề tài):**
   - *Cũ:* `vi ứng dụng: Áp dụng cho công tác đăng ký nhóm...`
   - *Sửa:* `Phạm vi ứng dụng: Áp dụng cho công tác đăng ký nhóm...`
3. **Đoạn P248 (Kiến trúc RESTful API):**
   - *Cũ:* `...đường dẫn URL.Một số phương thức HTTP...`
   - *Sửa:* `...đường dẫn URL. Một số phương thức HTTP...`
4. **Đoạn P256 (Giới thiệu SQL Server):**
   - *Cũ:* `Microsoft Microsoft SQL Server là hệ quản trị cơ sở dữ liệu...`
   - *Sửa:* `Microsoft SQL Server là hệ quản trị cơ sở dữ liệu...`
5. **Đoạn P365 (Firebase FCM):**
   - *Cũ:* `...thông báo thông qua Firebase 300Cloud Messaging.`
   - *Sửa:* `...thông báo thông qua Firebase Cloud Messaging.`

---

## 9. HƯỚNG DẪN CẬP NHẬT MỤC LỤC VÀ DANH MỤC TRONG MICROSOFT WORD

Sau khi hoàn tất chỉnh sửa các nội dung trên trong file Word, thực hiện các bước sau để làm mới hoàn toàn cấu trúc tài liệu:

1. **Cập nhật Mục lục chính (Table of Contents):**
   - Di chuyển đến trang Mục lục (Trang iii hoặc iv).
   - Click chuột phải vào bất kỳ vị trí nào trong Mục lục $\rightarrow$ chọn **Update Field**.
   - Hộp thoại xuất hiện: Chọn **Update entire table** $\rightarrow$ nhấn **OK**.
   - *Kết quả:* Word sẽ tự động quét và đưa toàn bộ các đề mục của Chương 4 (từ trang 77) và Chương 5 (đến trang 95) vào danh mục.
2. **Cập nhật Danh mục Hình ảnh (List of Figures):**
   - Di chuyển đến trang Danh mục Hình ảnh.
   - Click chuột phải vào danh mục $\rightarrow$ chọn **Update Field** $\rightarrow$ chọn **Update entire table** $\rightarrow$ nhấn **OK**.
   - *Kết quả:* Toàn bộ danh sách 22 hình ảnh thực tế (`Hình 4.1` đến `Hình 4.22`) sẽ xuất hiện đầy đủ kèm số trang tương ứng.
3. **Cập nhật Danh mục Bảng biểu (List of Tables):**
   - Tương tự, click chuột phải vào Danh mục Bảng biểu $\rightarrow$ chọn **Update Field** $\rightarrow$ **Update entire table**.
   - *Kết quả:* Bảng 4.1 và Bảng 5.1 sẽ được bổ sung chính xác vào danh mục.
"""

with open('PROGROUP_AI_WORD_CORRECTIONS.md', 'w', encoding='utf-8') as f:
    f.write(corrections_content)

print("Generated PROGROUP_AI_WORD_CORRECTIONS.md successfully!")
