import json
import xml.etree.ElementTree as ET
import subprocess

adb = r"C:\Users\ACER\AppData\Local\Android\Sdk\platform-tools\adb.exe"

# 1. Pull shared prefs
raw = subprocess.check_output([adb, "shell", "run-as", "com.example.progroup_ai_frontend", "cat", "shared_prefs/FlutterSharedPreferences.xml"]).decode("utf-8")

root = ET.fromstring(raw)
modified = False
for elem in root.findall("string"):
    if "chat_messages_cache" in elem.get("name", ""):
        try:
            msgs = json.loads(elem.text)
            cleaned = [m for m in msgs if m.get("id") != "wV6ZYf9WiscNO1w2XsSZ" and m.get("createdAt") is not None]
            elem.text = json.dumps(cleaned, ensure_ascii=False)
            modified = True
            print(f"Cleaned {len(msgs)} -> {len(cleaned)} messages in {elem.get('name')}")
        except Exception as ex:
            print("Error parsing:", ex)

if modified:
    new_xml = ET.tostring(root, encoding="utf-8").decode("utf-8")
    with open("temp_prefs.xml", "w", encoding="utf-8") as f:
        f.write(new_xml)
    
    subprocess.run([adb, "push", "temp_prefs.xml", "/data/local/tmp/prefs.xml"], check=True)
    subprocess.run([adb, "shell", "run-as", "com.example.progroup_ai_frontend", "cp", "/data/local/tmp/prefs.xml", "shared_prefs/FlutterSharedPreferences.xml"], check=True)
    print("Updated FlutterSharedPreferences.xml on device successfully!")
