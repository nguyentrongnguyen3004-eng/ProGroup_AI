import subprocess
import time
import os
import xml.etree.ElementTree as ET

ADB = r'C:\Users\ACER\AppData\Local\Android\Sdk\platform-tools\adb.exe'
OUTPUT_DIR = r'D:\TRONGNGUYEN_HK7\PhatTrienUngDungDiDong\ProGroup_AI\report_screenshots'
os.makedirs(OUTPUT_DIR, exist_ok=True)

def run_adb(args):
    cmd = [ADB] + args
    return subprocess.run(cmd, capture_output=True, text=True, encoding='utf-8', errors='ignore')

def dump_ui():
    run_adb(['shell', 'uiautomator', 'dump', '/sdcard/dump.xml'])
    res = run_adb(['shell', 'cat', '/sdcard/dump.xml'])
    try:
        return ET.fromstring(res.stdout)
    except Exception as e:
        print("XML error:", e)
        return None

def parse_bounds(bounds_str):
    # e.g. [116,2725][1325,2893]
    parts = bounds_str.replace('][', ',').replace('[', '').replace(']', '').split(',')
    if len(parts) == 4:
        x1, y1, x2, y2 = map(int, parts)
        return (x1 + x2) // 2, (y1 + y2) // 2
    return None

def find_node(text_sub):
    root = dump_ui()
    if root is None:
        return None
    for node in root.iter('node'):
        t = node.attrib.get('text', '') or node.attrib.get('content-desc', '')
        if text_sub.lower() in t.lower():
            coords = parse_bounds(node.attrib.get('bounds', ''))
            return (t, coords)
    return None

def tap_text(text_sub, sleep_sec=2):
    res = find_node(text_sub)
    if res and res[1]:
        print(f"Tapping '{res[0]}' at {res[1]}")
        run_adb(['shell', 'input', 'tap', str(res[1][0]), str(res[1][1])])
        time.sleep(sleep_sec)
        return True
    print(f"Node '{text_sub}' not found")
    return False

def tap_coords(x, y, sleep_sec=2):
    run_adb(['shell', 'input', 'tap', str(x), str(y)])
    time.sleep(sleep_sec)

def scroll_down(sleep_sec=1):
    run_adb(['shell', 'input', 'swipe', '720', '2200', '720', '800', '300'])
    time.sleep(sleep_sec)

def scroll_up(sleep_sec=1):
    run_adb(['shell', 'input', 'swipe', '720', '800', '720', '2200', '300'])
    time.sleep(sleep_sec)

def press_back(sleep_sec=1):
    run_adb(['shell', 'input', 'keyevent', '4'])
    time.sleep(sleep_sec)

def input_text(text):
    run_adb(['shell', 'input', 'text', text])
    time.sleep(1)

def capture(filename):
    filepath = os.path.join(OUTPUT_DIR, filename)
    with open(filepath, 'wb') as f:
        subprocess.run([ADB, 'exec-out', 'screencap', '-p'], stdout=f)
    size = os.path.getsize(filepath)
    print(f"Captured: {filename} ({size} bytes)")
    return filepath

if __name__ == '__main__':
    print("Testing capture_automation...")
    scroll_down()
    dump_ui()
