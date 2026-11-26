import json
import re

with open('all_testcases.json', encoding='utf-8') as f:
    tcs = json.load(f)['testcases']

print(f"Total TCs to analyze: {len(tcs)}")

# Group by Sheet
by_sheet = {}
for tc in tcs:
    s = tc['sheet']
    by_sheet.setdefault(s, []).append(tc)

for s, items in by_sheet.items():
    print(f"\n=======================================================")
    print(f"SHEET: {s} ({len(items)} Test Cases)")
    print(f"=======================================================")
    for tc in items:
        tc_id = tc['Mã TC (ID)']
        feat = tc.get('Phân hệ / Tính năng', '')
        scen = tc.get('Kịch bản kiểm thử (Scenario)', '')
        status = tc.get('Trạng thái (Status)', '').strip()
        act = tc.get('Kết quả thực tế (Actual Result)', '').strip()
        note = tc.get('Mã Bug / Ghi chú', '').strip()
        print(f"  - [{tc_id}] {feat}: {scen} | Status={status} | Act={act[:50]} | Note={note}")
