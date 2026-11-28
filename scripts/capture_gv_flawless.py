import sys, time
sys.path.append('scripts')
from ui_helper import tap_node, press_back, capture, print_screen_summary, tap_coords, find_node, scroll_down, run_adb

def switch_to_gv():
    print("=== Returning to Main Student Screen & Logging Out ===")
    # Press back until at main screen
    for _ in range(3):
        press_back(1)
    
    # Tap Cá nhân tab (5th tab)
    tap_coords(1300, 2924, 2)
    scroll_down(2)
    tap_node('Đăng xuất', 2)
    # Check for confirmation dialog
    tap_node('Đồng ý', 1.5) or tap_node('Đăng xuất', 1.5)
    time.sleep(2)

    print("=== Logging in as Giảng viên ===")
    tap_coords(1240, 2245, 1) # paste gv001
    tap_coords(720, 1890, 3)  # ĐĂNG NHẬP
    time.sleep(3)
    print_screen_summary()

def capture_gv_screens():
    # 4.10 Trang chủ GV
    print("=== 4.10 Trang chủ GV ===")
    capture('Hinh_4_10_GiangVien_TrangChu_QuanLyLop.png')

    # 4.11 Quản lý đề tài
    print("=== 4.11 Quản lý đề tài ===")
    tap_node('Kho đề tài', 2) or tap_node('Đề tài', 2)
    print_screen_summary()
    capture('Hinh_4_11_GiangVien_QuanLyDeTai.png')
    press_back(1.5)

    # 4.12 Xét duyệt đề xuất
    print("=== 4.12 Xét duyệt đề xuất ===")
    tap_node('Ý tưởng của SV', 2) or tap_node('Đề xuất sinh viên', 2)
    print_screen_summary()
    capture('Hinh_4_12_GiangVien_XetDuyetDeXuat.png')
    press_back(1.5)

    # 4.13 Đánh giá báo cáo tiến độ
    print("=== 4.13 Đánh giá báo cáo tiến độ ===")
    tap_node('Chấm điểm & nhận xét', 2) or tap_node('Báo cáo tiến độ', 2)
    print_screen_summary()
    capture('Hinh_4_13_GiangVien_DanhGiaBaoCaoTienDo.png')
    press_back(1.5)

    print("=== ALL 4 LECTURER SCREENS CAPTURED! ===")

if __name__ == '__main__':
    switch_to_gv()
    capture_gv_screens()
