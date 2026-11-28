import docx

doc = docx.Document('file_coso_v4.docx')
for i, t in enumerate(doc.tables[1:4], 1):
    print(f'Table {i}: style={t.style.name}, rows={len(t.rows)}, cols={len(t.columns)}')
    if len(t.rows) > 0:
        print('  header:', [c.text.strip().replace('\n', ' ') for c in t.rows[0].cells])
