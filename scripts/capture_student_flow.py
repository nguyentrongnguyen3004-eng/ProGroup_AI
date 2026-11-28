import sys
import time
sys.path.append('scripts')
from capture_automation import tap_coords, tap_text, dump_ui, capture, scroll_down, scroll_up, press_back, run_adb

def login_as(username, password='123456'):
    print(f"Logging in as {username}...")
    # Tap username field
    tap_coords(500, 1080, 1)
    # Clear and type username
    run_adb(['shell', 'input', 'keyevent', '--longpress', '67']) # backspace
    for _ in range(20):
        run_adb(['shell', 'input', 'keyevent', '67'])
    run_adb(['shell', 'input', 'text', username])
    time.sleep(1)

    # Tap password field
    tap_coords(500, 1440, 1)
    for _ in range(20):
        run_adb(['shell', 'input', 'keyevent', '67'])
    run_adb(['shell', 'input', 'text', password])
    time.sleep(1)

    # Tap ĐĂNG NHẬP button
    tap_coords(720, 1890, 4)
    print("Logged in!")

def logout():
    print("Logging out...")
    # Go to profile tab (bottom right, ~ 1260, 2900)
    tap_coords(1260, 2900, 2)
    scroll_down(1)
    scroll_down(1)
    # Tap Đăng xuất
    tap_text('Đăng xuất', 2)
    # Confirm in dialog (right button)
    tap_coords(1041, 1786, 3)
    print("Logged out!")

if __name__ == '__main__':
    login_as('sv001', '123456')
    time.sleep(2)
    capture('Hinh_4_3_SinhVien_TrangChu_LopHocPhan.png')
