import sys, time
sys.path.append('scripts')
from capture_automation import tap_text, tap_coords, dump_ui, capture, scroll_down, scroll_up, press_back, run_adb

def dump_texts():
    root = dump_ui()
    if root is None:
        print("Root is None")
        return []
    items = []
    for node in root.iter('node'):
        t = node.attrib.get('text', '') or node.attrib.get('content-desc', '')
        b = node.attrib.get('bounds', '')
        if t:
            items.append((t, b))
    return items

if __name__ == '__main__':
    texts = dump_texts()
    print("Found texts on current screen:")
    for t, b in texts[:20]:
        print(f"  {t} @ {b}")
