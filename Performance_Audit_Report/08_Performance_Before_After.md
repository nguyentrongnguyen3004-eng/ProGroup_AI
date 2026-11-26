# 08. Đối chiếu Hiệu năng Trước / Sau Tối ưu (Before vs After)

Toàn bộ số liệu **Before** lấy từ `perf_baseline.py` chạy trực tiếp trên bản API/SQL trước chỉnh sửa; toàn bộ số liệu **After** lấy từ `perf_after.py` chạy trên bản build cuối cùng sau tất cả chỉnh sửa SQL, Backend và Flutter (HTTP 200 cho 30/30 endpoint, bật `Accept-Encoding: gzip`).

---

## 1. Kịch bản Tải Khởi động & Chịu tải Đồng thời (Burst Scenarios)

| Kịch bản | Before (Baseline) | After (Final Build) | Cải thiện thực đo |
| --- | --- | --- | --- |
| **Student Startup Burst** (`StudentMainScreen`) | **10 calls**, `wall = 26,071.55 ms`, `max_call = 25,887.17 ms`, `89,941 B` | **5 calls**, `wall = 83.35 ms`, `max_call = 73.20 ms`, `wire = 7,461 B` (`raw = 27,315 B`) | Thời gian wall giảm **312.8x** (-99.68%), giảm **50%** số API, giảm **91.7%** byte truyền qua mạng |
| **Training/Governance Startup Burst** | **8 calls**, `wall = 76.50 ms`, `max_call = 74.02 ms`, `134,793 B` | **4 calls**, `wall = 61.17 ms`, `max_call = 59.72 ms`, `wire = 6,087 B` (`raw = 26,005 B`) | Giảm **50%** số API, giảm **95.5%** byte truyền wire, `wall` giảm **20.0%** |
| **Stress 10 Concurrent Calls (giống hệt payload burst của Baseline Student)** | `wall = 26,071.55 ms`, `max_call = 25,887.17 ms`, `89,941 B` | `wall = 88.11 ms`, `max_call = 83.35 ms`, `wire = 23,088 B` | **295.9x nhanh hơn** (-99.66%), triệt tiêu hoàn toàn tắc `RESOURCE_SEMAPHORE` |

---

## 2. Đối chiếu Chi tiết 30 Endpoint (5 lần đo/endpoint)

