import zipfile, os, shutil, docx

def update_docx_images(src_docx, dest_docx):
    print(f"Reading from {src_docx} and generating {dest_docx}...")
    if not os.path.exists(src_docx):
        print(f"File {src_docx} not found.")
        return

    # Find mapping of figure number to target media image
    fig_to_target = {}
    with zipfile.ZipFile(src_docx, 'r') as z:
        rels_xml = z.read('word/_rels/document.xml.rels').decode('utf-8')
        d = docx.Document(src_docx)
        for i, p in enumerate(d.paragraphs):
            txt = p.text.strip()
            if txt.startswith("Hình 4."):
                parts = txt.split('.')
                try:
                    fig_num = int(parts[1].strip().split()[0])
                except:
                    continue
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
                    fig_to_target[fig_num] = 'word/' + target

    # Write directly to dest_docx
    with zipfile.ZipFile(src_docx, 'r') as zin, zipfile.ZipFile(dest_docx, 'w', compression=zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            matched_fig = None
            for fnum, tpath in fig_to_target.items():
                if item.filename == tpath:
                    matched_fig = fnum
                    break
            
            if matched_fig:
                src_perfect = f"perfect_screenshots/Hình_4_{matched_fig}.png"
                with open(src_perfect, 'rb') as pf:
                    data = pf.read()
                zout.writestr(item, data)
                print(f"  Replaced {item.filename} with Hình 4.{matched_fig} ({len(data)} bytes)")
            else:
                zout.writestr(item, zin.read(item.filename))

    print(f"Successfully generated {dest_docx} ({os.path.getsize(dest_docx)} bytes)!\n")

if __name__ == '__main__':
    # Generate perfect docx
    update_docx_images('file_coso_v4_updated.docx', 'file_coso_v4_perfect.docx')
    update_docx_images('file_coso_v4.docx', 'file_coso_v4_final.docx')
