# 11. CÁC HẠNG MỤC TỒN ĐỌNG VÀ KẾ HOẠCH NÂNG CẤP (FUTURE ROADMAP)

Dưới đây là danh sách 17 hạng mục được phân loại NOT FIXED trong phạm vi kiểm thử hiện tại, giải thích kỹ thuật và khuyến nghị triển khai:

### 1. Nhóm Tính Năng Trí Tuệ Nhân Tạo (Gemini AI Dự Báo Học Vụ)
- **Các Test Case**: `TC_GVK_019`, `TC_PDT_011`, `TC_PDT_012`, `TC_PDT_013`.
- **Hiện trạng**: Ứng dụng hiện đã tích hợp thành công Gemini AI trong vai trò Trợ lý đề tài sinh viên (AiTopicScreen) và Chatbot hỗ trợ học tập. Tuy nhiên, module AI dự báo xu hướng đăng ký và khối lượng học vụ cho cán bộ cấp Khoa/Trường cần kết nối cơ sở dữ liệu thống kê nhiều năm và hiện chưa có endpoint Backend riêng.
- **Kế hoạch**: Xây dựng controller `AiAnalyticsController.cs` và tích hợp Gemini Flash 1.5 với Prompt chuyên biệt cho phân tích dữ liệu học vụ trong Sprint tiếp theo.

### 2. Nhóm Báo Cáo Phân Cấp & Biểu Đồ Thống Kê Nâng Cao
- **Các Test Case**: `TC_GVK_013`, `TC_PDT_002`, `TC_PDT_006`, `TC_PDT_010`, `TC_PDT_016`.
- **Hiện trạng**: Cần bổ sung thêm bảng `BoMon` trong CSDL SQL Server và tích hợp thư viện vẽ biểu đồ phân phối điểm (Gaussian Curve / Box Plot).
- **Kế hoạch**: Bổ sung bảng và xây dựng giao diện thống kê tương ứng.

### 3. Nhóm Tự Động Hóa Thông Báo Đẩy (Push Notifications)
- **Các Test Case**: `TC_GVK_022`, `TC_PDT_017`.
- **Hiện trạng**: Hệ thống thông báo in-app đã hoạt động tốt qua bảng `ThongBaos`. Việc kích hoạt thông báo tức thì khi có giảng viên mới hoặc có đợt đăng ký mới cần gắn thêm Event Handler vào các trigger tương ứng.
