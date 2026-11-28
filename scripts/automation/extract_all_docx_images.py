import docx, zipfile, os

def extract_all(docx_path, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    with zipfile.ZipFile(docx_path, 'r') as z:
        rels_xml = z.read('word/_rels/document.xml.rels').decode('utf-8')
        d = docx.Document(docx_path)
        for i, p in enumerate(d.paragraphs):
            txt = p.text.strip()
            if txt.startswith("Hình 4."):
                fig_num = txt.split('.')[0] + '.' + txt.split('.')[1]
                prev = d.paragraphs[i-1] if i > 0 else None
                rid = None
                if prev:
                    xml = prev._element.xml
                    b_idx = xml.find('r:embed="')
                    if b_idx != -1:
                        rid = xml[b_idx+9:xml.find('"', b_idx+9)]
                if rid:
                    r_pos = rels_xml.find(f'Id="{rid}"')
                    t_pos = rels_xml.find('Target="', r_pos)
                    target = rels_xml[t_pos+8:rels_xml.find('"', t_pos+8)]
                    img_data = z.read('word/' + target)
                    fname = f"{fig_num.replace(' ', '_').replace('.', '_')}.png"
                    out_path = os.path.join(out_dir, fname)
                    with open(out_path, 'wb') as f:
                        f.write(img_data)
                    print(f"Extracted {fig_num} -> {out_path} ({len(img_data)} bytes)")

extract_all('file_coso_v4_updated.docx', 'extracted_updated')
extract_all('file_coso_v4.docx', 'extracted_v4')
