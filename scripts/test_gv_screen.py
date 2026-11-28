import sys, time
sys.path.append('scripts')
from capture_automation import tap_coords, tap_text, dump_ui, capture, run_adb

def login_as(role_paste_x, role_paste_y):
    # If not on login screen, try to bring app to foreground or logout
    run_adb(['shell', 'monkey', '-p', 'com.example.progroup_ai_frontend', '-c', 'android.intent.category.LAUNCHER', '1'])
    time.sleep(2)
    # Check if login button exists
    root = dump_ui()
    has_login = False
    for node in root.iter('node'):
        if 'ĐĂNG NHẬP' in (node.attrib.get('text', '') or ''):
            has_login = True
            break
    if not has_login:
        # Tap bottom right (Cá nhân) and logout
        tap_coords(1296, 2924, 2)
        run_adb(['shell', 'input', 'swipe', '720', '2500', '720', '800', '300'])
        time.sleep(1)
        tap_text('Đăng xuất', 2)

    # Now paste credentials
    tap_coords(role_paste_x, role_paste_y, 1)
    tap_coords(720, 1890, 3) # tap ĐĂNG NHẬP

if __name__ == '__main__':
    print("Logging in as Giảng viên...")
    login_as(1240, 2245) # GV paste button
    time.sleep(2)
    root = dump_ui()
    for node in root.iter('node'):
        t = node.attrib.get('text', '') or node.attrib.get('content-desc', '')
        b = node.attrib.get('bounds', '')
        if t:
            print(f"  [{t}] @ {b}")
