import docx, zipfile, os, sys
import xml.etree.ElementTree as ET

def audit_docx(docx_path):
    print(f"==================================================")
    print(f"AUDITING DOCX: {docx_path}")
    print(f"==================================================")
    if not os.path.exists(docx_path):
        print("File does not exist!")
        return

    os.makedirs('temp_extracted', exist_ok=True)
    with zipfile.ZipFile(docx_path, 'r') as z:
        doc_xml = z.read('word/document.xml').decode('utf-8')
        rels_xml = z.read('word/_rels/document.xml.rels').decode('utf-8')

        # Find all figures
        d = docx.Document(docx_path)
        for i, p in enumerate(d.paragraphs):
            txt = p.text.strip()
            if txt.startswith("Hình 4."):
                # Find preceding paragraph graphic
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
                    fname = f"{txt[:8].replace(' ', '_').replace('.', '_')}.png"
                    out_path = os.path.join('temp_extracted', fname)
                    with open(out_path, 'wb') as f:
                        f.write(img_data)
                    print(f"Found: {txt:<65} | Target: {target:<20} | Bytes: {len(img_data):>7} | Saved: {out_path}")
                else:
                    print(f"Found: {txt:<65} | NO IMAGE ATTACHED!")

if __name__ == '__main__':
    audit_docx('file_coso_v4_updated.docx')
    audit_docx('file_coso_v4.docx')
