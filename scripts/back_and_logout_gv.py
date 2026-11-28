import sys, time
sys.path.append('scripts')
from capture_automation import tap_coords, tap_text, dump_ui, capture, scroll_down, press_back

# Back from "Đánh giá tiến độ" to Home
tap_coords(98, 242, 2)

# Go to Cá nhân
tap_coords(1296, 2924, 2)
scroll_down(2)
tap_text('Đăng xuất', 2)

root = dump_ui()
for node in root.iter('node'):
    t = node.attrib.get('text', '') or node.attrib.get('content-desc', '')
    b = node.attrib.get('bounds', '')
    if t:
        print(f"  [{t}] @ {b}")
