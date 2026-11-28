import os

root_dir = 'ProGroup_AI_Frontend'
for root, dirs, files in os.walk(root_dir):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                lines = file.readlines()
                for i, line in enumerate(lines, 1):
                    if 'dateOfBirth' in line or 'NgaySinh' in line or 'ngaySinh' in line:
                        print(f"{path}:{i}: {line.strip()}")
