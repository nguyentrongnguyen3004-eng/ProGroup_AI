import urllib.request
import json

login_req = urllib.request.Request(
    'http://127.0.0.1:5094/api/auth/login',
    data=json.dumps({'tenDangNhap': 'gv001', 'matKhau': '123456'}).encode(),
    headers={'Content-Type': 'application/json'},
    method='POST'
)

try:
    with urllib.request.urlopen(login_req) as resp:
        data = json.loads(resp.read().decode())
        token = data.get('token')
        print(f"Logged in as {data.get('user', {}).get('tenDangNhap')}, Token obtained.")
except Exception as e:
    print("Login error:", e)
    token = None

if token:
    user_req = urllib.request.Request(
        'http://127.0.0.1:5094/api/admin/users',
        headers={'Authorization': f'Bearer {token}'}
    )
    try:
        with urllib.request.urlopen(user_req) as resp:
            users = json.loads(resp.read().decode())
            print(f"Total Users in SQL Server: {len(users)}")
            for u in users:
                print(f"ID={u.get('nguoiDungId')}, User={u.get('tenDangNhap')}, Role={u.get('maVaiTro')} ({u.get('tenVaiTro')}), Email={u.get('email')}, Phone={u.get('soDienThoai')}")
    except Exception as e:
        print("Fetch users error:", e)
