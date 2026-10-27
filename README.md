# 🎓 ProGroup AI - Hệ thống Đăng ký & Quản lý Đề tài Đồ án Tích hợp AI

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![ASP.NET Core](https://img.shields.io/badge/ASP.NET%20Core-10.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com)
[![SQL Server](https://img.shields.io/badge/Database-SQL%20Server-CC292B?logo=microsoftsqlserver)](https://www.microsoft.com/sql-server)
[![Google Gemini](https://img.shields.io/badge/AI-Google%20Gemini-8E75C2?logo=google)](https://ai.google.dev/)
[![Material Design 3](https://img.shields.io/badge/UI-Material%20Design%203-757575?logo=materialdesign)](https://m3.material.io/)

**ProGroup AI** là hệ thống toàn diện hỗ trợ sinh viên, giảng viên và các phòng ban quản lý đề tài đồ án môn học, đồ án tốt nghiệp một cách thông minh, chuẩn hóa và minh bạch. Ứng dụng tích hợp trí tuệ nhân tạo **Google Gemini AI**, được xây dựng trên nền tảng ứng dụng di động **Flutter** và máy chủ dịch vụ **ASP.NET Core Web API**, kết nối cơ sở dữ liệu **Microsoft SQL Server**.

---

## 🌟 Điểm nổi bật & Tính năng cốt lõi

### 1. 🤖 Trí tuệ Nhân tạo (Google Gemini AI)
- **Tư vấn & Gợi ý đề tài chuyên sâu**: Sinh viên và giảng viên lựa chọn học phần, lĩnh vực nghiên cứu, công nghệ mục tiêu, nền tảng mong muốn và **tùy chỉnh số lượng đề tài cần AI tạo (1, 2, 3, 5, 10 đề tài)**.
- **Phân tích học vụ & Dự báo đào tạo**: Hỗ trợ Giáo vụ khoa và Phòng đào tạo phân tích khối lượng giảng dạy, dự báo xu hướng công nghệ đề tài và nhu cầu phân bổ nhân lực.

### 2. ⚡ Kết nối Thông minh & Tự động Nhận diện Máy chủ (Auto-Detect)
- **Không cần cấu hình thủ công**: Khi khởi chạy ứng dụng, hệ thống tự động kiểm tra và kết nối nhanh (ping 2 giây) với địa chỉ máy chủ khả dụng ưu tiên:
  - Cầu nối USB tốc độ cao (`http://127.0.0.1:5094` qua ADB Reverse).
  - Mạng Wi-Fi nội bộ LAN (`http://192.168.x.x:5094`).
  - Địa chỉ máy ảo Android Emulator (`http://10.0.2.2:5094`).
- **Giao diện tinh gọn, chuyên nghiệp**: Nút cấu hình máy chủ đã được ẩn khỏi màn hình Đăng nhập để tăng tính thẩm mỹ; tích hợp lối tắt ngầm cho Nhà phát triển bằng cách nhấn giữ vào biểu tượng logo ứng dụng.

### 3. 👤 Trải nghiệm Cá nhân hóa & Lưu trữ Trạng thái
- **Đồng bộ Avatar theo thời gian thực**: Ảnh đại diện được quản lý độc lập theo từng tài khoản, lưu trữ an toàn trên máy chủ và cập nhật tức thì trên trang chủ (*"Xin chào, [Họ tên]"*).
- **Ghi nhớ cấu hình người dùng**: Tự động lưu trữ giao diện (Sáng/Tối), ngôn ngữ (Tiếng Việt/Tiếng Anh) và trạng thái thông báo qua `SharedPreferences`, đảm bảo giữ nguyên cài đặt khi mở lại ứng dụng.
- **Quản lý Thông báo hai chiều**: Đồng bộ trạng thái đã đọc/chưa đọc trực tiếp với cơ sở dữ liệu Backend.

---

## 👥 Ma trận Phân hệ & Chức năng theo Vai trò

| Vai trò | Chức năng chính |
| :--- | :--- |
| **🎓 Sinh viên** | • Tra cứu danh sách lớp học phần và thông tin giảng viên phụ trách.<br>• Quản lý nhóm đồ án (xem thành viên, đổi tên nhóm thời gian thực).<br>• Đăng ký đề tài từ danh sách giảng viên công bố.<br>• Đề xuất đề tài cá nhân/nhóm gửi giảng viên phê duyệt.<br>• Nộp báo cáo tiến độ định kỳ theo từng giai đoạn.<br>• Trợ lý AI Gemini tư vấn đề tài đồ án chuyên sâu với tùy chọn số lượng.<br>• Nhận thông báo tự động khi có cập nhật trạng thái duyệt đề tài. |
| **👨‍🏫 Giảng viên** | • Quản lý các lớp học phần được phân công và mở đợt đăng ký.<br>• Quản lý ngân hàng đề tài đồ án, tạo mới và chỉnh sửa đề tài.<br>• Phê duyệt hoặc từ chối đơn đăng ký đề tài của các nhóm sinh viên.<br>• Phê duyệt và phản hồi các đề tài do sinh viên tự đề xuất.<br>• Theo dõi, đánh giá và chấm điểm báo cáo tiến độ theo cột mốc.<br>• Thống kê trực quan tình hình đăng ký và tiến độ của các nhóm. |
| **🏛️ Giáo vụ khoa** | • Quản lý danh mục lớp học phần toàn khoa.<br>• Phân công giảng viên phụ trách các lớp học phần.<br>• Theo dõi tiến độ đăng ký đề tài và danh sách sinh viên, giảng viên.<br>• Trợ lý AI Gemini phân tích khối lượng học vụ khoa. |
| **🏫 Phòng đào tạo** | • Giám sát dữ liệu đào tạo toàn trường.<br>• Quản lý cấu hình kỳ học, lớp học phần và đợt đăng ký.<br>• AI dự báo khối lượng đào tạo và phân bổ nguồn lực. |
| **🛡️ Quản trị viên (Admin)** | • Quản lý tài khoản toàn hệ thống (Kích hoạt / Khóa tài khoản, đặt lại mật khẩu).<br>• **Import người dùng hàng loạt từ file Excel (.xlsx) hoặc CSV** kèm file mẫu chuẩn.<br>• Thống kê phân bổ vai trò với **biểu đồ thanh ngang (Role Distribution Chart)** trực quan.<br>• Giám sát hoạt động và thông số vận hành hệ thống. |

---

## 💻 Yêu cầu Môi trường Cài đặt (Prerequisites)

Trước khi tiến hành cài đặt, hãy đảm bảo máy tính của bạn đã được cài đặt các công cụ sau:

1. **Backend**:
   - [.NET SDK](https://dotnet.microsoft.com/download) phiên bản **10.0** (hoặc tối thiểu **8.0+**).
   - [Microsoft SQL Server](https://www.microsoft.com/sql-server) (2019 trở lên hoặc SQL Server Express / LocalDB).
   - [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/sql/ssms/download-sql-server-management-studio-ssms) hoặc Azure Data Studio để quản trị CSDL.
2. **Frontend**:
   - [Flutter SDK](https://flutter.dev/docs/get-started/install) phiên bản **3.x+** (kèm Dart SDK 3.x+).
   - [Android Studio](https://developer.android.com/studio) & Android SDK (đã cài đặt `Android SDK Platform-Tools` bao gồm `adb`).
   - Thiết bị chạy thử: Điện thoại Android thật (đã bật chế độ *Gỡ lỗi USB / USB Debugging*) hoặc Máy ảo Android (Android Emulator).

---

## 🛠️ Hướng dẫn Cài đặt & Khởi chạy Chi tiết

### Bước 1: Chuẩn bị Cơ sở dữ liệu (Database Setup)

1. Mở **SQL Server Management Studio (SSMS)** và kết nối tới máy chủ SQL Server của bạn.
2. Tạo cơ sở dữ liệu có tên `ProjectRegistrationDB`:
   ```sql
   CREATE DATABASE ProjectRegistrationDB;
   ```
3. Chạy nội dung script khởi tạo cấu trúc và dữ liệu mẫu tại đường dẫn [scripts/database_schema.sql](file:///scripts/database_schema.sql) (hoặc restore file sao lưu mới nhất trong thư mục `backups/`).
4. Kiểm tra cấu hình chuỗi kết nối trong file:
   `ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API/appsettings.json`:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=localhost;Database=ProjectRegistrationDB;Trusted_Connection=True;TrustServerCertificate=True;"
   }
   ```
   *(Tùy chỉnh `Server`, `User Id`, `Password` sao cho khớp với môi trường SQL Server trên máy bạn).*

---

### Bước 2: Khởi chạy Backend API (ASP.NET Core)

1. Mở cửa sổ **Terminal** (PowerShell hoặc Command Prompt).
2. Di chuyển đến thư mục dự án Backend API:
   ```bash
   cd ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API
   ```
3. Khôi phục các gói phụ thuộc NuGet (nếu cần):
   ```bash
   dotnet restore
   ```
4. Khởi chạy máy chủ Backend:
   ```bash
   dotnet run --urls=http://0.0.0.0:5094
   ```
5. **Kiểm tra hoạt động**:
   - Mở trình duyệt và truy cập: `http://localhost:5094/api/health`
   - Phản hồi dạng JSON trạng thái khỏe mạnh (`Healthy`) xác nhận Backend đã sẵn sàng phục vụ.
   - Tài liệu API tương tác (Swagger UI): `http://localhost:5094/swagger` (ở chế độ Development).

---

### Bước 3: Khởi chạy Ứng dụng Di động Frontend (Flutter)

1. Mở một cửa sổ **Terminal** mới.
2. Di chuyển đến thư mục dự án Flutter Frontend:
   ```bash
   cd ProGroup_AI_Frontend/progroup_ai_frontend
   ```
3. Tải về và cài đặt các thư viện dependencies:
   ```bash
   flutter pub get
   ```
4. Kiểm tra danh sách thiết bị khả dụng (điện thoại thật hoặc máy ảo):
   ```bash
   flutter devices
   ```
5. Khởi chạy ứng dụng lên thiết bị:
   ```bash
   flutter run
   ```
   *(Nếu bạn có nhiều thiết bị, chỉ định thiết bị cụ thể bằng cờ `-d <device_id>`, ví dụ: `flutter run -d 3B1615003E300000`)*.

> [!TIP]
> Nếu bạn muốn đóng gói file cài đặt APK để cài thủ công vào điện thoại, thực hiện lệnh:
> ```bash
> flutter build apk --debug
> ```
> File APK đầu ra sẽ nằm tại: `build/app/outputs/flutter-apk/app-debug.apk`.

---

### Bước 4: Thiết lập Kết nối giữa Điện thoại và Máy chủ

Để ứng dụng di động trên điện thoại có thể giao tiếp trơn tru với Backend trên máy tính, bạn có thể lựa chọn 1 trong 2 phương thức:

#### Cách 1: Kết nối qua cáp USB bằng ADB Reverse (Khuyên dùng - Nhanh & Ổn định nhất)
1. Cắm cáp USB nối điện thoại với máy tính và chọn chế độ truyền tệp/gỡ lỗi.
2. Đảm bảo điện thoại đã bật **Tùy chọn cho nhà phát triển (Developer Options)** và kích hoạt **Gỡ lỗi qua USB (USB Debugging)**.
3. Thiết lập cầu nối mạng ngược cổng 5094 từ máy tính sang điện thoại bằng lệnh:
   ```bash
   adb reverse tcp:5094 tcp:5094
   ```
   *(Hoặc nhấp đúp chạy trực tiếp script [scripts/connect_usb.bat](file:///scripts/connect_usb.bat)).*
4. Lúc này, ứng dụng trên điện thoại sẽ kết nối trực tiếp đến Backend qua `http://127.0.0.1:5094` với tốc độ tức thì và độ trễ gần như bằng 0.

#### Cách 2: Kết nối qua mạng Wi-Fi nội bộ (LAN)
1. Đảm bảo máy tính và điện thoại cùng kết nối vào **chung một mạng Wi-Fi**.
2. Tìm địa chỉ IP nội bộ của máy tính bằng lệnh `ipconfig` (ví dụ: `192.168.1.109`).
3. Mở trình duyệt trên điện thoại truy cập thử: `http://192.168.1.109:5094/api/health`. Nếu hiển thị thành công, ứng dụng ProGroup AI sẽ tự động nhận diện và kết nối qua địa chỉ này.

---

### ⚡ Tùy chọn: Khởi động Nhanh Toàn bộ Hệ thống (1-Click Start)
Tại thư mục gốc của dự án, bạn chỉ cần nhấp đúp vào file:
```text
🚀 start_full_system.bat
```
Script tự động này sẽ:
1. Giải phóng cổng 5094 nếu đang có tiến trình cũ chiếm dụng.
2. Tự động sao lưu cơ sở dữ liệu SQL Server sang thư mục `backups/`.
3. Khởi động Backend API tại cổng `http://0.0.0.0:5094`.
4. Tự động kích hoạt cầu nối `adb reverse` cho điện thoại nếu đang cắm dây cáp USB.

---

## 📁 Cấu trúc Thư mục Dự án

```text
ProGroup_AI/
│
├── 🚀 start_full_system.bat          # Script khởi động tự động toàn bộ Backend & ADB Reverse
├── 📄 README.md                      # Tài liệu hướng dẫn tổng quan và triển khai hệ thống
│
├── 📁 backups/                       # Thư mục lưu trữ các bản sao lưu Database SQL Server (.bak)
│
├── 📁 scripts/                       # Các tập lệnh tiện ích hỗ trợ vận hành:
│   ├── connect_usb.bat               # Thiết lập nhanh ADB Reverse qua cáp USB
│   ├── backup_database.ps1           # Script PowerShell tự động sao lưu SQL Server
│   ├── database_schema.sql           # Script cấu trúc bảng và dữ liệu mẫu CSDL
│   ├── build_apk.bat                 # Script đóng gói ứng dụng Flutter APK
│   └── publish_backend.bat           # Script đóng gói Backend Release để triển khai
│
├── 📁 ProGroup_AI_Backend/           # Mã nguồn Backend Web API (ASP.NET Core .NET 10)
│   └── ProGroup_AI/
│       ├── ProGroup_AI.API/         # Dự án Web API chính
│       │   ├── Controllers/         # Auth, Student, Lecturer, Governance, Admin, DeTai, Groups...
│       │   ├── DTOs/                # Data Transfer Objects cho từng module
│       │   ├── Models/              # Thực thể ánh xạ cơ sở dữ liệu Entity Framework
│       │   ├── Data/                # ApplicationDbContext và cấu hình quan hệ bảng
│       │   ├── Services/            # Logic nghiệp vụ, Gemini AI, Email, Token Service
│       │   ├── wwwroot/             # Thư mục phục vụ tệp tĩnh (ảnh đại diện upload...)
│       │   └── appsettings.json     # Cấu hình CSDL SQL Server, JWT, Gemini API Key
│       └── ProGroup_AI.sln          # Visual Studio Solution
│
└── 📁 ProGroup_AI_Frontend/          # Mã nguồn Ứng dụng Di động (Flutter SDK)
    └── progroup_ai_frontend/
        ├── lib/
        │   ├── core/                # Theme, định tuyến (AppRoutes), AppSettings, Localization (Vi/En)
        │   ├── models/              # Model dữ liệu (User, Course, Group, Topic, Notification...)
        │   ├── screens/             # Giao diện người dùng phân theo 5 vai trò (sinh_vien, giang_vien...)
        │   ├── services/            # ApiService, StudentApiService, LecturerApiService, GeminiService...
        │   └── widgets/             # Các widget tái sử dụng (AppButton, AppTextField, Dialogs...)
        ├── android/                 # Cấu hình native Android (Permissions, Gradle, Manifest)
        └── pubspec.yaml             # Khai báo dependencies thư viện Flutter
```

---

## 🔒 Danh sách Tài khoản Kiểm thử Mặc định

Hệ thống được khởi tạo sẵn các tài khoản mẫu cho từng phân hệ vai trò để phục vụ trải nghiệm và chấm đồ án:

| Vai trò | Tên đăng nhập | Mật khẩu | Chú thích |
| :--- | :--- | :--- | :--- |
| **🎓 Sinh viên** | `sv001` | `123456` | Sinh viên tiêu biểu (đã tham gia LHP và nhóm) |
| **👨‍🏫 Giảng viên** | `gv001` | `123456` | Giảng viên phụ trách hướng dẫn đồ án |
| **🏛️ Giáo vụ khoa** | `gvk.demo` | `123456` | Chuyên viên quản lý học vụ cấp khoa |
| **🏫 Phòng đào tạo** | `pdt.demo` | `123456` | Chuyên viên giám sát đào tạo cấp trường |
| **🛡️ Quản trị viên** | `admin.demo` | `123456` | Quản trị viên hệ thống (toàn quyền) |

---

## 👥 Thông tin Tác giả & Bản quyền

- **Sinh viên thực hiện**: Nguyễn Trọng Nguyên
- **Học phần**: Phát triển Ứng dụng Di động
- **Công nghệ chính**: Flutter (Dart) & ASP.NET Core Web API (C#) & Google Gemini AI & Microsoft SQL Server
- **Bản quyền**: © 2026 ProGroup AI. Dự án phục vụ mục đích học tập và nghiên cứu khoa học.
