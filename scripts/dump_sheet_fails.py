import json

with open('all_testcases.json', encoding='utf-8') as f:
    tcs = json.load(f)['testcases']

for s in ['4. Phân hệ Giảng viên', '5. Giáo vụ khoa', '6. Phòng đào tạo']:
    sheet_tcs = [t for t in tcs if t['sheet'] == s]
    fails = [t for t in sheet_tcs if t.get('Trạng thái (Status)', '').strip().lower() == 'fail']
    print(f"\n=== {s} FAILS ({len(fails)}) ===")
    for f in fails:
        tc_id = f.get('Mã TC (ID)', '')
        feat = f.get('Phân hệ / Tính năng', '')
        scen = f.get('Kịch bản kiểm thử (Scenario)', '')
        exp = f.get('Kết quả mong đợi (Expected Result)', '')
        act = f.get('Kết quả thực tế (Actual Result)', '')
        note = f.get('Mã Bug / Ghi chú', '')
        print(f"[{tc_id}] {feat} - {scen}")
        print(f"  Exp: {exp}")
        print(f"  Act: {act}")
        if note:
            print(f"  Note: {note}")
