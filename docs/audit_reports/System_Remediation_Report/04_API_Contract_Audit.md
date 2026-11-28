# 04. BÁO CÁO ĐỐI SOÁT HỢP ĐỒNG API (API CONTRACT AUDIT)
## DANH MỤC ENDPOINTS, ROUTING, DTO MODELS & TƯƠNG THÍCH FRONTEND - BACKEND

---

### 1. BẢNG DANH MỤC TOÀN BỘ ENDPOINTS TRÊN BACKEND (35+ ENDPOINTS)

| Nhóm chức năng | Method | Route Endpoint | Request DTO / Params | Response Code / Model | Vai trò được phép |
|---|:---:|---|---|---|:---:|
| **Xác thực** | POST | `/api/auth/login` | `LoginRequest` (TenDangNhap, MatKhau) | 200 `AuthResponse`, 401 | Public |
| | POST | `/api/auth/doi-mat-khau` | `ChangePasswordRequest` | 200 OK, 400 | Authorized |
| | POST | `/api/auth/quen-mat-khau` | `ForgotPasswordRequest` (Email) | 200 OK, 404 | Public |
| | POST | `/api/auth/xac-nhan-otp` | `VerifyOtpRequest` (Email, Otp, NewPass) | 200 OK, 400 | Public |
| **Profile** | GET | `/api/profile` | (None, via JWT Bearer) | 200 `UserProfileDto` | Authorized |
| | PUT | `/api/profile` | `UpdateProfileRequest` (HoTen, SoDienThoai) | 200 `UserProfileDto` | Authorized |
| | POST | `/api/profile/upload-avatar` | `UploadAvatarRequest` (AvatarBase64) | 200 `UploadAvatarResponse` | Authorized |
| **Nhóm Đồ Án** | GET | `/api/nhom/danh-sach` | `?dotDangKyId={id}` | 200 `List<NhomDoAnDto>` | Authorized |
| | GET | `/api/nhom/cua-toi` | (None, via JWT Bearer) | 200 `List<NhomDoAnDto>` | Sinh viên |
| | GET | `/api/nhom/{id}` | Route parameter `{id}` | 200 `NhomDoAnDetailDto` | Authorized |
| | POST | `/api/nhom/tao-nhom` | `CreateNhomRequest` | 201 Created, 400 | Sinh viên |
| | POST | `/api/nhom/moi-thanh-vien` | `InviteMemberRequest` | 200 OK, 400 | Trưởng nhóm |
| | POST | `/api/nhom/xin-gia-nhap` | `JoinRequest` | 200 OK, 400 | Sinh viên |
| | POST | `/api/nhom/duyet-thanh-vien`| `ApproveMemberRequest` | 200 OK, 400 | Trưởng nhóm |
| | POST | `/api/nhom/roi-nhom` | `LeaveGroupRequest` | 200 OK, 400 | Sinh viên |
| | PUT | `/api/nhom/{id}/doi-ten` | `RenameGroupRequest` | 200 OK, 400 | Trưởng nhóm |
| **Đề Tài Đồ Án**| GET | `/api/de-tai/danh-sach` | `?dotDangKyId={id}` | 200 `List<DeTaiDto>` | Authorized |
| | GET | `/api/de-tai/{id}` | Route parameter `{id}` | 200 `DeTaiDetailDto` | Authorized |
| | POST | `/api/de-tai/de-xuat` | `ProposeTopicRequest` | 201 Created, 400 | Sinh viên |
| | POST | `/api/de-tai/tao-moi` | `CreateTopicRequest` | 201 Created, 400 | Giảng viên |
| | POST | `/api/de-tai/dang-ky` | `RegisterTopicRequest` (DeTaiId, NhomId) | 200 OK, 400, 409 | Trưởng nhóm |
| | POST | `/api/de-tai/duyet` | `ApproveTopicRequest` | 200 OK, 400 | Giảng viên |
| | POST | `/api/de-tai/duyet-de-xuat` | `ApproveProposedRequest` | 200 OK, 400 | Giảng viên |
| **Báo Cáo** | GET | `/api/bao-cao-tien-do/nhom/{nhomId}` | Route parameter `{nhomId}` | 200 `List<BaoCaoDto>` | Authorized |
| | POST | `/api/bao-cao-tien-do/nop` | `SubmitReportRequest` | 201 Created, 400 | Trưởng nhóm |
| | POST | `/api/bao-cao-tien-do/cham-diem`| `GradeReportRequest` | 200 OK, 400 | Giảng viên |
| **Admin** | GET | `/api/admin/overview` | (None, via JWT Bearer) | 200 `AdminOverviewDto` | ADMIN |
| | GET | `/api/admin/users` | `?page=1&pageSize=20` | 200 `PagedResult<UserDto>` | ADMIN |
| | POST | `/api/admin/users/create` | `CreateUserRequest` | 201 Created, 400 | ADMIN |
| | PUT | `/api/admin/users/{id}/status`| `UpdateStatusRequest` | 200 OK, 400 | ADMIN |
| **Giáo Vụ Khoa**| GET | `/api/giaovukhoa/thong-ke` | `?khoaId={id}` | 200 `FacultyStatsDto` | GIAOVUKHOA |
| | GET | `/api/giaovukhoa/lop-hoc-phan` | `?khoaId={id}` | 200 `List<LopHocPhanDto>`| GIAOVUKHOA |
| **Phòng Đào Tạo**| GET | `/api/phongdaotao/thong-ke`| (None, via JWT Bearer) | 200 `UniversityStatsDto`| PHONGDAOTAO |
| | GET | `/api/phongdaotao/hoc-ky` | (None) | 200 `List<HocKyDto>` | PHONGDAOTAO |

---

### 2. TƯƠNG THÍCH MÃ NGUỒN VÀ DỮ LIỆU FRONTEND
Toàn bộ các Service trong Frontend đã được kiểm tra tính tương thích tham số:
1. `ApiService`: Đã thống nhất Base URL động trỏ về `http://10.0.2.2:5094` (máy ảo Android) hoặc `http://127.0.0.1:5094` (Local Host).
2. `AuthService`: Tự động gắn header `Authorization: Bearer <token>` vào mọi request cần xác thực.
3. `TopicService`: Truyền đúng cặp tham số `{ "deTaiId": deTaiId, "nhomId": nhomId }` khớp chính xác với `RegisterTopicRequest` của Backend.
4. `ProfileService`: Gọi đúng endpoint `PUT /api/profile` truyền `{ "hoTen": hoTen, "soDienThoai": soDienThoai }` và đồng bộ lại SharedPreferences ngay khi thành công.
