import docx

doc = docx.Document('file_coso_v4_chuan_format.docx')

# Find the two occurrences of 'THIẾT KẾ CƠ SỞ DỮ LIỆU'
occ = []
for idx, p in enumerate(doc.paragraphs):
    if 'THIẾT KẾ CƠ SỞ DỮ LIỆU' in p.text:
        occ.append(idx)

print("Occurrences of THIẾT KẾ CƠ SỞ DỮ LIỆU:", occ)

if len(occ) == 2:
    # We want to remove paragraphs from occ[0] up to occ[1] - 1
    start_remove = occ[0]
    end_remove = occ[1]
    print(f"Removing paragraphs from {start_remove} to {end_remove - 1}...")
    
    # Also find if there is a table between them to remove
    # In python-docx, remove elements from parent
    for i in range(end_remove - 1, start_remove - 1, -1):
        p = doc.paragraphs[i]
        p._element.getparent().remove(p._element)

    # Save to file_coso_v4_chuan_format.docx
    doc.save('file_coso_v4_chuan_format.docx')
    print("Successfully removed duplicate 3.5!")