| Endpoint (`Method Path`) | Before Cold (ms) | Before Avg (ms) | After Cold (ms) | After Avg (ms) | After Median (ms) | Raw Bytes | After Wire Bytes (Gzip) | Ghi chú |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `Health` (`/api/health`) | 29.76 | 12.45 | 26.71 | 10.56 | 4.09 | 63 | 89 | Payload siêu nhỏ, header gzip hơn raw |
| `AppVersion` (`/api/app/version`) | 18.91 | 5.83 | 17.17 | 5.52 | 2.84 | 320 | 311 | Ổn định |
| `Profile_SV` (`/api/profile`) | 52.57 | 25.55 | 371.74 | 88.56 | 20.72 | 1,241 | 699 | Cold lần đầu sau boot gồm warmup R2/EF (-43.7% bytes) |
| `Student_Courses` (`/api/student/courses`) | 29.04 | 18.66 | 114.36 | 46.68 | 30.48 | 2,197 | 669 | Giảm 69.5% wire bytes |
| `Student_Groups` (`/api/student/groups`) | **25,093.56** | **9,588.94** | **146.47** | **43.54** | **19.77** | 2,298 | **795** | Thoát hoàn toàn tắc 25 giây (-99.4% cold, -99.5% avg) |
| `Student_Topics` (`/api/student/topics`) | 56.52 | 26.10 | 126.77 | 42.42 | 13.02 | 21,561 | **5,254** | Median 13.02 ms; giảm 75.6% wire bytes |
| `LopHocPhan_All` (`/api/lop-hoc-phan`) | 117.58 | 33.67 | 121.79 | 34.46 | 9.53 | 8,743 | **1,726** | Giảm 80.3% wire bytes |
| `LopHocPhan_Detail_1` (`/api/lop-hoc-phan/1/chi-tiet`) | 183.90 | 46.17 | 94.00 | 25.20 | 8.16 | 44 | 67 | Cold giảm 48.9%, avg giảm 45.4% |
| `LopHocPhan_Semesters` (`/api/lop-hoc-phan/hoc-ky`) | 28.47 | 12.41 | 23.62 | 8.40 | 4.81 | 933 | 266 | Avg giảm 32.3%, wire giảm 71.5% |
| `Groups_All` (`/api/groups`) | 51.46 | 26.21 | 89.82 | 25.87 | 9.82 | 27,109 | **3,625** | Median 9.82 ms; wire giảm **86.6%** |
| `Groups_Mine` (`/api/groups/mine`) | 106.53 | 34.80 | 72.81 | 21.28 | 8.25 | 2,335 | **487** | Cold giảm 31.7%, avg giảm 38.9%, wire giảm 79.1% |
| `DeTai_All` (`/api/de-tai`) | 30.60 *(trước nghẽn; bản giữa bị **25,077.34**)* | 13.14 | **48.05** | **22.23** | **12.00** | 58,367 | **13,981** | Đã bỏ SQL Sort `NVARCHAR(MAX)`, wire giảm **76.0%** |
| `DeTai_CuaToi` (`/api/de-tai/cua-toi`) | 14.11 | 6.33 | 53.49 | 18.70 | 10.04 | 17,581 | **4,300** | Wire giảm 75.5% |
| `DeTai_Proposals` (`/api/de-tai/proposals`) | 55.96 | 23.30 | 56.72 | 22.40 | 10.19 | 4,884 | **1,784** | Wire giảm 63.5% |
| `DangKyDeTai_All` (`/api/dang-ky-de-tai`) | 23.50 | 13.35 | 82.39 | 32.45 | 30.35 | 5,150 | **1,633** | Wire giảm 68.3% |
| `Notifications_SV` (`/api/notifications`) | 131.69 | 50.08 | 180.87 | 59.48 | 35.19 | 17,905 | **4,068** | Wire giảm **77.3%** |
| `Notifications_Unread_SV` (`/api/notifications/unread-count`) | 41.45 | 24.05 | 26.20 | 21.21 | 16.98 | 18 | 44 | Cold giảm 36.8% |
| `Notifications_GV` (`/api/notifications`) | 9.82 | 12.36 | 11.63 | 17.22 | 11.63 | 17,343 | **3,967** | Wire giảm 77.1% |
| `Lecturer_Courses` (`/api/lecturer/courses`) | 123.57 | 101.16 | 113.28 | **28.92** | **7.97** | 2,548 | **801** | Avg giảm **71.4%**, median **7.97 ms** |
| `Lecturer_Statistics` (`/api/lecturer/statistics`) | 135.10 | 67.48 | 57.98 | **24.21** | **10.37** | 135 | 120 | Cold giảm 57.1%, avg giảm **64.1%** |
| `Lecturer_Registrations` (`/api/lecturer/topic-registrations`) | 76.54 | 47.02 | 19.44 | **13.96** | **8.41** | 5,150 | **1,633** | Cold giảm 74.6%, avg giảm **70.3%** |
| `Governance_Courses` (`/api/governance/courses`) | 119.03 | 52.60 | 78.23 | **21.04** | **6.63** | 5,646 | **1,219** | Avg giảm **60.0%**, wire giảm 78.4% |
| `Governance_Students` (`/api/governance/students`) | 47.20 | 26.76 | 50.71 | 26.55 | 30.39 | 64,126 | **8,928** | Wire giảm **86.1%** (252 SV) |
| `Governance_Lecturers` (`/api/governance/lecturers`) | 40.48 | 19.03 | 34.42 | 10.98 | 5.07 | 1,725 | **703** | Avg giảm 42.3%, wire giảm 59.2% |
| `Governance_Assignments` (`/api/governance/assignments`) | 46.37 | 20.12 | 35.46 | 11.40 | 5.45 | 4,015 | **1,025** | Avg giảm 43.3%, wire giảm 74.5% |
| `Admin_Overview` (`/api/admin/overview`) | 389.84 | 148.29 | **185.54** | **56.09** | **31.06** | 997 | **554** | Cold giảm **52.4%**, avg giảm **62.2%** |
| `Admin_Users` (`/api/admin/users`) | 78.48 | 39.60 | 54.27 | 26.74 | 14.62 | 101,154 | **11,785** | Avg giảm 32.5%, wire giảm **88.3%** (264 users) |
| `Admin_ActivityLogs` (`/api/admin/activity-logs`) | 341.47 | 81.27 | **56.46** | **16.25** | **6.29** | 9,670 | **1,955** | Cold giảm **83.5%**, avg giảm **80.0%**, wire giảm **79.8%** |
| `BaoCao_GV` (`/api/bao-cao/giang-vien`) | 103.38 | 48.28 | 50.69 | 20.56 | 13.10 | 4,579 | **2,153** | Avg giảm 57.4%, wire giảm 53.0% |
| `DotDangKy_All` (`/api/dot-dang-ky`) | 58.01 | 28.68 | 40.68 | 20.05 | 18.74 | 5,458 | **1,234** | Avg giảm 30.1%, wire giảm 77.4% |

### Ghi nhận thêm về `POST /api/auth/login`
- Khi chạy đơn lẻ lúc bình thường sau khi khởi động API: `sv001` `3,293.72 ms` (lần đầu tiên warm up JIT + EF Model + BCrypt sau khởi động server, server log ghi `3129 ms`), các lần ngay sau đó giảm mạnh: `gv001` `599.65 ms`, `gvk.demo` `672.16 ms`, `pdt.demo` `516.58 ms`, `admin.demo` `197.62 ms`. Ở baseline trước tối ưu, server đã được warm sẵn trước khi đo nên các login đạt `114.30–363.77 ms` (và khi gặp bão 12 login song song từng vọt lên `5.2s–7.1s` — đã khóa bằng `_reAuthFuture` ở Flutter).
