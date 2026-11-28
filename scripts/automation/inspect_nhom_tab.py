import sys, time
sys.path.append('scripts')
from capture_automation import tap_coords, dump_ui, capture

# Tap Nhóm tab
print("Tapping Nhom tab at (720, 2924)...")
tap_coords(720, 2924, 2)

root = dump_ui()
for node in root.iter('node'):
    t = node.attrib.get('text', '') or node.attrib.get('content-desc', '')
    b = node.attrib.get('bounds', '')
    if t and len(t) < 50:
        print(f"  [{t}] @ {b}")
