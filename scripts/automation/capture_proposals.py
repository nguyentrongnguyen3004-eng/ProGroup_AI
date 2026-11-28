import sys, time
sys.path.append('scripts')
from capture_automation import tap_coords, tap_text, dump_ui, capture, scroll_down, scroll_up, press_back, run_adb

def capture_propose_topic():
    print("Logging in as sv001 to capture ProposeTopicScreen...")
    # Currently on Admin screen, let's logout
    tap_coords(1260, 2900, 2) # Cá nhân
    scroll_down(1)
    scroll_down(1)
    tap_text('Đăng xuất', 2)
    tap_coords(1041, 1786, 3) # confirm

    # Login sv001
    tap_coords(500, 1080, 1)
    for _ in range(25):
        run_adb(['shell', 'input', 'keyevent', '67'])
    run_adb(['shell', 'input', 'text', 'sv001'])
    time.sleep(1)

    tap_coords(500, 1440, 1)
    for _ in range(25):
        run_adb(['shell', 'input', 'keyevent', '67'])
    run_adb(['shell', 'input', 'text', '123456'])
    time.sleep(1)

    run_adb(['shell', 'input', 'keyevent', '111'])
    time.sleep(1)
    tap_coords(720, 1812, 4)

    # Tap Gemini AI banner on Home
    tap_coords(720, 650, 3) # banner opens AI Topic screen
    # In AI Topic screen, find 'Đề xuất đề tài' button or similar
    tap_text('Đề xuất', 2) or tap_text('Tự đề xuất', 2) or tap_coords(720, 2800, 2)
    capture('Hinh_4_6_SinhVien_DeXuatDeTai_AIChuanHoa.png')
    press_back(2)
    press_back(2)

def capture_lecturer_proposal():
    print("Logging in as gv001 to capture LecturerTopicProposalScreen...")
    tap_coords(1260, 2900, 2) # Cá nhân
    scroll_down(1)
    scroll_down(1)
    tap_text('Đăng xuất', 2)
    tap_coords(1041, 1786, 3) # confirm

    # Login gv001
    tap_coords(500, 1080, 1)
    for _ in range(25):
        run_adb(['shell', 'input', 'keyevent', '67'])
    run_adb(['shell', 'input', 'text', 'gv001'])
    time.sleep(1)

    tap_coords(500, 1440, 1)
    for _ in range(25):
        run_adb(['shell', 'input', 'keyevent', '67'])
    run_adb(['shell', 'input', 'text', '123456'])
    time.sleep(1)

    run_adb(['shell', 'input', 'keyevent', '111'])
    time.sleep(1)
    tap_coords(720, 1812, 4)

    # On Lecturer Home, scroll down to Quick Actions and tap 'Đề xuất sinh viên'
    scroll_down(1)
    tap_text('Đề xuất sinh viên', 3) or tap_text('Ý tưởng của SV', 3)
    capture('Hinh_4_12_GiangVien_XetDuyetDeXuat.png')

if __name__ == '__main__':
    capture_propose_topic()
    capture_lecturer_proposal()
    print("Refined captures completed!")
