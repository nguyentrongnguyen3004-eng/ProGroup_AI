import sys, time
sys.path.append('scripts')
from ui_helper import tap_coords, print_screen_summary, capture, tap_node

def run():
    print("=== Tapping Action Button Đăng xuất at (1041, 1786) ===")
    tap_coords(1041, 1786, 3)
    print_screen_summary()

    print("=== Tapping Admin demo row at (720, 2466) ===")
    tap_coords(720, 2466, 1)
    print("=== Tapping ĐĂNG NHẬP at (720, 1890) ===")
    tap_coords(720, 1890, 4)
    print_screen_summary()

    # Tab 1: Người dùng (5 tabs: x = 144, 432, 720, 1008, 1296; safe y = 2860)
    print("=== Tab 1: Người dùng ===")
    tap_coords(432, 2860, 2)
    print_screen_summary()
    capture('Hinh_4_21_Admin_QuanLyTaiKhoan_PhanQuyen.png')

    # Tab 2: Dữ liệu
    print("=== Tab 2: Dữ liệu ===")
    tap_coords(720, 2860, 2)
    print_screen_summary()
    capture('Hinh_4_22_Admin_SaoLuu_PhucHoiCSDL.png')

    print("=== ADMIN PERFECT DONE! ===")

if __name__ == '__main__':
    run()
