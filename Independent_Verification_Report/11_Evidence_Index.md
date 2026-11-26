# 11. MỤC LỤC CHỨNG CỨ KIỂM ĐỊNH ĐỘC LẬP (EVIDENCE INDEX)
**Dự án:** ProGroup_AI  
**Mục tiêu:** Tập hợp các tệp tin log, kịch bản kiểm thử, dữ liệu truy vấn và mã chứng minh.  

---

## 1. DANH MỤC TỆP TIN CHỨNG CỨ

1. **Tập tin kịch bản kiểm thử tích hợp Live API:**
   - [scripts/integration_api_tests.py](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/scripts/integration_api_tests.py): Kiểm thử 13 ca kiểm tra bao gồm Authentication, Authorization RBAC, Avatar Size Limit, Concurrency Registration.
   - [integration_test_results.json](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/integration_test_results.json): Kết quả JSON phản hồi thực tế từ Web API.
2. **Tập tin kịch bản kiểm thử 4 luồng E2E:**
   - [scripts/verify_4_e2e_workflows.py](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/scripts/verify_4_e2e_workflows.py): Kiểm thử 4 luồng E2E với token vai trò thực tế.
   - [e2e_verification_results.json](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/e2e_verification_results.json): Kết quả JSON phản hồi của 4 luồng E2E.
3. **Tập tin truy vấn kiểm tra CSDL SQL Server:**
   - [scripts/check_integrity2.ps1](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/scripts/check_integrity2.ps1): Kiểm tra phân bổ người dùng (264 users), kiểm tra 0 orphan records, 0 duplicate registrations.
4. **Tập tin trích xuất 200 Test Cases:**
   - [extracted_all_200_tcs.json](file:///D:/TRONGNGUYEN_HK7/PhatTrienUngDungDiDong/ProGroup_AI/extracted_all_200_tcs.json): Toàn bộ 200 kịch bản kiểm thử trích xuất trực tiếp từ file Excel gốc.
5. **Bằng chứng Git Commit:**
   - Commit SHA: `927bf4962cac67315fdc5f1bac8e303862bce38e` (Chứa toàn bộ 144 tệp tin đã khắc phục).
