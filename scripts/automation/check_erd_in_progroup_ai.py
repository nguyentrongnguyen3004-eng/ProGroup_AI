import docx

doc = docx.Document('ProGroup_AI.docx')
found_erd = []
for idx in range(370, 605):
    p = doc.paragraphs[idx]
    if 'CƠ SỞ DỮ LIỆU' in p.text or 'ERD' in p.text:
        found_erd.append((idx, p.style.name, p.text[:70]))

print(f"Found {len(found_erd)} matches in Chapter 3 of ProGroup_AI.docx:")
for idx, st, txt in found_erd:
    print(f"  [{idx}] {st}: {txt}")
