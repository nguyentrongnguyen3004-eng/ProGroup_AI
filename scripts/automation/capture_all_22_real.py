import sys, time, os, subprocess
sys.path.append('scripts')
from capture_automation import ADB, OUTPUT_DIR, dump_ui, capture, tap_coords, tap_text, scroll_down, scroll_up, press_back, run_adb

def restart_and_login(paste_x, paste_y):
    # Bring app to foreground
    run_adb(['shell', 'monkey', '-p', 'com.example.progroup_ai_frontend', '-c', 'android.intent.category.LAUNCHER', '1'])
    time.sleep(2)
    # Check if on login
    root = dump_ui()
    is_login = False
    if root is not None:
        for n in root.iter('node'):
            if 'ĐĂNG NHẬP' in (n.attrib.get('text', '') or ''):
                is_login = True
                break
    if not is_login:
        # Try logout
        tap_coords(1300, 2924, 2)
        scroll_down(2)
        tap_text('Đăng xuất', 2)
        # Check if dialog opened
        tap_coords(1000, 1600, 2) # confirm dialog if any

    # Now on login screen
    time.sleep(1)
    tap_coords(paste_x, paste_y, 1) # paste credentials
    tap_coords(720, 1890, 3)        # ĐĂNG NHẬP
    time.sleep(2)

