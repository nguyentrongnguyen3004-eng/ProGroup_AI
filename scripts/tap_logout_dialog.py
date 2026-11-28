import sys, time
sys.path.append('scripts')
from capture_automation import tap_coords, dump_ui

print("Tapping Dang xuat...")
tap_coords(720, 2438, 1)

root = dump_ui()
for node in root.iter('node'):
    t = node.attrib.get('text', '') or node.attrib.get('content-desc', '')
    b = node.attrib.get('bounds', '')
    if t:
        print(f"  [{t}] @ {b}")
