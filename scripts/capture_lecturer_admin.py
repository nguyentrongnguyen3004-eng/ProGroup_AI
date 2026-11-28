import sys, time
sys.path.append('scripts')
from capture_automation import tap_coords, tap_text, dump_ui, capture, scroll_down, scroll_up, press_back, run_adb

def logout():
    print("Logging out...")
    tap_coords(1260, 2900, 2) # Cá nhân
    scroll_down(1)
    scroll_down(1)
    tap_text('Đăng xuất', 2)
    tap_coords(1041, 1786, 3) # confirm dialog
    print("Logged out!")

def login_as(username, password='123456'):
    print(f"Logging in as {username}...")
    tap_coords(500, 1080, 1) # username
    for _ in range(25):
        run_adb(['shell', 'input', 'keyevent', '67'])
    run_adb(['shell', 'input', 'text', username])
    time.sleep(1)

    tap_coords(500, 1440, 1) # password
    for _ in range(25):
        run_adb(['shell', 'input', 'keyevent', '67'])
    run_adb(['shell', 'input', 'text', password])
    time.sleep(1)

    run_adb(['shell', 'input', 'keyevent', '111']) # hide keyboard
    time.sleep(1)
    tap_coords(720, 1812, 4) # ĐĂNG NHẬP
    print("Logged in!")

def capture_lecturer():
    print("--- LECTURER FLOW ---")
    logout()
    login_as('gv001', '123456')
    time.sleep(3)

    # 1. Trang chủ / Quản lý lớp
    capture('Hinh_4_10_GiangVien_TrangChu_QuanLyLop.png')

    # 2. Đề tài tab (index 1 ~ 432, 2900)
    tap_coords(432, 2900, 3)
    capture('Hinh_4_11_GiangVien_QuanLyDeTai.png')

    # 3. Xét duyệt đề xuất đề tài (nút hoặc tab xét duyệt)
    res = tap_text('Xét duyệt', 3) or tap_text('Đề xuất', 3)
    if not res:
        tap_coords(1000, 500, 2) # switch tab inside topic screen if any
    capture('Hinh_4_12_GiangVien_XetDuyetDeXuat.png')

    # 4. Nhóm / Báo cáo tiến độ (index 2 ~ 720, 2900)
    tap_coords(720, 2900, 3)
    capture('Hinh_4_13_GiangVien_DanhGiaBaoCaoTienDo.png')

def capture_admin():
    print("--- ADMIN FLOW ---")
    logout()
    login_as('admin.demo', '123456')
    time.sleep(3)

    # 1. Quản lý tài khoản & Phân quyền (index 1 ~ 360, 2900)
    tap_coords(360, 2900, 3)
    capture('Hinh_4_20_Admin_QuanLyTaiKhoan_PhanQuyen.png')

    # 2. Quản lý dữ liệu & Sao lưu CSDL (index 2 ~ 720, 2900)
    tap_coords(720, 2900, 3)
    capture('Hinh_4_21_Admin_SaoLuu_PhucHoiCSDL.png')

if __name__ == '__main__':
    capture_lecturer()
    capture_admin()
    print("All captures completed successfully!")
