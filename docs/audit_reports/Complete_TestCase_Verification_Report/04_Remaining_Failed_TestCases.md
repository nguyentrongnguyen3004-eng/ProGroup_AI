# BÁO CÁO 04: DANH SÁCH TEST CASE CHƯA ĐẠT VÀ ĐẠT MỘT PHẦN (FAIL & PARTIAL PASS)

## 1. TỔNG QUAN
- **Số lượng Test Case chưa đạt (FAIL):** 6 / 200 Test Cases (3.0%)
- **Số lượng Test Case đạt một phần (PARTIAL PASS):** 18 / 200 Test Cases (9.0%)
- **Nguyên tắc báo cáo:** Phản ánh trung thực 100% tình trạng kỹ thuật thực tế của hệ thống. Không bao che lỗi, không hạ thấp tiêu chí kiểm thử để chạy theo số liệu.

---

## 2. CHI TIẾT 6 TEST CASE CHƯA ĐẠT (FAIL)

| Mã TC | Phân hệ | Chức năng kiểm thử | Nguyên nhân kỹ thuật gốc (Root Cause) | Mức độ nghiêm trọng | Giải pháp đề xuất |
|:---|:---|:---|:---|:---:|:---|
| `TC_NFR_007` | Phi chức năng | Hiệu năng mạng 3G giả lập (< 3s) | Khi tải danh sách người dùng lớn (>250 bản ghi) qua mạng 3G giả lập có độ trễ RTT cao, thời gian phản hồi đạt ~6.2s do API chưa phân trang `take/skip` trên giao diện người dùng. | Trung bình | Bổ sung phân trang `Pagination` (trang 20-50 items) cho các màn hình danh sách lớn. |
| `TC_NFR_010` | Phi chức năng | Hiển thị trạng thái Offline trên mọi màn hình | Giao diện quản lý chi tiết giảng viên của phân hệ Giáo vụ chưa gắn listener kiểm tra `ConnectivityResult.none`, dẫn đến giao diện giữ vòng xoay loading khi mất mạng. | Thấp | Bổ sung widget `OfflineBanner` dùng chung cho toàn bộ các màn hình con. |
| `TC_STU_048` | Sinh viên | Đánh giá chéo thành viên nội bộ nhóm (Peer Review) | CSDL hiện tại chưa có bảng `DanhGiaThanhViens` để lưu trữ điểm số và nhận xét chéo giữa các thành viên cùng nhóm đồ án. | Trung bình | Tạo bảng CSDL mới `DanhGiaThanhViens (DanhGiaId, NhomId, NguoiDanhGiaId, NguoiDuocDanhGiaId, Diem, NhanXet, CreatedAt)`. |
| `TC_LEC_026` | Giảng viên | Tích hợp quét trùng lặp đạo văn đồ án bên ngoài | Hệ thống hiện chỉ hỗ trợ AI phân tích độ tương đồng đề tài nội bộ; chưa có hợp đồng API và webhook kết nối với dịch vụ quét đạo văn bên thứ ba như Turnitin / Copyleaks. | Thấp | Xây dựng Service adapter tích hợp API quét văn bản bên thứ ba khi có kinh phí license. |
| `TC_PDT_013` | Phòng đào tạo | Thuật toán tự động xếp lịch bảo vệ đồ án tối ưu | Chức năng xếp lịch bảo vệ hiện yêu cầu cán bộ Phòng đào tạo gán phòng và thời gian thủ công; chưa có module thuật toán tối ưu hóa ràng buộc phòng/ca thi. | Trung bình | Xây dựng thuật toán xếp lịch (Constraint Satisfaction Problem - CSP) trong giai đoạn 2. |
| `TC_ADM_020` | Quản trị | Cron Job sao lưu CSDL tự động trong Web API | Web API chưa cấu hình Background Service `IHostedService` chạy định kỳ lúc 00:00 hàng ngày để gọi lệnh backup CSDL; hiện phụ thuộc vào SQL Server Agent cấu hình ngoài server. | Trung bình | Thêm một `BackgroundService` chạy lệnh `BACKUP DATABASE` định kỳ vào thư mục sao lưu được chỉ định. |

---

## 3. CHI TIẾT 18 TEST CASE ĐẠT MỘT PHẦN (PARTIAL PASS)

> [!NOTE]
> Các Test Case dưới đây đã hoạt động tốt về mặt logic cốt lõi và nghiệp vụ Backend, nhưng cần bổ sung giao diện tương tác chuyên sâu hoặc tối ưu hóa trải nghiệm người dùng (UX).

