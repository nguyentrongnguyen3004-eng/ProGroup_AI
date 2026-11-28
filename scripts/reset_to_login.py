import sys, time
sys.path.append('scripts')
from capture_automation import run_adb, dump_ui

print("Clearing app state and relaunching...")
run_adb(['shell', 'pm', 'clear', 'com.example.progroup_ai_frontend'])
time.sleep(1)
run_adb(['shell', 'monkey', '-p', 'com.example.progroup_ai_frontend', '-c', 'android.intent.category.LAUNCHER', '1'])
time.sleep(3)

root = dump_ui()
for node in root.iter('node'):
    t = node.attrib.get('text', '') or node.attrib.get('content-desc', '')
    b = node.attrib.get('bounds', '')
    if t:
        print(f"  [{t}] @ {b}")
