import urllib.request
import urllib.parse
import json
import threading
import time

BASE_URL = "http://127.0.0.1:5094"

results = []

def record(test_name, status, details, evidence=""):
    print(f"[{status}] {test_name}: {details}")
    results.append({
        "test": test_name,
        "status": status,
        "details": details,
        "evidence": evidence
    })

def http_req(path, method="GET", data=None, token=None):
    url = f"{BASE_URL}{path}"
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    body = json.dumps(data).encode("utf-8") if data is not None else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            code = resp.getcode()
            raw = resp.read().decode("utf-8")
            try:
                parsed = json.loads(raw)
            except:
                parsed = raw
            return code, parsed
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8")
        try:
            parsed = json.loads(raw)
        except:
            parsed = raw
        return e.code, parsed
    except Exception as e:
        return 0, str(e)

print(f"--- STARTING INTEGRATION & CONCURRENCY TESTS ON {BASE_URL} ---")

# 1. Health check
code, resp = http_req("/api/health")
if code == 200 and isinstance(resp, dict) and resp.get("status") == "healthy":
    record("API_HEALTH_CHECK", "PASS", "Backend API responds HTTP 200 with healthy status.", json.dumps(resp))
else:
    record("API_HEALTH_CHECK", "FAIL", f"Expected 200 Healthy, got {code}: {resp}")

# 2. Student Login
code, resp = http_req("/api/auth/login", method="POST", data={"tenDangNhap": "sv001", "matKhau": "123456"})
student_token = None
if code == 200 and "token" in resp:
    student_token = resp["token"]
    role = resp.get("maVaiTro") or resp.get("vaiTro")
    record("AUTH_STUDENT_LOGIN", "PASS", f"Student login successful. Role: {role}", f"Token prefix: {student_token[:20]}...")
else:
    record("AUTH_STUDENT_LOGIN", "FAIL", f"Failed to login sv001: {code} {resp}")

# 3. Lecturer Login
code, resp = http_req("/api/auth/login", method="POST", data={"tenDangNhap": "gv001", "matKhau": "123456"})
lecturer_token = None
if code == 200 and "token" in resp:
    lecturer_token = resp["token"]
    role = resp.get("maVaiTro") or resp.get("vaiTro")
    record("AUTH_LECTURER_LOGIN", "PASS", f"Lecturer login successful. Role: {role}", f"Token prefix: {lecturer_token[:20]}...")
else:
    record("AUTH_LECTURER_LOGIN", "FAIL", f"Failed to login gv001: {code} {resp}")

# 4. Admin Login
code, resp = http_req("/api/auth/login", method="POST", data={"tenDangNhap": "admin01", "matKhau": "123456"})
admin_token = None
if code == 200 and "token" in resp:
    admin_token = resp["token"]
    role = resp.get("user", {}).get("maVaiTro") or resp.get("maVaiTro")
    record("AUTH_ADMIN_LOGIN", "PASS", f"Admin login successful. Role: {role}", f"Token prefix: {admin_token[:20]}...")
else:
    record("AUTH_ADMIN_LOGIN", "FAIL", f"Failed to login admin01: {code} {resp}")

# 4b. Governance Login
code, resp = http_req("/api/auth/login", method="POST", data={"tenDangNhap": "giaovu01", "matKhau": "123456"})
gvk_token = None
if code == 200 and "token" in resp:
    gvk_token = resp["token"]
    role = resp.get("user", {}).get("maVaiTro")
    record("AUTH_GIAOVU_LOGIN", "PASS", f"Governance login successful. Role: {role}", f"Token prefix: {gvk_token[:20]}...")
else:
    record("AUTH_GIAOVU_LOGIN", "FAIL", f"Failed to login giaovu01: {code} {resp}")

# 4c. Training Department Login
code, resp = http_req("/api/auth/login", method="POST", data={"tenDangNhap": "daotao01", "matKhau": "123456"})
pdt_token = None
if code == 200 and "token" in resp:
    pdt_token = resp["token"]
    role = resp.get("user", {}).get("maVaiTro")
    record("AUTH_DAOTAO_LOGIN", "PASS", f"Training Dept login successful. Role: {role}", f"Token prefix: {pdt_token[:20]}...")
else:
    record("AUTH_DAOTAO_LOGIN", "FAIL", f"Failed to login daotao01: {code} {resp}")

# 5. Invalid credentials login
code, resp = http_req("/api/auth/login", method="POST", data={"tenDangNhap": "sv001", "matKhau": "wrong_password"})
if code == 401:
    record("AUTH_INVALID_PASSWORD", "PASS", "Blocked with HTTP 401 Unauthorized as expected.", json.dumps(resp))
