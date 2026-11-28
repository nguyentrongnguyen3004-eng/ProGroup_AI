# 10. BÁO CÁO KIỂM THỬ TỰ ĐỘNG & TÍCH HỢP (UNIT & INTEGRATION TEST REPORT)
## KẾT QUẢ THỰC THI SCRIPT `scripts/integration_api_tests.py` TRÊN MÔI TRƯỜNG THỰC TẾ

---

### 1. MÔI TRƯỜNG KIỂM THỬ
- **Backend Host:** `http://127.0.0.1:5094`.
- **Database:** Microsoft SQL Server `ProjectRegistrationDB`.
- **Script kiểm thử:** [integration_api_tests.py](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/scripts/integration_api_tests.py).
- **Thời gian chạy kiểm thử:** 26/11/2026 14:23.
- **Tổng số kịch bản:** 13 kịch bản.
- **Kết quả:** **13 / 13 PASSED (100%)**.

---

### 2. KẾT QUẢ CHI TIẾT TỪNG KỊCH BẢN (EVIDENCE LOGS)

| Mã Test Case | Kịch bản kiểm thử | Trạng thái | Mã HTTP | Chi tiết & Minh chứng phản hồi |
|---|---|:---:|:---:|---|
| `TEST_01` | `API_HEALTH_CHECK` | **PASS** | 200 OK | Backend phản hồi healthy: `{"status": "healthy", "timestamp": "..."}` |
| `TEST_02` | `AUTH_STUDENT_LOGIN` | **PASS** | 200 OK | Đăng nhập Sinh viên (`sv001`) thành công, trả về JWT Token hợp lệ |
| `TEST_03` | `AUTH_LECTURER_LOGIN` | **PASS** | 200 OK | Đăng nhập Giảng viên (`gv001`) thành công, trả về JWT Token hợp lệ |
| `TEST_04` | `AUTH_ADMIN_LOGIN` | **PASS** | 200 OK | Đăng nhập Admin (`admin01`) thành công, Role: `ADMIN` |
| `TEST_05` | `AUTH_GIAOVU_LOGIN` | **PASS** | 200 OK | Đăng nhập Giáo vụ khoa (`giaovu01`) thành công, Role: `GIAOVUKHOA` |
| `TEST_06` | `AUTH_DAOTAO_LOGIN` | **PASS** | 200 OK | Đăng nhập Phòng đào tạo (`daotao01`) thành công, Role: `PHONGDAOTAO` |
| `TEST_07` | `AUTH_INVALID_PASSWORD` | **PASS** | 401 Unauth | Nhập sai mật khẩu bị chặn chính xác với HTTP 401 Unauthorized |
| `TEST_08` | `PROFILE_FETCH_STUDENT` | **PASS** | 200 OK | Lấy thông tin cá nhân SV: Trần Minh An, MSSV: SV001 |
| `TEST_09` | `PROFILE_UPDATE_PHONE` | **PASS** | 200 OK | Cập nhật số điện thoại thành công lên DB qua `PUT /api/profile` |
| `TEST_10` | `SECURITY_AVATAR_OVERSIZED` | **PASS** | 400 BadReq | Gửi payload 15MB base64 (> 10MB) bị chặn chính xác với HTTP 400 |
| `TEST_11` | `SECURITY_RBAC_FORBIDDEN` | **PASS** | 403 Forbid | Token sinh viên truy cập API Admin bị máy chủ chặn với HTTP 403 |
| `TEST_12` | `ADMIN_OVERVIEW_DATA` | **PASS** | 200 OK | Thống kê chính xác: 264 Users, 252 SV, 6 GV, 12 LHP, 52 Đề tài, 28 Nhóm |
| `TEST_13` | `CONCURRENCY_TOPIC_LOCK` | **PASS** | 409 Conflict | 2 luồng đồng thời tranh chấp đăng ký đề tài được khóa an toàn |
