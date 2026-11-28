import os

keywords = ['ngày sinh', 'ngaysinh', 'dateofbirth', 'dob', '2005-01-15', 'calendar']

for root_dir in ['ProGroup_AI_Frontend', 'ProGroup_AI_Backend']:
    for root, dirs, files in os.walk(root_dir):
        if 'bin' in dirs: dirs.remove('bin')
        if 'obj' in dirs: dirs.remove('obj')
        if '.dart_tool' in dirs: dirs.remove('.dart_tool')
        if 'build' in dirs: dirs.remove('build')
        for f in files:
            if f.endswith(('.dart', '.cs', '.json')):
                path = os.path.join(root, f)
                try:
                    with open(path, 'r', encoding='utf-8') as file:
                        content = file.read()
                        for kw in keywords:
                            if kw in content.lower():
                                print(f"Found '{kw}' in {path}")
                                break
                except Exception:
                    pass
