import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')
found_35 = False
for idx, p in enumerate(doc.paragraphs):
    if '3.5. THIẾT KẾ CƠ SỞ DỮ LIỆU' in p.text:
        found_35 = True
        print(f"[{idx}] {p.style.name}: {p.text}")
        for j in range(idx, min(idx + 30, len(doc.paragraphs))):
            pj = doc.paragraphs[j]
            drawings = pj._element.xpath('.//w:drawing | .//w:pict')
            has_img = f" [IMAGE {len(drawings)}]" if len(drawings) > 0 else ""
            print(f"  [{j}] {pj.style.name}: {pj.text[:65]}...{has_img}")
            if 'CHƯƠNG 4' in pj.text:
                break
        break

print("\nFound 3.5:", found_35)