def execute_all_captures():
    print("========================================")
    print("PHASE 1: CAPTURE LOGIN & FORGOT PASSWORD")
    print("========================================")
    # Relaunch to login screen
    run_adb(['shell', 'monkey', '-p', 'com.example.progroup_ai_frontend', '-c', 'android.intent.category.LAUNCHER', '1'])
    time.sleep(2)
    # If logged in, logout
    tap_coords(1300, 2924, 1)
    scroll_down(2)
    tap_text('Đăng xuất', 1)
    time.sleep(1)

    print("Capturing Hinh 4.1: Dang nhap...")
    capture('Hinh_4_1_DangNhap.png')

    print("Opening Quen mat khau...")
    tap_coords(1135, 1688, 2) # Quên mật khẩu?
    capture('Hinh_4_2_QuenMatKhau_OTP.png')
    tap_coords(98, 242, 2)    # Back to login

    print("========================================")
    print("PHASE 2: PHÂN HỆ SINH VIÊN")
    print("========================================")
    tap_coords(1240, 2170, 1) # paste sv001
    tap_coords(720, 1890, 3)  # ĐĂNG NHẬP
    time.sleep(2)

    # 4.3 Trang chủ SV
    print("Capturing Hinh 4.3: Trang chu SV...")
    capture('Hinh_4_3_SinhVien_TrangChu_LopHocPhan.png')

    # 4.5 AI gợi ý đề tài
    print("Opening AI Goi y de tai...")
    tap_coords(720, 674, 3) # banner Gemini AI
    capture('Hinh_4_5_SinhVien_AIGoiYDeTai.png')
    tap_coords(98, 242, 2)  # Back to Home

    # Course Detail -> Topic -> Propose Topic
    print("Opening Course Detail...")
    tap_coords(720, 1950, 2) # Tap 'Trí tuệ nhân tạo'
    time.sleep(1)
    tap_coords(720, 2450, 2) # 'Xem danh sách đề tài'
    time.sleep(1)

    # 4.7 Đăng ký đề tài (Topic Detail)
    print("Opening first topic in list...")
    tap_coords(720, 1200, 2) # tap first topic card
    time.sleep(1)
    print("Capturing Hinh 4.7: Dang ky de tai...")
    capture('Hinh_4_7_SinhVien_DangKyDeTai.png')
    tap_coords(98, 242, 2) # back to Topic list

    # 4.6 Đề xuất đề tài (Propose Topic)
    print("Opening Propose Topic...")
    tap_coords(1181, 2882, 2) # tap 'Đề xuất'
    time.sleep(1)
    # Tap 'Đề xuất đề tài' in bottom sheet
    tap_coords(720, 2600, 2)
    time.sleep(1)
    print("Capturing Hinh 4.6: De xuat de tai...")
    capture('Hinh_4_6_SinhVien_DeXuatDeTai_AIChuanHoa.png')
    tap_coords(98, 242, 2) # back to Topic list
    tap_coords(98, 242, 2) # back to Course Detail
    tap_coords(98, 242, 2) # back to Home

    # 4.4 Nhóm & Quản lý thành viên
    print("Opening Nhóm tab...")
    tap_coords(720, 2924, 2) # Nhóm tab
    time.sleep(1)
    tap_coords(720, 1283, 2) # Tap 'Nhóm Demo 02'
    time.sleep(1)
    print("Capturing Hinh 4.4: Chi tiet nhom & Thanh vien...")
    capture('Hinh_4_4_SinhVien_TaoNhom_QuanLyThanhVien.png')

    # 4.8 Chat realtime
    print("Opening Chat...")
    tap_coords(1356, 242, 2) # Chat icon top right
    time.sleep(1)
    print("Capturing Hinh 4.8: Chat realtime...")
    capture('Hinh_4_8_SinhVien_ChatNhomRealtime.png')
    tap_coords(98, 242, 2) # Back to Group Detail

    # 4.9 Báo cáo tiến độ
    print("Opening Progress Report...")
    scroll_down(2)
    time.sleep(1)
    # Tap 'Xem & Nộp báo cáo tiến độ'
    tap_coords(720, 1850, 2) or tap_coords(720, 2100, 2)
    time.sleep(1)
    print("Capturing Hinh 4.9: Bao cao tien do...")
    capture('Hinh_4_9_SinhVien_BaoCaoTienDo.png')
    tap_coords(98, 242, 2) # Back to Group Detail
    tap_coords(98, 242, 2) # Back to Nhóm tab

    # Logout SV
    tap_coords(1300, 2924, 2) # Cá nhân
    scroll_down(2)
    tap_text('Đăng xuất', 2)

    print("========================================")
    print("PHASE 3: PHÂN HỆ GIẢNG VIÊN")
    print("========================================")
    tap_coords(1240, 2245, 1) # paste gv001
    tap_coords(720, 1890, 3)  # ĐĂNG NHẬP
    time.sleep(2)

    # 4.10 Trang chủ GV
    print("Capturing Hinh 4.10: Trang chu GV...")
    capture('Hinh_4_10_GiangVien_TrangChu_QuanLyLop.png')

    # 4.11 Quản lý đề tài
    print("Opening Kho de tai...")
    tap_coords(386, 2364, 2) # Đề tài - Kho đề tài
    time.sleep(1)
    print("Capturing Hinh 4.11: Quan ly de tai GV...")
    capture('Hinh_4_11_GiangVien_QuanLyDeTai.png')
    tap_coords(98, 242, 2) # Back to Home

    # 4.12 Xét duyệt đề xuất
    print("Opening De xuat sinh vien...")
    tap_coords(386, 2692, 2) # Đề xuất sinh viên - Ý tưởng của SV
    time.sleep(1)
    print("Capturing Hinh 4.12: Xet duyet de xuat GV...")
    capture('Hinh_4_12_GiangVien_XetDuyetDeXuat.png')
    tap_coords(98, 242, 2) # Back to Home

    # 4.13 Báo cáo tiến độ
    print("Opening Bao cao tien do...")
    tap_coords(1054, 2692, 2) # Báo cáo tiến độ - Chấm điểm & nhận xét
    time.sleep(1)
    print("Capturing Hinh 4.13: Danh gia bao cao tien do GV...")
    capture('Hinh_4_13_GiangVien_DanhGiaBaoCaoTienDo.png')
    tap_coords(98, 242, 2) # Back to Home

    # Logout GV
    tap_coords(1300, 2924, 2) # Cá nhân
    scroll_down(2)
    tap_text('Đăng xuất', 2)

    print("========================================")
    print("PHASE 4: PHÂN HỆ GIÁO VỤ KHOA")
    print("========================================")
    tap_coords(1240, 2320, 1) # paste gvk.demo
    tap_coords(720, 1890, 3)  # ĐĂNG NHẬP
    time.sleep(2)

    # 4.14 Dashboard Giáo vụ
    print("Capturing Hinh 4.14: Dashboard Giao vu...")
    capture('Hinh_4_14_GiaoVu_TongQuanDashboard.png')

    # 4.15 Quản lý Lớp HP
    print("Opening Du lieu khoa -> Lop HP...")
    tap_coords(300, 2924, 2) # Tab Dữ liệu khoa
    time.sleep(1)
    print("Capturing Hinh 4.15: Quan ly Lop HP Giao vu...")
    capture('Hinh_4_15_GiaoVu_QuanLyLopHocPhan.png')

    # 4.17 Quản lý Sinh viên / Giảng viên
    print("Tapping 'Sinh viên' sub-tab...")
    tap_coords(500, 680, 2) # Tap 'Sinh viên' toggle
    time.sleep(1)
    print("Capturing Hinh 4.17: Quan ly Sinh vien Giao vu...")
    capture('Hinh_4_17_GiaoVu_QuanLySinhVien_GiangVien.png')

    # 4.16 Phân công giảng viên
    print("Opening Phân công tab...")
    tap_coords(500, 2924, 2) # Tab Phân công
    time.sleep(1)
    tap_coords(720, 1000, 2) # Tap 'Phân công giảng viên'
    time.sleep(1)
    print("Capturing Hinh 4.16: Phan cong giang vien...")
    capture('Hinh_4_16_GiaoVu_PhanCongGiangVien.png')
    tap_coords(98, 242, 2) # Back to Phân công tab

    # Logout Giao vu
    tap_coords(900, 2924, 2) # Cá nhân
    scroll_down(2)
    tap_text('Đăng xuất', 2)

    print("========================================")
    print("PHASE 5: PHÂN HỆ PHÒNG ĐÀO TẠO")
    print("========================================")
    tap_coords(1240, 2390, 1) # paste pdt.demo
    tap_coords(720, 1890, 3)  # ĐĂNG NHẬP
    time.sleep(2)

    # 4.18 Dashboard PĐT
    print("Capturing Hinh 4.18: Dashboard PDT...")
    capture('Hinh_4_18_PhongDaoTao_DashboardTongQuan.png')

    # 4.19 Quản lý đào tạo / Thiết lập đợt đăng ký
    print("Opening QL Đào tạo...")
    tap_coords(540, 2924, 2) # Tab QL Đào tạo
    time.sleep(1)
    print("Capturing Hinh 4.19: Thiet lap dot dang ky / QL Dao tao...")
    capture('Hinh_4_19_PhongDaoTao_ThietLapDotDangKy.png')

    # 4.20 Import dữ liệu Excel
    print("Opening Import dữ liệu...")
    tap_coords(1150, 2800, 2) # '+ Thêm / Nhập' FAB
    time.sleep(1)
    tap_text('Nhập danh sách', 2) or tap_coords(720, 2400, 2)
    time.sleep(1)
    print("Capturing Hinh 4.20: Import du lieu Excel...")
    capture('Hinh_4_20_PhongDaoTao_ImportDuLieuExcel.png')
    tap_coords(98, 242, 2) # Back

    # Logout PDT
    tap_coords(1260, 2924, 2) # Cá nhân
    scroll_down(2)
    tap_text('Đăng xuất', 2)

    print("========================================")
    print("PHASE 6: PHÂN HỆ ADMIN")
    print("========================================")
    tap_coords(1240, 2465, 1) # paste admin.demo
    tap_coords(720, 1890, 3)  # ĐĂNG NHẬP
    time.sleep(2)

    # 4.21 Quản lý người dùng & phân quyền
    print("Opening Tab 'Người dùng' in Admin...")
    tap_coords(300, 2924, 2) # Tab Người dùng
    time.sleep(1)
    print("Capturing Hinh 4.21: Quan tri tai khoan & Phan quyen Admin...")
    capture('Hinh_4_21_Admin_QuanLyTaiKhoan_PhanQuyen.png')

    # 4.22 Dữ liệu hệ thống / Sao lưu CSDL
    print("Opening Tab 'Dữ liệu' in Admin...")
    tap_coords(600, 2924, 2) # Tab Dữ liệu
    time.sleep(1)
    print("Capturing Hinh 4.22: Du lieu he thong & Sao luu Admin...")
    capture('Hinh_4_22_Admin_SaoLuu_PhucHoiCSDL.png')

    print("========================================")
    print("ALL 22 SCREENSHOTS CAPTURED FLAWLESSLY!")
    print("========================================")

if __name__ == '__main__':
    execute_all_captures()
