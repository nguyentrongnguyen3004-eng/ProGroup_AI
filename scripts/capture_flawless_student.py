import sys, time
sys.path.append('scripts')
from capture_automation import tap_coords, tap_text, dump_ui, capture, scroll_down, scroll_up, press_back, run_adb

def dump_and_print():
    root = dump_ui()
    if root is None:
        return
    for node in root.iter('node'):
        t = node.attrib.get('text', '') or node.attrib.get('content-desc', '')
        b = node.attrib.get('bounds', '')
        if t and len(t) < 50:
            print(f"  [{t}] @ {b}")

def capture_student_flow_flawless():
    print("=== STEP 1: Login as Sinh viên ===")
    tap_coords(1240, 2170, 1) # paste sv001
    tap_coords(720, 1890, 3)  # ĐĂNG NHẬP

    print("=== STEP 2: Capture Hinh 4.3 Trang chu SV ===")
    capture('Hinh_4_3_SinhVien_TrangChu_LopHocPhan.png')

    print("=== STEP 3: Capture Hinh 4.5 AI Goi y de tai ===")
    tap_coords(720, 650, 3) # banner Gemini AI
    capture('Hinh_4_5_SinhVien_AIGoiYDeTai.png')
    press_back(2)

    print("=== STEP 4: Navigate to CourseDetail -> Topics -> Propose Topic ===")
    # Tap first course on home screen
    tap_text('Trí tuệ nhân tạo', 2)
    # Inside CourseDetailScreen:
    dump_and_print()
    tap_text('Xem danh sách đề tài', 2)
    
    print("=== STEP 5: Capture Hinh 4.7 Dang ky de tai ===")
    capture('Hinh_4_7_SinhVien_DangKyDeTai.png')

    # Look for button to propose topic in TopicScreen
    print("=== Looking for Propose topic button in TopicScreen ===")
    dump_and_print()
    # In TopicScreen, there is often a button "Đề xuất đề tài" or "+"
    res_prop = tap_text('Đề xuất', 2) or tap_coords(1280, 2750, 2) # FAB
    if res_prop:
        print("=== STEP 6: Capture Hinh 4.6 De xuat de tai ===")
        capture('Hinh_4_6_SinhVien_DeXuatDeTai_AIChuanHoa.png')
        press_back(2)
    else:
        print("Could not find propose topic button in TopicScreen, will try alternative route")

    press_back(2) # back from TopicScreen to CourseDetail
    press_back(2) # back from CourseDetail to Home

    print("=== STEP 7: Group Tab ===")
    tap_coords(720, 2924, 2) # Group tab (3rd icon)
    dump_and_print()

    # Look for "Tạo nhóm"
    tap_text('Tạo nhóm', 2) or tap_coords(1280, 2750, 2) # FAB
    print("=== STEP 8: Capture Hinh 4.4 Tao nhom & Quan ly TV ===")
    capture('Hinh_4_4_SinhVien_TaoNhom_QuanLyThanhVien.png')
    press_back(2)

    # Open first group card
    print("=== Open Group Detail ===")
    tap_text('Nhóm Demo 02', 2) or tap_coords(720, 1100, 2)
    dump_and_print()

    # Chat icon in app bar
    print("=== Open Chat ===")
    tap_coords(1330, 200, 3)
    capture('Hinh_4_8_SinhVien_ChatNhomRealtime.png')
    press_back(2)

    # Scroll down to find Progress report in Group Detail
    print("=== Open Progress Report ===")
    scroll_down(2)
    dump_and_print()
    tap_text('Báo cáo', 2) or tap_text('tiến độ', 2) or tap_coords(720, 2300, 2)
    capture('Hinh_4_9_SinhVien_BaoCaoTienDo.png')
    press_back(2)

    # Logout
    print("=== Logout ===")
    tap_coords(1300, 2924, 2) # Cá nhân tab
    scroll_down(2)
    tap_text('Đăng xuất', 2)

    print("=== STUDENT FLOW FINISHED ===")

if __name__ == '__main__':
    capture_student_flow_flawless()
