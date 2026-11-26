# BÁO CÁO 05: DANH SÁCH TEST CASE BỊ CHẶN VÀ CHƯA CHẠY (BLOCKED & NOT RUN)

## 1. TỔNG QUAN
- **Tổng số Test Case bị chặn (BLOCKED):** 8 / 200 Test Cases (4.0%)
- **Số Test Case Chưa Chạy (NOT RUN):** 0 (Toàn bộ 200 Test Cases đều đã được thẩm định và phân loại).
- **Nguyên nhân chính:** Bị giới hạn bởi môi trường máy ảo, tài nguyên phần cứng, thiếu cấu hình OAuth ngoại vi của nhà trường, hoặc các kịch bản đòi hỏi tác động vật lý trên thiết bị thật.

---

## 2. DANH SÁCH CHI TIẾT 8 TEST CASE BỊ CHẶN

| STT | Mã TC | Phân hệ | Tên chức năng | Yếu tố gây chặn (Blocker) | Điều kiện cần để mở chặn (Unblock Criteria) | Quy trình kiểm thử thay thế đã thực hiện |
|:---:|:---|:---|:---|:---|:---|:---|
| 1 | `TC_AUTH_017` | Xác thực | Ngắt kết nối vật lý (rút cáp USB/mạng) khi đang truyền dữ liệu | Máy ảo Android Emulator không hỗ trợ mô phỏng ngắt kết nối phần cứng USB thực tế khi đang debug qua ADB bridge. | Cần thiết bị Android vật lý cắm cáp USB và thực hiện rút cáp trực tiếp trong lúc stream tệp tin lớn. | Đã kiểm thử ngắt kết nối mạng logic thông qua API `WiFi / Data Toggle` và kiểm tra timeout xử lý ở tầng HTTP client. |
| 2 | `TC_STU_042` | Sinh viên | Nhận FCM Push Notification khi ứng dụng bị tắt hoàn toàn (Killed State) | Máy ảo `Pixel_7_Pro_API_34` thiếu Google Play Services image hoặc bộ nhớ máy ảo bị đầy (`INSTALL_FAILED_INSUFFICIENT_STORAGE`). | Thiết bị Android thật có Google Play Services, kết nối mạng Internet công cộng và cấp quyền `POST_NOTIFICATIONS`. | Đã kiểm thử đẩy thông báo qua Firebase Admin SDK trên Backend và nhận thông báo khi ứng dụng đang chạy nền (Background State). |
| 3 | `TC_NFR_009` | Phi chức năng | Kiểm thử tải đồng thời 5000 CCU | Máy chủ kiểm thử là SQL Server Express chạy trên Localhost, bị giới hạn tối đa 1 vCPU và 1GB RAM bộ nhớ đệm Buffer Pool. | Máy chủ Staging / Production chạy SQL Server Standard/Enterprise, tối thiểu 8 vCPU, 32GB RAM, kết nối mạng 1Gbps. | Đã kiểm thử chịu tải đồng thời 100 luồng đa luồng (Threading pool) trên Localhost xác nhận xử lý tốt các race conditions. |
| 4 | `TC_AUTH_025` | Xác thực | Đăng nhập SSO qua Google Workspace trường | Thiếu OAuth Client ID và cấu hình Google Cloud Console được nhà trường ủy quyền chính thức (`@sinhvien.edu.vn`). | Quản trị viên hệ thống của trường cung cấp Google OAuth Client ID & Secret trên Google Cloud Console. | Đã hoàn thiện luồng đăng nhập tài khoản thường qua JWT và chuẩn bị sẵn interface tích hợp OAuth 2.0. |
| 5 | `TC_AUTH_026` | Xác thực | Đăng nhập SSO qua Microsoft Entra ID (Office 365) | Chưa có Azure Tenant ID và Application Registration từ Phòng Công nghệ Thông tin của nhà trường. | Cấu hình Microsoft Identity Platform (MSAL) với Azure Tenant ID và Client ID hợp lệ. | Đã cấu hình kiến trúc xác thực đa nguồn mở rộng trên Backend API. |
| 6 | `TC_AUTH_027` | Xác thực | Đồng bộ tài khoản LDAP / Active Directory nội bộ | Hệ thống mạng nội bộ trường yêu cầu kết nối VPN chuyên dụng và chứng chỉ số bảo mật nội bộ. | Thiết lập đường truyền VPN bảo mật kết nối trực tiếp đến LDAP Server của trường. | Đã xác thực chức năng Import dữ liệu người dùng hàng loạt qua tệp tin Excel/CSV thay thế. |
| 7 | `TC_NFR_016` | Phi chức năng | Quét lỗ hổng bảo mật tự động bằng OWASP ZAP trên domain công khai | Hệ thống đang vận hành trong môi trường phát triển cục bộ (`localhost:5094`), chưa triển khai trên tên miền công cộng có chứng chỉ SSL/TLS. | Triển khai ứng dụng lên môi trường Staging có domain công khai và chứng chỉ HTTPS hợp lệ. | Đã thực hiện kiểm định thủ công toàn bộ các lỗi bảo mật cốt lõi: SQL Injection, IDOR, Token Spoofing, MIME Sniffing. |
| 8 | `TC_AUTH_015` | Xác thực | Đăng nhập bằng sinh trắc học vân tay | Máy ảo Android Emulator không có phần cứng cảm biến vân tay vật lý để quét vân tay thật. | Thiết bị Android vật lý có cảm biến vân tay (Fingerprint hardware sensor). | Đã kiểm tra cơ chế fallback về mã PIN và mật khẩu thiết bị khi cảm biến không khả dụng. |