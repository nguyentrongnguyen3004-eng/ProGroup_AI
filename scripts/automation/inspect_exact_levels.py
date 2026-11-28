import zipfile
import xml.etree.ElementTree as ET

with zipfile.ZipFile('file_coso_v4_chuan_format.docx') as z:
    num_xml = z.read('word/numbering.xml').decode('utf-8')
    root = ET.fromstring(num_xml)
    
    for ab in root.findall('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}abstractNum'):
        if ab.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}abstractNumId') == '11':
            for lvl in ab.findall('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}lvl'):
                ilvl = lvl.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}ilvl')
                xml_str = ET.tostring(lvl, encoding='unicode')
                print(f"=== Level {ilvl} ===")
                print(xml_str)
