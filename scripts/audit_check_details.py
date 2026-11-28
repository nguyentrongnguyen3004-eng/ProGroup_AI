import docx, re

doc = docx.Document('file_coso_v4_updated.docx')

print("=== CHECKING TYPOS & ANOMALIES ===")
for i, p in enumerate(doc.paragraphs):
    t = p.text
    for target in ["300Cloud", "Cloudfare", "URL.Một", "xin cảm gia đình", "vi ứng dụng", "Microsoft Microsoft"]:
        if target.lower() in t.lower():
            print(f"P{i} [target: {target}]: {t}")

print("\n=== CHECKING REFERENCES (Tài liệu tham khảo) ===")
ref_paras = []
found_ref = False
for i, p in enumerate(doc.paragraphs):
    if "TÀI LIỆU THAM KHẢO" in p.text.upper():
        found_ref = True
    if found_ref:
        ref_paras.append((i, p.text.strip()))

print(f"Total reference lines: {len(ref_paras)}")
for idx, t in ref_paras[:25]:
    if t:
        print(f"  P{idx}: {t}")

# Check citations in text vs references
text_all = " ".join([p.text for p in doc.paragraphs if "TÀI LIỆU THAM KHẢO" not in p.text.upper() and not found_ref])
citations = re.findall(r'\[(\d+)\]', text_all)
unique_cites = sorted(list(set(int(c) for c in citations)))
print(f"\nCitations found in body text ({len(unique_cites)}): {unique_cites}")
