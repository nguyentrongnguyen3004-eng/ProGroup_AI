# 09. BẢNG TRẠNG THÁI CUỐI CÙNG 200 TEST CASE (FINAL STATUS)
## ĐỐI CHIẾU CHI TIẾT TỪNG SHEET TỪ NGUỒN GOOGLE SHEETS GỐC

---

### 1. TỔNG HỢP TOÀN BỘ 7 SHEETS

```
+---------------------------------------------------------------------------------+
| Sheet Name                | Total TCs | PASSED / FIXED | NOT FIXED (Backlog)   |
+---------------------------+-----------+----------------+-----------------------+
| 1. Xác thực & Phân quyền  |    28     |       28       |          0            |
| 2. Sinh viên & Nhóm       |    57     |       57       |          0            |
| 3. Giảng viên & Hướng dẫn |    30     |       30       |          0            |
| 4. Báo cáo & Tiến độ      |    25     |       25       |          0            |
| 5. Giáo vụ khoa           |    20     |       14       |          6            |
| 6. Phòng đào tạo          |    24     |       13       |         11            |
| 7. Quản trị hệ thống      |    16     |       16       |          0            |
+---------------------------+-----------+----------------+-----------------------+
| TỔNG CỘNG                 |   200     |      183       |         17 (8.5%)     |
+---------------------------------------------------------------------------------+
```

---

### 2. CHI TIẾT CÁC TEST CASES ĐÃ ĐƯỢC XÁC NHẬN VÀ FIX LỖI (183 TCs)
- **Sheet 1 (Auth - 28 TCs):** `TC_AUTH_001` đến `TC_AUTH_028`: Đăng nhập đúng/sai mật khẩu, format email, cấp JWT, timeout token, OTP đổi mật khẩu, phân quyền 5 vai trò. Toàn bộ **PASSED**.
- **Sheet 2 (Student & Group - 57 TCs):** `TC_STU_001` đến `TC_STU_057`: Tạo nhóm, đổi tên nhóm, mời thành viên, duyệt đơn xin gia nhập, rời nhóm, tìm kiếm đề tài, đề xuất đề tài mới, đăng ký đề tài (bao gồm fix lỗi chọn nhầm nhóm đại diện). Toàn bộ **PASSED**.
- **Sheet 3 (Lecturer - 30 TCs):** `TC_LEC_001` đến `TC_LEC_030`: Tạo đề tài mới, duyệt đề xuất sinh viên, chấp nhận/từ chối đăng ký đề tài của nhóm, xem danh sách nhóm hướng dẫn. Toàn bộ **PASSED**.
- **Sheet 4 (Reports - 25 TCs):** `TC_REP_001` đến `TC_REP_025`: Nộp báo cáo định kỳ, đính kèm link tài liệu, giảng viên nhận xét, chấm điểm tiến độ, xem lịch sử phản hồi. Toàn bộ **PASSED**.
- **Sheet 5 (Faculty - 14 TCs Fixed):** `TC_GVK_001` đến `TC_GVK_012`, `TC_GVK_015`, `TC_GVK_017`: Xem thống kê khoa, quản lý lớp học phần, mở đợt đăng ký. Toàn bộ **PASSED**.
- **Sheet 6 (Training - 13 TCs Fixed):** `TC_PDT_001`, `TC_PDT_003`, `TC_PDT_004`, `TC_PDT_007`, `TC_PDT_008`, `TC_PDT_015`, `TC_PDT_018` đến `TC_PDT_024`: Xem danh mục học kỳ, thống kê toàn trường, kiểm tra lớp học phần. Toàn bộ **PASSED**.
- **Sheet 7 (Admin - 16 TCs):** `TC_ADM_001` đến `TC_ADM_016`: Dashboard overview, tạo người dùng, khóa tài khoản, phân quyền, xem log hệ thống. Toàn bộ **PASSED**.

---

### 3. CHI TIẾT 17 TEST CASES CHƯA TRIỂN KHAI (NOT FIXED / OUT OF SCOPE)
1. `TC_GVK_013`: Báo cáo danh mục đề tài phân rã theo Bộ môn chuyên ngành.
2. `TC_GVK_014`: Màn hình tra cứu tập trung toàn bộ sinh viên toàn khoa.
3. `TC_GVK_016`: Bộ lọc sinh viên theo Khóa niên chế K20, K21.
4. `TC_GVK_019`: AI Gemini phân tích khối lượng học vụ giáo vụ khoa.
5. `TC_GVK_021`: Cảnh báo trễ hạn nộp báo cáo tập trung toàn khoa.
6. `TC_GVK_022`: Thông báo đẩy tự động khi bổ sung giảng viên mới.
7. `TC_PDT_002`: Biểu đồ so sánh số lượng đồ án giữa các Khoa trên mobile.
8. `TC_PDT_005`: Giao diện chuyển đổi Học kỳ hiện tại trên mobile.
9. `TC_PDT_006`: Khung thời gian kế hoạch đồ án toàn trường (Gantt chart).
10. `TC_PDT_009`: Danh sách giám sát riêng các LHP chưa mở đợt đăng ký.
11. `TC_PDT_010`: Dashboard phân tích chuyên sâu tỷ lệ hoàn thành đồ án.
12. `TC_PDT_011`: AI Gemini dự báo nhu cầu đào tạo và đồ án cho PDT.
13. `TC_PDT_012`: AI Gemini phân tích xu hướng đề tài sinh viên quan tâm.
14. `TC_PDT_013`: Xử lý ngoại lệ kết nối mạng cho module AI Phòng đào tạo.
15. `TC_PDT_014`: Bộ lọc kiểm tra sinh viên mồ côi (chưa thuộc khoa).
16. `TC_PDT_016`: Biểu đồ thống kê phổ điểm đồ án toàn trường cho PDT.
17. `TC_PDT_017`: Thông báo đẩy tự động tới PDT khi có đợt đăng ký mới kích hoạt.
