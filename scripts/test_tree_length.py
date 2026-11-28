backend_compact = [
    "ProGroup_AI.API/",
    "├── Controllers/          # Tiếp nhận HTTP Request (16 bộ)",
    "│   ├── AuthController.cs # Xác thực JWT, OTP, đổi mật khẩu",
    "│   ├── StudentsController.cs  # Hồ sơ sinh viên, nhóm",
    "│   ├── LecturersController.cs # Giảng viên, phân công",
    "│   ├── ClassesController.cs   # Lớp học phần, sĩ số",
    "│   ├── ProjectsController.cs  # Danh mục & đăng ký đề tài",
    "│   ├── ProposalsController.cs # Xét duyệt đề xuất đề tài",
    "│   ├── GroupsController.cs    # Tạo nhóm, mời thành viên",
    "│   ├── ProgressController.cs  # Nộp & chấm báo cáo tiến độ",
    "│   ├── NotificationsController.cs # Thông báo người dùng",
    "│   ├── DataImportController.cs    # Nhập Excel sinh viên/GV",
    "│   ├── AnalyticsController.cs # Thống kê số liệu đào tạo",
    "│   └── AiController.cs   # Cổng giao tiếp Gemini AI",
    "├── Data/                 # DbContext & cấu hình EF Core",
    "├── Models/               # 21 thực thể CSDL SQL Server",
    "├── Services/             # Xử lý nghiệp vụ & Cloud",
    "├── DTOs/                 # DTOs Request/Response",
    "└── Program.cs            # DI Container & Middleware"
]

frontend_compact = [
    "progroup_ai_frontend/lib/",
    "├── constants/            # Cấu hình API, màu sắc, hằng số",
    "├── models/               # Mô hình hóa dữ liệu từ Web API",
    "├── services/             # API Client, Firestore, FCM, R2",
    "├── screens/              # Màn hình giao diện theo vai trò",
    "│   ├── auth/             # Đăng nhập, quên mật khẩu, OTP",
    "│   ├── student/          # Trang chủ SV, nhóm, gợi ý AI",
    "│   ├── lecturer/         # Quản lý lớp, duyệt đề xuất",
    "│   ├── giaovu/           # Phân công GV, quản lý lớp HP",
    "│   ├── pdt/              # Dashboard PĐT, import Excel",
    "│   ├── admin/            # Quản trị tài khoản, sao lưu DB",
    "│   └── chat/             # Phòng chat nhóm thời gian thực",
    "├── widgets/              # Thành phần UI dùng chung",
    "└── main.dart             # Điểm khởi chạy ứng dụng"
]

print("Backend max length:", max(len(l) for l in backend_compact))
for l in backend_compact:
    print(f"{len(l):2d}: {l}")

print("\nFrontend max length:", max(len(l) for l in frontend_compact))
for l in frontend_compact:
    print(f"{len(l):2d}: {l}")
