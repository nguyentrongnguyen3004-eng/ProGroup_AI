# 🎓 ProGroup AI - Hệ thống Đăng ký & Quản lý Đề tài Đồ án Tích hợp AI

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![ASP.NET Core](https://img.shields.io/badge/ASP.NET%20Core-10.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com)
[![SQL Server](https://img.shields.io/badge/Database-SQL%20Server-CC292B?logo=microsoftsqlserver)](https://www.microsoft.com/sql-server)
[![Google Gemini](https://img.shields.io/badge/AI-Google%20Gemini-8E75C2?logo=google)](https://ai.google.dev/)
[![Cloudflare Tunnel](https://img.shields.io/badge/Network-Cloudflare%20Tunnel-F38020?logo=cloudflare)](https://cloudflare.com)

**ProGroup AI** là giải pháp toàn diện hỗ trợ sinh viên, giảng viên và các phòng ban quản lý đồ án môn học, đồ án tốt nghiệp một cách thông minh, minh bạch và tiện lợi. Ứng dụng tích hợp trí tuệ nhân tạo **Google Gemini AI**, hỗ trợ đa nền tảng (Android Mobile, Web & Windows) và hệ sinh thái máy chủ kết nối trực tuyến toàn cầu.

---

## 🌟 Điểm nổi bật & Tính năng cốt lõi

### 1. 🤖 Trí tuệ Nhân tạo (Google Gemini AI)
- **Tư vấn & Gợi ý đề tài thông minh**: Sinh viên và giảng viên có thể chọn lĩnh vực nghiên cứu, công nghệ mục tiêu, nền tảng mong muốn và **tùy chỉnh số lượng đề tài cần AI tạo (1, 2, 3, 5, 10 đề tài)**.
- **Phân tích học vụ & Dự báo đào tạo**: Hỗ trợ Giáo vụ khoa và Phòng đào tạo phân tích khối lượng giảng dạy, dự báo xu hướng công nghệ đề tài và nhu cầu nhân lực.

### 2. ⚡ Cập nhật ứng dụng tự động 1-Chạm (In-App Auto Update / OTA)
- **Không cần cài lại APK thủ công**: Khi có bản cập nhật mới, App tự động nhận diện thông qua API máy chủ (`GET /api/app/version`) và hiển thị popup thông báo kèm chi tiết thay đổi (*Changelog*).
- **Tải và cài đặt tự động**: Người dùng chỉ cần chạm nút **"Cập nhật ngay"**, ứng dụng sẽ tự động tải APK với thanh tiến trình trực quan và kích hoạt trình cài đặt hệ thống Android (giữ nguyên phiên đăng nhập và dữ liệu người dùng).
- **Phát hành siêu tốc cho Developer**: Chỉ cần nhấp đúp file `publish_update.bat`, hệ thống sẽ tự động tăng số version, build APK, nạp vào máy chủ và đẩy toàn bộ mã nguồn lên GitHub!

### 3. 🌐 Kết nối Trực tuyến Toàn cầu (Cloudflare Tunnel & Auto-Failover)
- **Bất kỳ mạng nào cũng kết nối được**: Tích hợp đường hầm Cloudflare Tunnel bảo mật bằng giao thức HTTPS toàn cầu, cho phép điện thoại sử dụng **4G/5G** hay bất kỳ Wi-Fi nào cũng kết nối được vào máy chủ.
- **Auto-Failover đa kênh**: Client tự động dò tìm địa chỉ Backend khả dụng (Cloudflare HTTPS, Localhost, Wi-Fi LAN hoặc Android Emulator) để đảm bảo không bao giờ bị gián đoạn kết nối.

### 4. 👤 Đồng bộ Avatar Cá nhân Thời gian thực
- **Cá nhân hóa theo từng vai trò**: Avatar hiển thị tại góc trên trang chủ (*"Xin chào, [User]"*) được đồng bộ tự động và độc lập từ hồ sơ cá nhân của từng tài khoản/vai trò, hỗ trợ cập nhật ảnh đại diện tức thì.

---

## 👥 Ma trận Phân hệ & Chức năng theo Vai trò

| Vai trò | Chức năng chính |
| :--- | :--- |
| **🎓 Sinh viên** | • Xem danh sách lớp học phần và giảng viên hướng dẫn.<br>• Quản lý nhóm đồ án (đổi tên nhóm thời gian thực, xem thành viên).<br>• Đăng ký đề tài từ danh sách giảng viên công bố.<br>• Đề xuất đề tài cá nhân/nhóm gửi giảng viên phê duyệt.<br>• Nộp báo cáo tiến độ định kỳ theo từng giai đoạn.<br>• Trợ lý AI Gemini tư vấn đề tài đồ án chuyên sâu.<br>• Nhận thông báo tự động khi có thay đổi trạng thái đăng ký/duyệt. |
| **👨‍🏫 Giảng viên** | • Quản lý lớp học phần được phân công và mở đợt đăng ký.<br>• Quản lý ngân hàng đề tài đồ án, tạo đề tài mới.<br>• Duyệt / Từ chối đăng ký đề tài của các nhóm.<br>• Duyệt / Phản hồi đề tài do sinh viên tự đề xuất.<br>• Theo dõi, đánh giá và chấm điểm báo cáo tiến độ của sinh viên.<br>• Thống kê trực quan tình hình đăng ký và tiến độ đồ án. |
| **🏛️ Giáo vụ khoa** | • Quản lý danh mục lớp học phần toàn khoa.<br>• Phân công giảng viên phụ trách các lớp học phần.<br>• Theo dõi tiến độ đăng ký đề tài và danh sách sinh viên, giảng viên.<br>• Trợ lý AI Gemini phân tích khối lượng học vụ khoa. |
| **🏫 Phòng đào tạo** | • Giám sát dữ liệu đào tạo toàn trường.<br>• Quản lý cấu hình kỳ học, lớp học phần và đợt đăng ký.<br>• AI dự báo khối lượng đào tạo và phân bổ nguồn lực. |
| **🛡️ Quản trị viên (Admin)** | • Quản lý danh sách người dùng toàn hệ thống (Kích hoạt / Khóa tài khoản).<br>• **Import người dùng hàng loạt từ file Excel (.xlsx) / CSV** kèm chức năng tải file mẫu chuẩn.<br>• Đặt lại mật khẩu mặc định an toàn cho người dùng.<br>• **Biểu đồ thanh ngang (Role Distribution Chart)** phân bổ tỷ lệ các vai trò trực quan.<br>• Giám sát nhật ký hoạt động hệ thống. |

---

## 📁 Cấu trúc Thư mục Dự án

```text
ProGroup_AI/
│
├── 🚀 start_full_system.bat      # [1-CLICK] Khởi động toàn bộ Backend API & Cloudflare Tunnel
├── 📦 publish_update.bat          # [1-CLICK] Đóng gói APK mới, nạp vào Server & Push GitHub
├── 📄 publish-update.ps1         # Script PowerShell tự động hóa quy trình phát hành OTA
│
├── 📁 scripts/                   # Thư mục chứa các script công cụ phụ trợ:
│   ├── build_apk.bat             # Build APK thủ công khi cần
│   ├── run_tunnel.bat            # Khởi chạy riêng lẻ đường hầm Cloudflare
│   └── publish_backend.bat       # Đóng gói Backend Release để deploy Hosting
│
├── 📁 tools/                     # Thư mục công cụ hệ thống (cloudflared.exe)
│
├── 📁 ProGroup_AI_Backend/       # Mã nguồn Backend Web API (ASP.NET Core .NET 10)
│   └── ProGroup_AI/
│       ├── ProGroup_AI.API/     # Controllers, DTOs, Services, DbContext, wwwroot
│       │   ├── Controllers/     # Auth, Groups, DeTai, AppVersion, Admin, v.v.
│       │   ├── wwwroot/         # Thư mục phục vụ file tĩnh (avatars, downloads/app-latest.apk)
│       │   └── appsettings.json # Cấu hình Database SQL Server, JWT, Email SMTP
│       └── ProGroup_AI.sln      # Solution Visual Studio
│
└── 📁 ProGroup_AI_Frontend/      # Mã nguồn Ứng dụng Di động (Flutter SDK)
    └── progroup_ai_frontend/
        ├── lib/
        │   ├── core/            # Theme, Routes, Constants, Settings, Localization (Vi/En)
        │   ├── models/          # User, Course, Group, Topic, UpdateInfo models
        │   ├── screens/         # Màn hình giao diện phân theo 5 vai trò (sinh_vien, giang_vien, ...)
        │   ├── services/        # ApiService, AppUpdateService, AuthService, AvatarService, GeminiService
        │   └── widgets/         # Component dùng chung (buttons, text fields, bottom nav, dialogs)
        ├── android/             # Native Android project (FileProvider, Permissions, Desugaring)
        └── pubspec.yaml         # Cấu hình dependencies (ota_update, http, file_picker, excel...)
```

---

## 🛠️ Hướng dẫn Khởi chạy & Sử dụng

### 1. Khởi chạy Hệ thống (Chỉ 1 thao tác)
Tại thư mục gốc của dự án, nhấp đúp vào:
```text
🚀 start_full_system.bat
```
Script sẽ tự động:
1. Khởi động Backend ASP.NET Core API tại cổng `http://0.0.0.0:5094`.
2. Khởi động đường hầm Cloudflare Tunnel với địa chỉ HTTPS công khai kết nối toàn cầu đến điện thoại.

---

### 2. Phát hành Bản cập nhật App mới (Chỉ 1 thao tác)
Mỗi khi bạn hoàn thành chỉnh sửa mã nguồn và muốn phát hành bản cập nhật cho điện thoại:
- Nhấp đúp vào:
  ```text
  📦 publish_update.bat
  ```
- Hoặc mở PowerShell và chạy:
  ```powershell
  .\publish-update.ps1 -Version "1.0.3" -Changelog "• Bổ sung tính năng mới`n• Tối ưu giao diện"
  ```
Hệ thống sẽ **tự động tăng version, biên dịch APK mới, nạp vào thư mục tải về của máy chủ và đồng bộ đẩy mã nguồn lên GitHub**!

---

### 3. Trải nghiệm trên Điện thoại di động
- **Cài đặt lần đầu**: Cài đặt file APK tại `ProGroup_AI_Frontend/progroup_ai_frontend/build/app/outputs/flutter-apk/app-debug.apk` (hoặc tải trực tiếp từ đường link máy chủ).
- **Các lần cập nhật sau**: 
  - Mở app lên: Popup cập nhật tự động xuất hiện.
  - Hoặc vào mục **Cá nhân** > **Thông tin ứng dụng** > bấm **"Kiểm tra bản cập nhật"**.
  - Bấm **"Cập nhật ngay"** để app tự tải và cài đặt đè trong 2 giây mà không mất dữ liệu.

---

## 🔒 Tài khoản Mẫu để Trải nghiệm Hệ thống

| Vai trò | Tên đăng nhập | Mật khẩu | Chú thích |
| :--- | :--- | :--- | :--- |
| **Sinh viên** | `sv001` | `123456` | Sinh viên chính thức |
| **Giảng viên** | `gv001` | `123456` | Giảng viên hướng dẫn |
| **Giáo vụ khoa** | `gvk.demo` | `123456` | Giáo vụ quản lý khoa |
| **Phòng đào tạo** | `pdt.demo` | `123456` | Chuyên viên phòng đào tạo |
| **Quản trị viên** | `admin.demo` | `123456` | Toàn quyền quản trị hệ thống |

---

## 👥 Nhóm Phát triển & Bản quyền
- **Sinh viên thực hiện**: Nguyễn Trọng Nguyên
- **Học phần**: Phát triển Ứng dụng Di động
- **Công nghệ**: Flutter (Dart) & ASP.NET Core Web API (C#) & Google Gemini AI
- **Giấy phép**: Bản quyền thuộc về tác giả - Phát triển phục vụ mục đích học tập và nghiên cứu.
