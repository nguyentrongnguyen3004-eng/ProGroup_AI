import sys, time
sys.path.append('scripts')
from ui_helper import tap_coords, print_screen_summary, capture, tap_node, press_back

def run():
    print("=== Tapping Giáo vụ demo row ===")
    tap_coords(720, 2320, 1)
    print("=== Tapping ĐĂNG NHẬP ===")
    tap_coords(720, 1890, 4)
    print_screen_summary()

    # 4.14
    print("=== 4.14 Dashboard Giáo vụ ===")
    capture('Hinh_4_14_GiaoVu_TongQuanDashboard.png')

    # Tab Dữ liệu khoa (Y=2860 is safe!)
    print("=== Tab Dữ liệu khoa ===")
    tap_coords(432, 2860, 2)
    print_screen_summary()
    capture('Hinh_4_15_GiaoVu_QuanLyLopHocPhan.png')

    # Sub-tab Sinh viên
    print("=== Sub-tab Sinh viên ===")
    tap_node('Sinh viên', 2)
    print_screen_summary()
    capture('Hinh_4_17_GiaoVu_QuanLySinhVien_GiangVien.png')

    # Tab Phân công
    print("=== Tab Phân công ===")
    tap_coords(720, 2860, 2)
    print_screen_summary()
    tap_node('Phân công giảng viên', 2)
    print_screen_summary()
    capture('Hinh_4_16_GiaoVu_PhanCongGiangVien.png')
    press_back(1.5)

    print("=== GIAO VU DONE! ===")

if __name__ == '__main__':
    run()
