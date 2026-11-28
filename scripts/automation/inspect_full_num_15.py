import zipfile
import xml.etree.ElementTree as ET

with zipfile.ZipFile('ProGroup_AI.docx') as z:
    num_xml = z.read('word/numbering.xml').decode('utf-8')
    root = ET.fromstring(num_xml)
    
    for num in root.findall('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}num'):
        if num.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}numId') == '15':
            print("--- num 15 ---")
            print(ET.tostring(num, encoding='unicode'))

    for ab in root.findall('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}abstractNum'):
        if ab.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}abstractNumId') == '9':
            print("--- abstractNum 9 ---")
            for lvl in ab.findall('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}lvl'):
                print(ET.tostring(lvl, encoding='unicode'))
