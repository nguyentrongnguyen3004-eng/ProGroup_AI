# ProGroup AI - Hệ thống Đăng ký & Quản lý Đề tài Đồ án Tích hợp AI

Hệ thống quản lý nhóm và đăng ký đề tài đồ án môn học, đồ án tốt nghiệp ứng dụng công nghệ trí tuệ nhân tạo (Google Gemini AI), hỗ trợ toàn diện các phân hệ: Sinh viên, Giảng viên, Giáo vụ khoa, Phòng đào tạo và Quản trị viên.

---

## 📁 Cấu trúc dự án

```text
ProGroup_AI/
├── ProGroup_AI_Backend/              # Backend Web API (ASP.NET Core .NET 10)
│   └── ProGroup_AI/
│       ├── ProGroup_AI.API/          # Controllers, DTOs, Services, DbContext
│       └── ProGroup_AI.sln           # Visual Studio Solution
└── ProGroup_AI_Frontend/             # Ứng dụng Frontend đa nền tảng (Flutter)
    └── progroup_ai_frontend/
        ├── lib/                      # Clean Architecture UI, Services, Models
        ├── android/                  # Android native project & configurations
        ├── web/                      # Flutter Web configurations
        └── pubspec.yaml              # Dependencies & asset manifests
```

---

## 🚀 Công nghệ sử dụng

### 1. Frontend (Flutter)
- **Framework**: Flutter SDK (Dart 3), hỗ trợ Android, Windows Desktop & Web (Chrome).
- **Trí tuệ nhân tạo**: Tích hợp Google Gemini AI API (tư vấn đề tài, dự báo khối lượng đào tạo, phân tích học vụ).
- **Xác thực & Thông báo**: JWT Token, Firebase Messaging & Realtime Notifications.
- **UI/UX**: Design system hiện đại với Dynamic Gradient, Squircle Icons, Stat Cards & Biểu đồ phân bổ vai trò trực quan.

### 2. Backend (ASP.NET Core)
- **Framework**: ASP.NET Core Web API (.NET 10).
- **Cơ sở dữ liệu**: SQL Server & Entity Framework Core (Code First / Scaffolding).
- **Bảo mật**: JWT Bearer Authentication, Role-based Authorization (5 vai trò), CORS Policy.
- **Tính năng nổi bật**:
  - Quản lý đợt đăng ký, lớp học phần, phân công giảng viên.
  - Quản lý đề tài đồ án, đề xuất đề tài từ sinh viên, kiểm duyệt đề tài.
  - Đăng ký nhóm, duyệt nhóm và quản trị tài khoản hệ thống.

---

## 🛠️ Hướng dẫn cài đặt & khởi chạy

### Khởi chạy Backend (.NET 10)
```bash
cd ProGroup_AI_Backend/ProGroup_AI/ProGroup_AI.API
dotnet restore
dotnet build
dotnet run --urls=http://0.0.0.0:5094
```
*API Base URL*: `http://localhost:5094` (hoặc `http://10.0.2.2:5094` trên Android Emulator).

### Khởi chạy Frontend (Flutter)
```bash
cd ProGroup_AI_Frontend/progroup_ai_frontend
flutter pub get

# Chạy trên trình duyệt Web (Chrome)
flutter run -d chrome

# Chạy trên thiết bị di động Android
flutter run -d <android-device-id>
```

---

## 👥 Nhóm phát triển
- Sinh viên thực hiện: Nguyễn Trọng Nguyên
- Môn học: Phát triển ứng dụng di động
