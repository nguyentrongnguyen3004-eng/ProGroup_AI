import sys, time
sys.path.append('scripts')
from role_capture import login_as
from ui_helper import tap_node, print_screen_summary, capture, tap_coords, press_back

def capture_giaovu():
    # Login as gvk
    login_as('gvk')

    # 4.14 Dashboard Giáo vụ
    print("=== 4.14 Dashboard Giáo vụ ===")
    print_screen_summary()
    capture('Hinh_4_14_GiaoVu_TongQuanDashboard.png')

    # Tab 1: Dữ liệu khoa (5 tabs total: x = 144, 432, 720, 1008, 1296)
    print("=== Opening Tab Dữ liệu khoa ===")
    tap_coords(432, 2924, 2)
    print_screen_summary()
    # 4.15 Quản lý Lớp học phần (default sub-tab)
    print("=== 4.15 Quản lý Lớp HP ===")
    capture('Hinh_4_15_GiaoVu_QuanLyLopHocPhan.png')

    # Tap sub-tab 'Sinh viên'
    print("=== Tapping 'Sinh viên' sub-tab ===")
    tap_node('Sinh viên', 2)
    print_screen_summary()
    # 4.17 Quản lý Sinh viên / Giảng viên
    print("=== 4.17 Quản lý Sinh viên/GV ===")
    capture('Hinh_4_17_GiaoVu_QuanLySinhVien_GiangVien.png')

    # Tab 2: Phân công (x = 720)
    print("=== Opening Tab Phân công ===")
    tap_coords(720, 2924, 2)
    print_screen_summary()
    # Tap 'Phân công giảng viên'
    tap_node('Phân công giảng viên', 2)
    print_screen_summary()
    # 4.16 Phân công giảng viên
    print("=== 4.16 Phân công giảng viên ===")
    capture('Hinh_4_16_GiaoVu_PhanCongGiangVien.png')
    press_back(1.5)

    print("=== ALL 4 GIAO VU SCREENS CAPTURED! ===")

if __name__ == '__main__':
    capture_giaovu()
