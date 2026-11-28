import sys, time
sys.path.append('scripts')
from capture_automation import tap_coords, tap_text, dump_ui, capture, scroll_down, scroll_up, press_back, run_adb

def run_student_captures():
    print("--- 1. Tap Group tab ---")
    tap_coords(720, 2924, 3)
    capture('Hinh_4_4_SinhVien_TaoNhom_QuanLyThanhVien.png')

    # Look for chat icon or chat button in Group screen
    print("--- 2. Checking for Chat in Group ---")
    res_chat = tap_text('Trò chuyện', 3)
    if not res_chat:
        res_chat = tap_text('Chat', 3)
    if not res_chat:
        # Check if there is an icon or tap group card
        tap_coords(720, 1100, 3) # tap first group card
        capture('Hinh_4_4_SinhVien_NhomChiTiet.png')
        tap_text('Trò chuyện', 3) or tap_text('Chat', 3)

    capture('Hinh_4_8_SinhVien_ChatNhomRealtime.png')
    press_back(2)

    # Check for Báo cáo tiến độ
    print("--- 3. Checking for Progress Report ---")
    tap_text('Báo cáo', 3) or tap_text('Tiến độ', 3)
    capture('Hinh_4_9_SinhVien_BaoCaoTienDo.png')
    press_back(2)

    # Return to Home tab
    tap_coords(144, 2924, 2)

    # Tap Gemini AI banner on Home
    print("--- 4. Open Gemini AI Topic Assistant ---")
    tap_coords(720, 650, 3) # banner
    capture('Hinh_4_5_SinhVien_AIGoiYDeTai.png')
    press_back(2)

    # Tap Lớp học phần tab or Topics
    print("--- 5. Open Topics & Propose Topic ---")
    tap_coords(432, 2924, 2) # Lớp học phần tab
    tap_coords(720, 600, 2) # first course
    tap_text('Đề tài', 2) or tap_text('Danh sách đề tài', 2)
    capture('Hinh_4_7_SinhVien_DangKyDeTai.png')

    tap_text('Đề xuất', 2) or tap_text('Đề xuất đề tài', 2)
    capture('Hinh_4_6_SinhVien_DeXuatDeTai_AIChuanHoa.png')
    press_back(2)
    press_back(2)

    print("Student flow captured successfully!")

if __name__ == '__main__':
    run_student_captures()
