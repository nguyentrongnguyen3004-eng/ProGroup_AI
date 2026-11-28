import re, time, subprocess, sys
import xml.etree.ElementTree as ET

ADB = r"C:\Users\ACER\AppData\Local\Android\Sdk\platform-tools\adb.exe"

def run_adb(args):
    return subprocess.run([ADB] + args, capture_output=True, text=True, encoding='utf-8', errors='ignore')

def dump_ui():
    run_adb(['shell', 'uiautomator', 'dump', '/data/local/tmp/uidump.xml'])
    res = run_adb(['shell', 'cat', '/data/local/tmp/uidump.xml'])
    if not res.stdout or '<hierarchy' not in res.stdout:
        return None
    xml_str = res.stdout[res.stdout.find('<hierarchy'):]
    try:
        return ET.fromstring(xml_str)
    except Exception:
        return None

def find_node(substring):
    root = dump_ui()
    if root is None:
        return None, None, None
    for n in root.iter('node'):
        t = n.attrib.get('text', '') or n.attrib.get('content-desc', '')
        if substring.lower() in t.lower():
            bounds = n.attrib.get('bounds', '')
            m = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', bounds)
            if m:
                x1, y1, x2, y2 = map(int, m.groups())
                return t, (x1 + x2) // 2, (y1 + y2) // 2
    return None, None, None

def tap_node(substring, delay=2):
    t, cx, cy = find_node(substring)
    if cx is not None:
        print(f'Tapping "{t}" at ({cx}, {cy})')
        run_adb(['shell', 'input', 'tap', str(cx), str(cy)])
        time.sleep(delay)
        return True
    print(f'Node "{substring}" not found!')
    return False

def tap_coords(x, y, delay=2):
    run_adb(['shell', 'input', 'tap', str(x), str(y)])
    time.sleep(delay)

def scroll_down(delay=1):
    run_adb(['shell', 'input', 'swipe', '720', '2200', '720', '800', '350'])
    time.sleep(delay)

def scroll_up(delay=1):
    run_adb(['shell', 'input', 'swipe', '720', '800', '720', '2200', '350'])
    time.sleep(delay)

def press_back(delay=1):
    # Click AppBar back icon if present, otherwise adb back
    t, cx, cy = find_node('Back')
    if cx is not None and cy < 400:
        tap_coords(cx, cy, delay)
    else:
        run_adb(['shell', 'input', 'keyevent', '4'])
        time.sleep(delay)

def capture(filename):
    out_path = f"report_screenshots/{filename}"
    run_adb(['shell', 'screencap', '-p', '/data/local/tmp/screen.png'])
    run_adb(['pull', '/data/local/tmp/screen.png', out_path])
    import os
    size = os.path.getsize(out_path)
    print(f'Captured: {filename} ({size} bytes)')
    return size

def print_screen_summary():
    root = dump_ui()
    if root is None:
        print('UI dump failed')
        return
    texts = []
    for n in root.iter('node'):
        t = n.attrib.get('text', '') or n.attrib.get('content-desc', '')
        if t and t not in texts:
            texts.append(t)
    print('SCREEN NODES: ' + ' | '.join(texts[:15]))
