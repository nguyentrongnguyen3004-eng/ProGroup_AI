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

# 1. Login sv001
st, res, dur = make_req(f"{BASE_URL}/api/auth/login", "POST", {"tenDangNhap": "sv001", "matKhau": "123456"})
print(f"1. Login sv001: status={st}, dur={dur:.1f}ms")
token_sv1 = res["token"]
results["3.1a_login_sv001"] = {"status": st, "dur": dur}

# 2. sv001 Create group
group_payload = {
    "dotDangKyId": 48,
    "tenNhom": "Nhóm E2E ProGroup AI"
}
st, res, dur = make_req(f"{BASE_URL}/api/groups", "POST", group_payload, token_sv1)
print(f"2. Create group: status={st}, dur={dur:.1f}ms, res={res}")
results["3.1b_create_group"] = {"status": st, "dur": dur, "res": res}
group_id = res.get("nhomId") or res.get("id")

# If already created, get my group
if not group_id:
    st, res, dur = make_req(f"{BASE_URL}/api/groups/mine", "GET", None, token_sv1)
    group_id = res.get("nhomId") or res.get("id")
    print(f"2b. Fetched existing group: {group_id}")

print(f"Using Group ID: {group_id}")

# 3. Constraint Test 1: Try inviting invalid student
st, res, dur = make_req(f"{BASE_URL}/api/groups/{group_id}/invitations", "POST", {"mssv": "NON_EXISTING_999"}, token_sv1)
print(f"3. Constraint Test 1 (Invalid MSSV): status={st} (expected 400/404), dur={dur:.1f}ms, msg={res}")
results["3.2_constraint_invalid_student"] = {"status": st, "dur": dur, "expected": 400}

# 4. Invite sv002 (MSSV: SV002)
st, res, dur = make_req(f"{BASE_URL}/api/groups/{group_id}/invitations", "POST", {"mssv": "SV002"}, token_sv1)
print(f"4. Invite SV002: status={st}, dur={dur:.1f}ms, res={res}")
results["3.3_invite_sv002"] = {"status": st, "dur": dur}

# 5. Constraint Test 2: Try inviting same student again (duplicate invite)
st, res, dur = make_req(f"{BASE_URL}/api/groups/{group_id}/invitations", "POST", {"mssv": "SV002"}, token_sv1)
print(f"5. Constraint Test 2 (Duplicate Invite): status={st} (expected 400/409), dur={dur:.1f}ms, msg={res}")
results["3.4_constraint_duplicate_invite"] = {"status": st, "dur": dur}

# 6. Login sv002 and accept invitation
st, res, dur = make_req(f"{BASE_URL}/api/auth/login", "POST", {"tenDangNhap": "sv002", "matKhau": "123456"})
print(f"6a. Login sv002: status={st}, dur={dur:.1f}ms")
token_sv2 = res["token"]

st, res, dur = make_req(f"{BASE_URL}/api/groups/invitations/me", "GET", None, token_sv2)
print(f"6b. Get invitations for sv002: status={st}, count={len(res) if isinstance(res, list) else 0}")
invitation_id = None
if isinstance(res, list) and len(res) > 0:
    for inv in res:
        if inv.get("groupId") == group_id or inv.get("groupName") == "Nhóm E2E ProGroup AI":
            invitation_id = inv.get("id")
            break
    if not invitation_id:
        invitation_id = res[0].get("id")

print(f"Invitation ID to accept: {invitation_id}")
if invitation_id:
    st, res, dur = make_req(f"{BASE_URL}/api/groups/invitations/{invitation_id}", "PUT", {"accept": True}, token_sv2)
    print(f"6c. Accept invitation: status={st}, dur={dur:.1f}ms, res={res}")
    results["3.5_accept_invitation"] = {"status": st, "dur": dur}

# 7. AI Suggestion as sv001
ai_suggest_payload = {
    "linhVuc": "Trí tuệ nhân tạo & Mobile Flutter",
    "congNghe": "Flutter, ASP.NET Core, Gemini API"
}
st, res, dur = make_req(f"{BASE_URL}/api/ai/suggest-topics", "POST", ai_suggest_payload, token_sv1)
print(f"7. AI Suggest Topics: status={st}, dur={dur:.1f}ms, suggestions_count={len(res.get('goiY', [])) if isinstance(res, dict) else 0}")
results["3.6_ai_suggest"] = {"status": st, "dur": dur, "res": res}

# 8. AI Standardize Topic as sv001
ai_std_payload = {
    "tenDeTai": "Hệ thống hỗ trợ đăng ký và quản lý nhóm đồ án sinh viên tích hợp AI",
    "moTa": "Ứng dụng đa nền tảng kết nối sinh viên, giảng viên và phòng đào tạo, hỗ trợ gợi ý đề tài và chuẩn hóa hồ sơ."
}
st, res, dur = make_req(f"{BASE_URL}/api/ai/standardize-topic", "POST", ai_std_payload, token_sv1)
print(f"8. AI Standardize Topic: status={st}, dur={dur:.1f}ms, standardized={res.get('mucTieu') is not None if isinstance(res, dict) else False}")
results["3.7_ai_standardize"] = {"status": st, "dur": dur, "res": res}
std_topic = res if isinstance(res, dict) else {}

# 9. sv001 Submits Topic Proposal
propose_payload = {
    "tenDeTai": std_topic.get("tenDeTaiChuanHoa", "Ứng dụng Quản lý & Phê duyệt Đồ án Sinh viên ProGroup AI"),
    "moTa": "Nghiên cứu kiến trúc Microservices và ứng dụng di động Flutter hỗ trợ quản lý đề tài đồ án tốt nghiệp.",
    "mucTieu": std_topic.get("mucTieu", "Tự động hóa quy trình phân nhóm, đăng ký đề tài và nộp báo cáo định kỳ."),
    "phamVi": std_topic.get("phamVi", "Toàn trường Đại học, áp dụng cho tất cả các khoa."),
    "congNgheDuKien": std_topic.get("congNgheDuKien", "Flutter, ASP.NET Core Web API, SQL Server, Firebase"),
    "dotDangKyId": 48,
    "lopHocPhanId": 26
}
st, res, dur = make_req(f"{BASE_URL}/api/de-tai/de-xuat", "POST", propose_payload, token_sv1)
print(f"9. Propose Topic: status={st}, dur={dur:.1f}ms, res={res}")
results["3.8_propose_topic"] = {"status": st, "dur": dur, "res": res}
topic_id = res.get("id") if isinstance(res, dict) else None

# 10. Constraint Test 3: Duplicate Proposal Prevention
st, res, dur = make_req(f"{BASE_URL}/api/de-tai/de-xuat", "POST", propose_payload, token_sv1)
print(f"10. Constraint Test 3 (Duplicate Proposal): status={st} (expected 400), dur={dur:.1f}ms, msg={res}")
results["3.9_constraint_duplicate_proposal"] = {"status": st, "dur": dur, "res": res}

with open("scripts/flow3_results.json", "w", encoding="utf-8") as f:
    json.dump({"results": results, "groupId": group_id, "topicId": topic_id}, f, ensure_ascii=False, indent=2)

print("Flow 3 API execution completed successfully!")
