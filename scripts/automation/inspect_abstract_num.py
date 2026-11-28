import zipfile
import xml.etree.ElementTree as ET

with zipfile.ZipFile('file_coso_v4_chuan_format.docx') as z:
    num_xml = z.read('word/numbering.xml').decode('utf-8')
    root = ET.fromstring(num_xml)
    
    # find num with numId="19"
    abstract_num_id = None
    for num in root.findall('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}num'):
        if num.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}numId') == '19':
            ab = num.find('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}abstractNumId')
            abstract_num_id = ab.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val')
            print(f"numId 19 maps to abstractNumId: {abstract_num_id}")
            break
            
    if abstract_num_id:
        for ab in root.findall('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}abstractNum'):
            if ab.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}abstractNumId') == abstract_num_id:
                for lvl in ab.findall('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}lvl'):
                    ilvl = lvl.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}ilvl')
                    lvlText = lvl.find('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}lvlText')
                    lvlRestart = lvl.find('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}lvlRestart')
                    txt = lvlText.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val') if lvlText is not None else None
                    restart = lvlRestart.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val') if lvlRestart is not None else None
                    print(f"Level {ilvl}: lvlText='{txt}', lvlRestart='{restart}'")
