# 15. CÁC VẤN ĐỀ TỒN ĐỌNG & LỘ TRÌNH TƯƠNG LAI (REMAINING ISSUES & ROADMAP)
## GHI NHẬN MINH BẠCH CÁC TÍNH NĂNG MỞ RỘNG VÀ ĐỀ XUẤT CHO CÁC SPRINT TIẾP THEO

---

### 1. DANH SÁCH 17 TEST CASE CHƯA TRIỂN KHAI (NOT FIXED / FUTURE BACKLOG)
Các tính năng sau đây thuộc về pha phát triển mở rộng trong tương lai:
1. **Module AI Gemini cho Phòng Đào tạo & Giáo vụ khoa (TC_PDT_011, 012, 013, TC_GVK_019):**
   - *Thực trạng:* Hiện tại Gemini AI đã tích hợp hỗ trợ sinh viên gợi ý đề tài trong `AiChatController.cs`. Tuy nhiên, tính năng AI phân tích chuyên sâu xu hướng đào tạo toàn trường cho Ban Giám hiệu/Phòng Đào tạo đang là placeholder UI.
   - *Kế hoạch:* Xây dựng pipeline dữ liệu tổng hợp (ETL) đưa vào Vertex AI / Gemini 1.5 Pro để sinh báo cáo phân tích tự động.
2. **Phân rã Bộ môn chuyên ngành (TC_GVK_013):**
   - *Thực trạng:* CSDL hiện tại phân cấp đến cấp Khoa (`Khoas`), chưa có bảng trung gian `BoMons`.
   - *Kế hoạch:* Tạo Migration bổ sung bảng `BoMons` và liên kết với `GiangViens`.
3. **Biểu đồ Timeline Gantt chart toàn trường (TC_PDT_006):**
   - *Kế hoạch:* Tích hợp thư viện hiển thị biểu đồ tiến độ Gantt chuyên dụng trên Flutter.
4. **Hệ thống Push Notification FCM Production (TC_GVK_022, TC_PDT_017):**
   - *Kế hoạch:* Đăng ký tài khoản Firebase Cloud Messaging Production và cấu hình Service Account JSON để bắn thông báo nền.

---

### 2. LỘ TRÌNH ĐỀ XUẤT PHÁT TRIỂN (NEXT MILESTONES)
- **Giai đoạn 1 (Tuần 1-2):** Triển khai thử nghiệm (Pilot Testing) cho 2 khoa CNTT và KTPM.
- **Giai đoạn 2 (Tuần 3-4):** Hoàn thiện phân cấp Bộ môn và tích hợp FCM Notification đẩy.
- **Giai đoạn 3 (Tháng tiếp theo):** Nâng cấp module AI Gemini dự báo học vụ cho Phòng Đào tạo.
