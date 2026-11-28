import docx, re

def inspect_docx(filepath):
    print(f"=== INSPECTING: {filepath} ===")
    doc = docx.Document(filepath)
    print(f"Total paragraphs: {len(doc.paragraphs)}")
    print(f"Total tables: {len(doc.tables)}")

    # 1. Check Table of Contents / Mục lục
    print("\n--- 1. Check Mục lục ---")
    toc_paras = []
    found_toc = False
    for i, p in enumerate(doc.paragraphs[:100]):
        t = p.text.strip()
        if "MỤC LỤC" in t.upper():
            found_toc = True
        if found_toc:
            toc_paras.append((i, t))
            if "DANH MỤC" in t.upper() and len(toc_paras) > 5:
                break
    for idx, t in toc_paras[:35]:
        if t:
            print(f"  P{idx}: {t}")

    # Check if CHƯƠNG 4 or CHƯƠNG 5 are mentioned in TOC
    toc_text = " ".join([t for _, t in toc_paras])
    print(f"CHƯƠNG 4 in TOC: {'CHƯƠNG 4' in toc_text.upper() or 'CÀI ĐẶT' in toc_text.upper()}")
    print(f"CHƯƠNG 5 in TOC: {'CHƯƠNG 5' in toc_text.upper() or 'KIỂM THỬ' in toc_text.upper()}")

    # 2. Check Danh mục hình ảnh & Danh mục bảng
    print("\n--- 2. Check Danh mục hình ảnh & bảng ---")
    found_lof = False
    for i, p in enumerate(doc.paragraphs[:150]):
        t = p.text.strip()
        if "DANH MỤC HÌNH" in t.upper() or "DANH MỤC BẢNG" in t.upper():
            print(f"  Found list header P{i}: {t}")
        if "Hình 4." in t or "Bảng 5." in t or "Bảng 4." in t:
            print(f"  Found figure/table entry in front matter P{i}: {t}")

    # 3. Check for specific editorial sentences
    print("\n--- 3. Check editorial placeholders ---")
    editorial_patterns = [
        "Trình bày mô hình",
        "Nên mô tả rõ",
        "Sơ đồ nên thể hiện",
        "Mô tả chi tiết các tác nhân",
        "hướng dẫn",
        "Gợi ý:",
        "Lưu ý:"
    ]
    for i, p in enumerate(doc.paragraphs):
        t = p.text.strip()
        for ep in editorial_patterns:
            if ep.lower() in t.lower() and len(t) < 300:
                print(f"  [EDITORIAL MATCH] P{i}: {t}")

    # 4. Check for typos
    print("\n--- 4. Check specific typos ---")
    typos = [
        "xin cảm gia đình",
        "vi ứng dụng",
        "Microsoft Microsoft",
        "Firebase 300Cloud",
        "Cloudfare",
        "URL.Một",
        "ProGroup AI",
        "ProGroup_AI"
    ]
    for i, p in enumerate(doc.paragraphs):
        t = p.text
        for tp in typos:
            if tp.lower() in t.lower():
                print(f"  [TYPO/TERM MATCH '{tp}'] P{i}: {t[:120]}...")

    # 5. Check Group table at page 6 (early tables)
    print("\n--- 5. Check early tables (Group Workload etc.) ---")
    for t_idx, tbl in enumerate(doc.tables[:5]):
        print(f"\nTable {t_idx+1} rows={len(tbl.rows)}, cols={len(tbl.columns)}:")
        for r_idx, row in enumerate(tbl.rows[:5]):
            row_vals = [c.text.strip().replace('\n', ' ') for c in row.cells]
            print(f"  Row {r_idx}: {' | '.join(row_vals[:5])}")

    # 6. Check Use Case tables in Chapter 3
    print("\n--- 6. Check Use Case tables ---")
    uc_tables = 0
    for t_idx, tbl in enumerate(doc.tables):
        header_text = " ".join([c.text for c in tbl.rows[0].cells])
        if "Use Case" in header_text or "Tên Use Case" in header_text or "Mã Use Case" in header_text:
            uc_tables += 1
            print(f"  UC Table #{uc_tables} (Table {t_idx+1}): {header_text[:100]}")
    print(f"Total Use Case tables: {uc_tables}")

    # 7. Check Headings of Chapter 4 & 5
    print("\n--- 7. Check Headings in Document ---")
    for i, p in enumerate(doc.paragraphs):
        if p.style.name.startswith("Heading 1"):
            print(f"  [H1] P{i}: {p.text}")
        elif p.style.name.startswith("Heading 2") and ("Chương 4" in p.text or "Chương 5" in p.text or "Cài đặt" in p.text or "Kiểm thử" in p.text):
            print(f"  [H2] P{i}: {p.text}")

if __name__ == "__main__":
    # Check both files
    import os
    if os.path.exists("file_coso_v4_updated.docx"):
        inspect_docx("file_coso_v4_updated.docx")
    elif os.path.exists("file_coso_v4.docx"):
        inspect_docx("file_coso_v4.docx")
