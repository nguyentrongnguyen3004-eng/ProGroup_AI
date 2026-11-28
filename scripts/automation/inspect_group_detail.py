with open('ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/sinh_vien/group/group_detail_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re
matches = re.findall(r"Text\(\s*['\"]([^'\"]+)['\"]", text)
print("Labels found in group_detail_screen.dart:")
for m in matches:
    print(" -", m)

# Search for Navigator.push or routes
pushes = re.findall(r"Navigator\.push[^\n]+", text)
print("\nPushes found:")
for p in pushes:
    print(" -", p)
