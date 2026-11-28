import json

with open('all_testcases.json', encoding='utf-8') as f:
    tcs = json.load(f)['testcases']

sheets = [
    '2. Xác thực & Hệ thống',
    '3. Phân hệ Sinh viên',
    '4. Phân hệ Giảng viên',
    '5. Giáo vụ khoa',
    '6. Phòng đào tạo',
    '7. Quản trị hệ thống',
    '8. Phi chức năng & Bảo mật'
]

for s in sheets:
    sheet_tcs = [t for t in tcs if t['sheet'] == s]
    fails = [t for t in sheet_tcs if t.get('Trạng thái (Status)', '').strip().lower() == 'fail']
    untested = [t for t in sheet_tcs if t.get('Trạng thái (Status)', '').strip().lower() in ['untested', '', '(empty/untested)']]
    passes = [t for t in sheet_tcs if t.get('Trạng thái (Status)', '').strip().lower() == 'pass']
    print(f"\n=======================================================")
    print(f"=== {s} ===: Total={len(sheet_tcs)}, Pass={len(passes)}, Fail={len(fails)}, Untested={len(untested)}")
    print(f"=======================================================")
    if fails:
        print("  --- FAILS ---")
        for f in fails:
            tc_id = f.get('Mã TC (ID)', '')
            feat = f.get('Phân hệ / Tính năng', '')
            scen = f.get('Kịch bản kiểm thử (Scenario)', '')
            exp = f.get('Kết quả mong đợi (Expected Result)', '')
            act = f.get('Kết quả thực tế (Actual Result)', '')
            note = f.get('Mã Bug / Ghi chú', '')
            print(f"  [{tc_id}] {feat} - {scen}")
            print(f"    Expected: {exp}")
            print(f"    Actual:   {act}")
            if note:
                print(f"    Note:     {note}")
    if untested:
        print("  --- UNTESTED / EMPTY ---")
        for u in untested:
            tc_id = u.get('Mã TC (ID)', '')
            feat = u.get('Phân hệ / Tính năng', '')
            scen = u.get('Kịch bản kiểm thử (Scenario)', '')
            print(f"  [{tc_id}] {feat} - {scen}")
