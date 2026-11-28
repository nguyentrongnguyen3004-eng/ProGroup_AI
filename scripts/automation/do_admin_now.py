import sys, time
sys.path.append('scripts')
from ui_helper import tap_coords, print_screen_summary, capture, tap_node, scroll_down, press_back

def run():
    print("=== Exiting TrainingImportScreen ===")
    press_back(1.5)
    print_screen_summary()

    print("=== Tapping Cá nhân tab ===")
    tap_coords(1260, 2860, 2)
    print_screen_summary()

    print("=== Scrolling down to Logout ===")
    scroll_down(1.5)
    scroll_down(1.5)
    tap_node('Đăng xuất', 1.5)
    print_screen_summary()

    # Tap confirmation button 'Đăng xuất' in dialog (bottom right of dialog)
    print("=== Confirming Logout ===")
    tap_coords(1000, 1600, 2)
    print_screen_summary()

    # If still not on login screen, try tapping FilledButton specifically
    tap_node('Đăng xuất', 1.5)
    time.sleep(2)
    print_screen_summary()

    # Now on Login screen
    print("=== Logging in as Admin ===")
    tap_coords(720, 2466, 1) # Admin demo row
    tap_coords(720, 1890, 4) # ĐĂNG NHẬP
    print_screen_summary()

    # Tab 1: Người dùng (5 tabs: 144, 432, 720, 1008, 1296; y = 2860)
    print("=== Tab Người dùng ===")
    tap_coords(432, 2860, 2)
    print_screen_summary()
    capture('Hinh_4_21_Admin_QuanLyTaiKhoan_PhanQuyen.png')

    # Tab 2: Dữ liệu
    print("=== Tab Dữ liệu ===")
    tap_coords(720, 2860, 2)
    print_screen_summary()
    capture('Hinh_4_22_Admin_SaoLuu_PhucHoiCSDL.png')

    print("=== ADMIN DONE! ===")

if __name__ == '__main__':
    run()
