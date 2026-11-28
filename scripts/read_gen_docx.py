with open('scripts/generate_docx_content.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()
print(f"Total lines in generate_docx_content.py: {len(lines)}")
for i in range(min(50, len(lines))):
    print(lines[i].rstrip())
