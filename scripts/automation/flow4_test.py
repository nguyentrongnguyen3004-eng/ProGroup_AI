import urllib.request
import json
import time

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

# 1. Login Lecturer gv001
st, res, dur = make_req(f"{BASE_URL}/api/auth/login", "POST", {"tenDangNhap": "gv001", "matKhau": "123456"})
print(f"1. Login gv001: status={st}, dur={dur:.1f}ms")
token_gv = res["token"]
results["4.1_login_lecturer"] = {"status": st, "dur": dur}

# 2. Get pending proposals for lecturer
query = urllib.parse.quote("Chờ duyệt")
st, res, dur = make_req(f"{BASE_URL}/api/de-tai?trangThaiDuyet={query}", "GET", None, token_gv)
print(f"2. Get pending topics: status={st}, dur={dur:.1f}ms, count={len(res) if isinstance(res, list) else 0}")
topic_id = 130 # From Flow 3

# 3. Reject with revision request
reject_payload = {
    "chap_nhan": False,
    "lyDoTuChoi": "Cần bổ sung kiến trúc Microservices và kịch bản kiểm thử tải JMeter."
}
st, res, dur = make_req(f"{BASE_URL}/api/de-tai/{topic_id}/tu-choi", "PUT", reject_payload, token_gv)
print(f"3. Reject with comments: status={st}, dur={dur:.1f}ms, res={res}")
results["4.2_reject_with_comments"] = {"status": st, "dur": dur, "res": res}

# 4. Check notification sent to student in DB
st, res, dur = make_req(f"{BASE_URL}/api/auth/login", "POST", {"tenDangNhap": "sv001", "matKhau": "123456"})
token_sv1 = res["token"]
st, res, dur = make_req(f"{BASE_URL}/api/notifications", "GET", None, token_sv1)
print(f"4. Verify student notifications: status={st}, count={len(res) if isinstance(res, list) else 0}")
results["4.3_student_notifications"] = {"status": st, "dur": dur, "count": len(res) if isinstance(res, list) else 0}

# 5. Lecturer approves topic
approve_payload = {
    "chap_nhan": True,
    "isApproved": True,
    "ghiChu": "Đề tài đã bổ sung hoàn chỉnh kiến trúc và đạt yêu cầu phê duyệt chính thức."
}
st, res, dur = make_req(f"{BASE_URL}/api/de-tai/{topic_id}/duyet", "PUT", approve_payload, token_gv)
print(f"5. Approve topic: status={st}, dur={dur:.1f}ms, res={res}")
results["4.4_approve_topic"] = {"status": st, "dur": dur, "res": res}

# 6. Group 73 registers the approved topic
reg_payload = {
    "nhomId": 73,
    "deTaiId": topic_id
}
st, res, dur = make_req(f"{BASE_URL}/api/de-tai/dang-ky", "POST", reg_payload, token_sv1)
print(f"6. Register approved topic to group: status={st}, dur={dur:.1f}ms, res={res}")
results["4.5_register_topic_to_group"] = {"status": st, "dur": dur, "res": res}

# 7. Verify group status and topic linkage
st, res, dur = make_req(f"{BASE_URL}/api/groups/73", "GET", None, token_sv1)
print(f"7. Verify group 73: status={st}, dur={dur:.1f}ms, group={res.get('tenNhom') if isinstance(res, dict) else res}")
results["4.6_verify_group_linked"] = {"status": st, "dur": dur}

with open("scripts/flow4_results.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print("Flow 4 API execution completed successfully!")
