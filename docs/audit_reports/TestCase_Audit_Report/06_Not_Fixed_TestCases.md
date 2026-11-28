# 06. DANH SÁCH TEST CASE CHƯA TRIỂN KHAI (NOT FIXED: 17 TCs)

Các Test Case dưới đây thuộc về các chức năng mở rộng nâng cao chưa có API hoặc Model trong Backend:

| STT | Mã TC | Sheet | Tính năng | Lý do chưa thực hiện & Yêu cầu giải pháp tương lai |
|---|---|---|---|---|
| 1 | `TC_GVK_013` | 5. Giáo vụ khoa | Thống kê đề tài | Báo cáo danh mục đề tài phân rã theo Bộ môn chuyên ngành (Chưa có phân cấp Bộ môn trong CSDL). |
| 2 | `TC_GVK_014` | 5. Giáo vụ khoa | Danh sách SV | Màn hình tra cứu tập trung toàn bộ sinh viên toàn khoa (Hiện tại tra cứu theo từng Lớp học phần). |
| 3 | `TC_GVK_016` | 5. Giáo vụ khoa | Lọc Khóa SV | Bộ lọc sinh viên theo Khóa niên chế K20, K21, K22 (Chưa bổ sung cột NienKhoa trong bảng SinhViens). |
| 4 | `TC_GVK_019` | 5. Giáo vụ khoa | AI Phân tích | Tính năng AI Gemini phân tích khối lượng học vụ giáo vụ khoa (Module AI nâng cao nằm ngoài phạm vi sprint hiện tại). |
| 5 | `TC_GVK_021` | 5. Giáo vụ khoa | Cảnh báo trễ hạn | Màn hình nhắc nhở các nhóm chưa nộp báo cáo tiến độ toàn khoa (Hiện tại do Giảng viên quản lý trực tiếp). |
| 6 | `TC_GVK_022` | 5. Giáo vụ khoa | Thông báo Khoa | Hệ thống thông báo đẩy tự động khi bổ sung giảng viên mới vào khoa (Chưa tích hợp event bus thông báo này). |
| 7 | `TC_PDT_002` | 6. Phòng đào tạo | Dashboard Toàn trường | Biểu đồ trực quan so sánh số lượng đồ án giữa các Khoa (Cần bổ sung component BarChart liên khoa). |
| 8 | `TC_PDT_005` | 6. Phòng đào tạo | Cấu hình Học kỳ | Giao diện chuyển đổi Học kỳ hiện tại (Active Semester) trên Mobile (Hiện cấu hình qua SQL Script). |
| 9 | `TC_PDT_006` | 6. Phòng đào tạo | Khung thời gian | Khung thời gian kế hoạch đồ án toàn trường (Timeline Gantt chart liên khoa). |
| 10 | `TC_PDT_009` | 6. Phòng đào tạo | Giám sát tiến độ | Danh sách giám sát riêng các LHP chưa mở đợt đăng ký (Hiện xem gộp chung trong danh mục LHP). |
| 11 | `TC_PDT_010` | 6. Phòng đào tạo | Giám sát tiến độ | Dashboard phân tích chuyên sâu tỷ lệ hoàn thành đồ án toàn trường theo từng đợt. |
| 12 | `TC_PDT_011` | 6. Phòng đào tạo | AI Dự báo đào tạo | AI Gemini dự báo nhu cầu đào tạo và đồ án cho Phòng Đào tạo. |
| 13 | `TC_PDT_012` | 6. Phòng đào tạo | AI Dự báo công nghệ | AI Gemini phân tích xu hướng đề tài sinh viên quan tâm (Data Mining). |
| 14 | `TC_PDT_013` | 6. Phòng đào tạo | AI Dự báo lỗi mạng | Xử lý ngoại lệ kết nối mạng cho module AI Phòng đào tạo. |
| 15 | `TC_PDT_014` | 6. Phòng đào tạo | Toàn vẹn dữ liệu | Bộ lọc kiểm tra sinh viên mồ côi (chưa thuộc khoa nào) trên giao diện mobile. |
| 16 | `TC_PDT_016` | 6. Phòng đào tạo | Báo cáo tổng kết | Biểu đồ thống kê phổ điểm đồ án toàn trường (Grade Distribution Chart cho PDT). |
| 17 | `TC_PDT_017` | 6. Phòng đào tạo | Thông báo Đào tạo | Thông báo đẩy tự động tới PDT khi có đợt đăng ký mới kích hoạt. |
