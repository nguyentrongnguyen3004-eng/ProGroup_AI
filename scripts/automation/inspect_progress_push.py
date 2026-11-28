with open('ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/sinh_vien/group/group_detail_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

idx = text.find('Xem & Nộp báo cáo tiến độ')
print(text[idx-800:idx-400])
