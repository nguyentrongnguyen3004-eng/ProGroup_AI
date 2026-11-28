import zipfile
import io
import os

OUT_DIR = os.path.abspath("sample_import_files")

def fix_xlsx(path):
    zin = zipfile.ZipFile(path, 'r')
    buf = io.BytesIO()
    zout = zipfile.ZipFile(buf, 'w')
    for item in zin.infolist():
        content = zin.read(item.filename)
        if item.filename == 'xl/_rels/workbook.xml.rels':
            content = content.replace(b'Target="/xl/', b'Target="')
        zout.writestr(item, content)
    zin.close()
    zout.close()
    with open(path, 'wb') as f:
        f.write(buf.getvalue())
    print(f"Fixed {os.path.basename(path)}")

for f in os.listdir(OUT_DIR):
    if f.endswith('.xlsx'):
        fix_xlsx(os.path.join(OUT_DIR, f))

print("All xlsx files fixed for Dart excel compatibility!")