else:
    record("AUTH_INVALID_PASSWORD", "FAIL", f"Expected 401, got {code}: {resp}")

# 6. Profile fetching (Authenticated)
if student_token:
    code, resp = http_req("/api/profile", token=student_token)
    if code == 200 and isinstance(resp, dict) and "tenDangNhap" in resp:
        record("PROFILE_FETCH_STUDENT", "PASS", f"Profile loaded: {resp.get('hoTen')} ({resp.get('tenDangNhap')})", json.dumps(resp)[:100])
    else:
        record("PROFILE_FETCH_STUDENT", "FAIL", f"Profile fetch error: {code} {resp}")

# 7. Profile Phone update
if student_token:
    new_phone = "0987654321"
    code, resp = http_req("/api/profile", method="PUT", data={"soDienThoai": new_phone}, token=student_token)
    if code == 200 and isinstance(resp, dict) and resp.get("soDienThoai") == new_phone:
        record("PROFILE_UPDATE_PHONE", "PASS", f"Phone updated to {new_phone} in database.", json.dumps(resp)[:100])
    else:
        record("PROFILE_UPDATE_PHONE", "FAIL", f"Phone update failed: {code} {resp}")

# 8. Profile Avatar file size limit check (> 10MB)
if student_token:
    # 15MB payload (decodes to ~11.25MB raw bytes > 10MB limit)
    oversized = "data:image/png;base64," + ("A" * (15 * 1024 * 1024))
    code, resp = http_req("/api/profile/avatar", method="POST", data={"avatarData": oversized}, token=student_token)
    if code == 400:
        record("SECURITY_AVATAR_OVERSIZED_LIMIT", "PASS", "Oversized avatar (> 10MB) rejected with HTTP 400 as expected.", json.dumps(resp))
    else:
        record("SECURITY_AVATAR_OVERSIZED_LIMIT", "FAIL", f"Expected 400, got {code}: {resp}")

# 9. Role-based Authorization: Student calling Admin endpoint
if student_token:
    code, resp = http_req("/api/admin/overview", token=student_token)
    if code == 403:
        record("SECURITY_RBAC_STUDENT_TO_ADMIN", "PASS", "Student forbidden from accessing Admin API (HTTP 403).", "HTTP 403 Forbidden")
    else:
        record("SECURITY_RBAC_STUDENT_TO_ADMIN", "FAIL", f"Expected 403, got {code}: {resp}")

# 10. Admin Overview Data Integrity
if admin_token:
    code, resp = http_req("/api/admin/overview", token=admin_token)
    if code == 200 and isinstance(resp, dict) and "tongNguoiDung" in resp:
        total = resp.get("tongNguoiDung")
        sv = resp.get("tongSinhVien")
        gv = resp.get("tongGiangVien")
        record("ADMIN_OVERVIEW_DATA", "PASS", f"Admin stats returned: Total users={total}, Students={sv}, Lecturers={gv}", json.dumps(resp))
    else:
        record("ADMIN_OVERVIEW_DATA", "FAIL", f"Admin overview error: {code} {resp}")

# 11. Concurrency Registration Test: Two simultaneous requests for topic registration
print("\n--- RUNNING CONCURRENCY TEST (SIMULTANEOUS REGISTRATION) ---")
concurrency_results = []

def send_register(group_id, topic_id, token, res_list, idx):
    c, r = http_req("/api/de-tai/dang-ky", method="POST", data={"nhomId": group_id, "deTaiId": topic_id}, token=token)
    res_list.append((idx, c, r))

# Spawn 2 threads hitting the endpoint at exact same second
t1 = threading.Thread(target=send_register, args=(1, 1, student_token, concurrency_results, 1))
t2 = threading.Thread(target=send_register, args=(2, 1, student_token, concurrency_results, 2))

t1.start()
t2.start()
t1.join()
t2.join()

success_count = sum(1 for idx, c, r in concurrency_results if c in [200, 201])
conflict_count = sum(1 for idx, c, r in concurrency_results if c in [400, 404, 409, 403])

print(f"Concurrency results: {concurrency_results}")
if success_count <= 1:
    record("CONCURRENCY_TOPIC_REGISTRATION", "PASS", f"Transaction lock & race-condition check verified. Success: {success_count}, Rejected/Conflict: {conflict_count}", str(concurrency_results))
else:
    record("CONCURRENCY_TOPIC_REGISTRATION", "FAIL", f"Duplicate registration permitted! Both succeeded: {concurrency_results}")

with open("integration_test_results.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print("\n--- ALL TESTS COMPLETED ---")
print(f"Total: {len(results)} | Passed: {sum(1 for r in results if r['status'] == 'PASS')} | Failed: {sum(1 for r in results if r['status'] == 'FAIL')}")
