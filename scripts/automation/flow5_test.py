import urllib.request
import json
import time
import os

BASE_URL = "http://localhost:5094"

def make_req(url, method="GET", data=None, token=None):
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    body = json.dumps(data).encode("utf-8") if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    start = time.perf_counter()
    try:
        with urllib.request.urlopen(req) as resp:
            dur = (time.perf_counter() - start) * 1000
            res_body = resp.read().decode("utf-8")
            try:
                parsed = json.loads(res_body)
            except Exception:
                parsed = res_body
            return resp.status, parsed, dur
    except urllib.error.HTTPError as e:
        dur = (time.perf_counter() - start) * 1000
        err_body = e.read().decode("utf-8")
        try:
            parsed = json.loads(err_body)
        except Exception:
            parsed = err_body
        return e.code, parsed, dur

results = {}

# 1. Login Admin
st, res, dur = make_req(f"{BASE_URL}/api/auth/login", "POST", {"tenDangNhap": "admin.demo", "matKhau": "123456"})
print(f"1. Login Admin: status={st}, dur={dur:.1f}ms")
token_admin = res["token"]
results["5.1_login_admin"] = {"status": st, "dur": dur}

# 2. Login GVK and fetch overview
st, res, dur = make_req(f"{BASE_URL}/api/auth/login", "POST", {"tenDangNhap": "gvk.demo", "matKhau": "123456"})
token_gvk = res["token"]
st, res, dur = make_req(f"{BASE_URL}/api/governance/overview", "GET", None, token_gvk)
print(f"2. GVK Overview: status={st}, dur={dur:.1f}ms, data={res}")
results["5.2_gvk_overview"] = {"status": st, "dur": dur, "res": res}

# 3. PDT / Admin Overview
st, res, dur = make_req(f"{BASE_URL}/api/admin/overview", "GET", None, token_admin)
print(f"3. Admin/PDT Overview: status={st}, dur={dur:.1f}ms, deTaiDaDuyet={res.get('tongDeTaiDaDuyet')}, tongNhom={res.get('tongNhom')}, tyLeHoanThanh={res.get('tyLeHoanThanh')}%")
results["5.3_admin_overview"] = {"status": st, "dur": dur, "res": res}

# 4. Trigger Database Backup
st, res, dur = make_req(f"{BASE_URL}/api/admin/backup", "POST", None, token_admin)
print(f"4. Database Backup: status={st}, dur={dur:.1f}ms, res={res}")
results["5.4_db_backup"] = {"status": st, "dur": dur, "res": res}
backup_file = res.get("filePath") if isinstance(res, dict) else None

# 5. Get Backup History
st, res, dur = make_req(f"{BASE_URL}/api/admin/backups", "GET", None, token_admin)
print(f"5. Backup History: status={st}, dur={dur:.1f}ms, count={len(res) if isinstance(res, list) else 0}")
results["5.5_backup_history"] = {"status": st, "dur": dur, "count": len(res) if isinstance(res, list) else 0, "first": res[0] if isinstance(res, list) and res else None}

# 6. Verify physical file
file_exists = os.path.exists(backup_file) if backup_file else False
file_size = os.path.getsize(backup_file) if file_exists else 0
print(f"6. Physical Backup File: exists={file_exists}, size={file_size:,} bytes")
results["5.6_physical_backup"] = {"exists": file_exists, "sizeBytes": file_size, "filePath": backup_file}

with open("scripts/flow5_results.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print("Flow 5 execution completed successfully!")