1. `TC_STU_031` (Tư vấn đề tài AI): Backend API Gemini hoạt động tốt, sinh gợi ý chuẩn; tuy nhiên UI chưa có khung chat tương tác nhiều lượt (Multi-turn conversational chat) như ChatGPT, hiện tại hiển thị danh sách thẻ gợi ý tĩnh.
2. `TC_PDT_006` (Biểu đồ Gantt tiến độ toàn trường): Dữ liệu mốc thời gian hiển thị đầy đủ dưới dạng danh sách mốc thẻ; cần nâng cấp lên thư viện đồ họa Gantt Chart tương tác để trực quan hóa hơn.
3. `TC_STU_039` (Tin nhắn nhóm Offline): Tin nhắn gửi khi mất mạng được lưu vào local SQLite/SharedPreferences của thiết bị; tuy nhiên khi có mạng trở lại, cơ chế giải quyết xung đột (conflict resolution) giữa nhiều thiết bị dùng quy tắc Last-Write-Wins đơn giản.
4. `TC_STU_040` (Tải tệp đính kèm khi mạng chập chờn): Chưa hỗ trợ tải ngắt quãng (Resume download chunked range header) nếu tệp vượt quá 50MB.
5. `TC_LEC_013` (Giao diện chấm điểm đồ án theo Rubric): Đã chấm điểm từ 0 đến 10 và lưu nhận xét thành công; UI mobile hiện gộp thành một thanh điểm tổng thay vì hiển thị ma trận từng tiêu chí nhỏ.
6. `TC_LEC_014` (Xuất bảng điểm ra Excel/PDF): Endpoint Backend xuất dữ liệu dạng CSV/JSON chuẩn; cần bổ sung template định dạng biểu mẫu hành chính in ấn PDF trực tiếp từ mobile.
7. `TC_GVK_012` (Xuất báo cáo khoa dạng Excel): File xuất dạng CSV tương thích Excel, cần mở bằng Excel chọn phân cách dấu phẩy để hiển thị chuẩn bảng tính.
8. `TC_GVK_013` (Thống kê phân bổ đề tài theo bộ môn): Hiển thị dạng danh sách thẻ số liệu; cần bổ sung biểu đồ tròn (Pie Chart) trực quan trên dashboard.
9. `TC_ADM_016` (Sao lưu hệ thống từ Admin UI): Đã có script SQL backup; cần tài khoản SQL Server quyền SYSADMIN khi triển khai môi trường thực tế.
10. `TC_ADM_017` (Khôi phục dữ liệu hệ thống): Yêu cầu ngắt kết nối các session đang hoạt động trước khi restore CSDL.
11. `TC_STU_044` (Đồng bộ Google Calendar): Cần cấp quyền OAuth cá nhân của sinh viên; hiện tại sử dụng lịch nội bộ của ứng dụng.
12. `TC_STU_053` (Tìm kiếm đồng đội theo kỹ năng): Backend API đã hỗ trợ tìm kiếm theo chuyên môn; giao diện frontend cần thêm thanh lọc đa lựa chọn bằng Chip.
13. `TC_LEC_022` (Nhắc nhở nộp bài tự động): Đã gửi thông báo đẩy trong ứng dụng; chưa kích hoạt cổng gửi tin nhắn SMS viễn thông.
14. `TC_LEC_025` (Xem trước file nộp đồ án): Xem trước trực tiếp mượt mà các file định dạng ảnh/PDF nhẹ; file Office Word/Zip cần tải về máy để mở bằng ứng dụng ngoài.
15. `TC_PDT_008` (Cảnh báo lớp có tỷ lệ rớt cao): Đang áp dụng ngưỡng cố định 20% học viên chưa có nhóm; cần hỗ trợ cấu hình động ngưỡng phần trăm theo từng khoa.
16. `TC_PDT_016` (Duyệt mở đợt đăng ký bổ sung): Hoạt động chuẩn; cần bổ sung thêm cấp phê duyệt trung gian của Trưởng khoa trước khi Phòng đào tạo công bố.
17. `TC_ADM_006` (Thước đo độ mạnh mật khẩu): Backend đã kiểm tra độ phức tạp nghiêm ngặt; UI màn hình Đổi mật khẩu cần vẽ thêm thanh màu trực quan (Yếu/Trung bình/Mạnh).
18. `TC_ADM_022` (Xuất nhật ký hệ thống ra SIEM): Nhật ký lưu đầy đủ IP và thời gian trong CSDL; chưa hỗ trợ đẩy log trực tiếp qua giao thức Syslog ra các hệ thống SIEM ngoài.