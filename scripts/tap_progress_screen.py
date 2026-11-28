import sys, time
sys.path.append('scripts')
from capture_automation import tap_coords, tap_text, dump_ui, capture, scroll_down

# Go back from "Duyệt yêu cầu tham gia"
tap_coords(98, 242, 2)

# Now we should be on GroupDetailScreen
scroll_down(2)
root = dump_ui()
for node in root.iter('node'):
    t = node.attrib.get('text', '') or node.attrib.get('content-desc', '')
    b = node.attrib.get('bounds', '')
    if t:
        print(f"  [{t}] @ {b}")
