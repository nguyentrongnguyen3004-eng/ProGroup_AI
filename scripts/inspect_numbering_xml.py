import zipfile
import xml.etree.ElementTree as ET

with zipfile.ZipFile('file_coso_v4_chuan_format.docx') as z:
    if 'word/numbering.xml' in z.namelist():
        print("--- word/numbering.xml exists ---")
        num_xml = z.read('word/numbering.xml').decode('utf-8')
        print(num_xml[:1500])
    else:
        print("No numbering.xml")

    styles_xml = z.read('word/styles.xml').decode('utf-8')
    root = ET.fromstring(styles_xml)
    for s in root.findall('.//{http://schemas.openxmlformats.org/wordprocessingml/2006/main}style'):
        s_id = s.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}styleId')
        if s_id in ['Heading1', 'Heading2', 'Heading3', 'Heading4']:
            print(f"\nStyle: {s_id}")
            numPr = s.find('.//{http://schemas.openxmlformats.org/wordprocessingml/2006/main}numPr')
            if numPr is not None:
                print("  numPr in style:", ET.tostring(numPr, encoding='unicode'))
            else:
                print("  No numPr in style")
