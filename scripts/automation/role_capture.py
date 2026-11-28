import sys, time, subprocess
sys.path.append('scripts')
from ui_helper import run_adb, tap_coords, print_screen_summary, dump_ui, tap_node, capture, press_back

PASTE_COORDS = {
    'sv': (1240, 2170),
    'gv': (1240, 2245),
    'gvk': (1240, 2320),
    'pdt': (1240, 2390),
    'admin': (1240, 2465),
}

def login_as(role):
    print(f"=== Logging in cleanly as '{role}' ===")
    run_adb(['shell', 'pm', 'clear', 'com.example.progroup_ai_frontend'])
    time.sleep(1)
    run_adb(['shell', 'monkey', '-p', 'com.example.progroup_ai_frontend', '-c', 'android.intent.category.LAUNCHER', '1'])
    time.sleep(3)

    # Check for notification dialog
    root = dump_ui()
    if root is not None:
        for n in root.iter('node'):
            t = n.attrib.get('text', '')
            if 'Allow' in t:
                tap_coords(720, 1684, 1) # tap Allow
                time.sleep(1)
                break

    # Tap paste credentials
    px, py = PASTE_COORDS[role]
    tap_coords(px, py, 1)
    # Tap ĐĂNG NHẬP
    tap_coords(720, 1890, 4)
    print_screen_summary()

if __name__ == '__main__':
    login_as('gv')
