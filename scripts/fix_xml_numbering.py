import zipfile
import xml.etree.ElementTree as ET
import os, re
import docx
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls, qn

def fix_document_numbering(docx_path):
    print(f"Fixing numbering in {docx_path}...")
    
    # 1. Update numbering.xml inside docx to add lvlRestart
    temp_dir = 'temp_docx_extract'
    if os.path.exists(temp_dir):
        import shutil
        shutil.rmtree(temp_dir)
        
    with zipfile.ZipFile(docx_path, 'r') as z:
        z.extractall(temp_dir)

    num_path = os.path.join(temp_dir, 'word', 'numbering.xml')
    if os.path.exists(num_path):
        with open(num_path, 'r', encoding='utf-8') as f:
            xml_content = f.read()
            
        root = ET.fromstring(xml_content.encode('utf-8'))
        w_ns = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
        ns = {'w': w_ns}
        
        # In all abstractNum
        for ab in root.findall('w:abstractNum', ns):
            ab_id = ab.attrib.get(f'{{{w_ns}}}abstractNumId')
            for lvl in ab.findall('w:lvl', ns):
                ilvl = lvl.attrib.get(f'{{{w_ns}}}ilvl')
                lvlRestart = lvl.find('w:lvlRestart', ns)
                if ilvl == '1' and lvlRestart is None:
                    elem = ET.Element(f'{{{w_ns}}}lvlRestart', {f'{{{w_ns}}}val': '1'})
                    lvl.insert(1, elem)
                    print(f"Added lvlRestart val=1 to abstractNum {ab_id} Level 1")
                elif ilvl == '2' and lvlRestart is None:
                    elem = ET.Element(f'{{{w_ns}}}lvlRestart', {f'{{{w_ns}}}val': '2'})
                    lvl.insert(1, elem)
                    print(f"Added lvlRestart val=2 to abstractNum {ab_id} Level 2")
                elif ilvl == '3' and lvlRestart is None:
                    elem = ET.Element(f'{{{w_ns}}}lvlRestart', {f'{{{w_ns}}}val': '3'})
                    lvl.insert(1, elem)
                    print(f"Added lvlRestart val=3 to abstractNum {ab_id} Level 3")

        # Write back numbering.xml
        xml_str = ET.tostring(root, encoding='utf-8', xml_declaration=True)
        with open(num_path, 'wb') as f:
            f.write(xml_str)

        # Repackage docx
        with zipfile.ZipFile(docx_path, 'w', zipfile.ZIP_DEFLATED) as z_out:
            for root_d, dirs, files in os.walk(temp_dir):
                for file in files:
                    full_p = os.path.join(root_d, file)
                    rel_p = os.path.relpath(full_p, temp_dir)
                    z_out.write(full_p, rel_p)

        import shutil
        shutil.rmtree(temp_dir)
        print("numbering.xml updated and repacked successfully!")

    # 2. Now open with python-docx and ensure Chapter headings have correct numPr
    doc = docx.Document(docx_path)
    
    # Identify numId used by Heading 1 style
    h1_style = doc.styles['Heading 1']
    numPr_s = h1_style._element.xpath('.//w:numPr')
    target_numId = '15'
    if numPr_s:
        nid = numPr_s[0].find(qn('w:numId'))
        if nid is not None:
            target_numId = nid.attrib.get(qn('w:val'), '15')
    print(f"Using target_numId: {target_numId} for Chapter Headings")

    chapter_titles = {
        1: 'GIỚI THIỆU ĐỀ TÀI',
        2: 'CƠ SỞ LÝ THUYẾT',
        3: 'THIẾT KẾ HỆ THỐNG',
        4: 'CÀI ĐẶT HỆ THỐNG',
        5: 'KIỂM THỬ, TRIỂN KHAI VÀ ĐÁNH GIÁ HỆ THỐNG'
    }

    found_ch = 0
    for idx, p in enumerate(doc.paragraphs):
        txt_u = p.text.strip().upper()
        # Only chapters in the main body (idx > 200)
        if idx > 200 and any(title in txt_u for title in chapter_titles.values()) and found_ch < 5:
            found_ch += 1
            ch_num = found_ch
            title = chapter_titles[ch_num]
            print(f"Updating Chapter {ch_num} at [{idx}]: title='{title}'")
            
            p.style = doc.styles['Heading 1']
            p.text = title
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = docx.shared.Pt(18)
                r.font.bold = True
                r.font.color.rgb = docx.shared.RGBColor(0, 0, 0)
                
            pPr = p._element.get_or_add_pPr()
            for np in pPr.findall(qn('w:numPr')):
                pPr.remove(np)
            new_numPr = parse_xml(f'<w:numPr {nsdecls("w")}><w:ilvl w:val="0"/><w:numId w:val="{target_numId}"/></w:numPr>')
            pPr.append(new_numPr)

    doc.save(docx_path)
    print(f"Saved {docx_path} successfully!")

if __name__ == '__main__':
    fix_document_numbering('ProGroup_AI.docx')
    import shutil
    shutil.copy('ProGroup_AI.docx', 'file_coso_v4_chuan_format.docx')
    print("Copied to file_coso_v4_chuan_format.docx successfully!")
