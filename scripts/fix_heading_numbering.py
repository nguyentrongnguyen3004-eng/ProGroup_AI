import docx
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls, qn
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

def fix_headings(src_path, dst_path):
    print(f"Fixing headings in {src_path} -> {dst_path}...")
    doc = docx.Document(src_path)

    # 1. First, fix the 2 ghost Heading 1 paragraphs that are just page breaks
    for p in doc.paragraphs:
        if p.style.name == 'Heading 1' and not p.text.strip():
            print(f"Removing Heading 1 style from empty page break paragraph: xml={p._element.xml[:80]}")
            p.style = doc.styles['Normal']
            pPr = p._element.get_or_add_pPr()
            # remove numPr if present
            for np in pPr.findall(qn('w:numPr')):
                pPr.remove(np)

    # 2. For each Chapter paragraph:
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
        if idx > 150 and (p.style.name == 'Heading 1' or any(txt_u.startswith(f'CHƯƠNG {k}') for k in range(1, 6))) and len(txt_u) < 120 and found_ch < 5:
            found_ch += 1
            ch_num = found_ch
            title = chapter_titles[ch_num]
            print(f"Fixing Chapter {ch_num} at [{idx}]: was '{p.text}' -> title='{title}'")
            
            p.style = doc.styles['Heading 1']
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.space_before = Pt(18)
            p.paragraph_format.space_after = Pt(12)
            p.paragraph_format.line_spacing = 1.3
            p.paragraph_format.first_line_indent = Cm(0)

            # Set paragraph text to title only
            p.text = title
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(18)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0, 0, 0)

            # Ensure numPr is ilvl 0, numId 19
            pPr = p._element.get_or_add_pPr()
            for np in pPr.findall(qn('w:numPr')):
                pPr.remove(np)
            new_numPr = parse_xml(f'<w:numPr {nsdecls("w")}><w:ilvl w:val="0"/><w:numId w:val="19"/></w:numPr>')
            pPr.append(new_numPr)

    # 3. Clean up our inserted Section 3.5 headings so they don't have hardcoded numbers
    for p in doc.paragraphs:
        if p.style.name == 'Heading 2':
            if p.text.startswith('3.5.'):
                p.text = p.text.replace('3.5.', '').strip()
                print(f"Cleaned Heading 2: was '3.5. ...' -> '{p.text}'")
        elif p.style.name == 'Heading 3':
            if p.text.startswith('3.5.1.'):
                p.text = p.text.replace('3.5.1.', '').strip()
                print(f"Cleaned Heading 3: was '3.5.1. ...' -> '{p.text}'")
            elif p.text.startswith('3.5.2.'):
                p.text = p.text.replace('3.5.2.', '').strip()
                print(f"Cleaned Heading 3: was '3.5.2. ...' -> '{p.text}'")

    doc.save(dst_path)
    print("Done saving fixed document!")

if __name__ == '__main__':
    fix_headings('file_coso_v4_chuan_format.docx', 'test_fixed_headings.docx')
