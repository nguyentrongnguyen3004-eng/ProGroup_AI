import sys, time
sys.path.append('scripts')
from ui_helper import run_adb, tap_coords, print_screen_summary, capture, tap_node, dump_ui, press_back

def run():
    print("=== Clearing data & launching for PDT ===")
    run_adb(['shell', 'pm', 'clear', 'com.example.progroup_ai_frontend'])
    time.sleep(1)
    run_adb(['shell', 'monkey', '-p', 'com.example.progroup_ai_frontend', '-c', 'android.intent.category.LAUNCHER', '1'])
    time.sleep(3)

    # Check notification dialog
    root = dump_ui()
    if root is not None:
        for n in root.iter('node'):
            if 'Allow' in (n.attrib.get('text', '') or ''):
                tap_coords(720, 1684, 1.5)
                time.sleep(1)
                break

    print("=== Tapping Phòng đào tạo demo row ===")
    tap_coords(720, 2393, 1)
    print("=== Tapping ĐĂNG NHẬP ===")
    tap_coords(720, 1890, 4)
    print_screen_summary()

    # 4.18 Dashboard PĐT
    print("=== 4.18 Dashboard PĐT ===")
    capture('Hinh_4_18_PhongDaoTao_DashboardTongQuan.png')

    # Tab 1: QL Đào tạo (4 tabs total: x = 180, 540, 900, 1260; safe y = 2860)
    print("=== Tab QL Đào tạo ===")
    tap_coords(540, 2860, 2)
    print_screen_summary()
    capture('Hinh_4_19_PhongDaoTao_ThietLapDotDangKy.png')

    # Tap FAB 'Thêm / Nhập'
    print("=== Tapping FAB Thêm / Nhập ===")
    tap_node('Thêm / Nhập', 2) or tap_coords(1150, 2680, 2)
    print_screen_summary()
    tap_node('Nhập danh sách', 2) or tap_node('Nhập', 2)
    print_screen_summary()
    capture('Hinh_4_20_PhongDaoTao_ImportDuLieuExcel.png')
    press_back(1.5)

    print("=== PDT DONE! ===")

if __name__ == '__main__':
    run()
