import docx

doc = docx.Document('test_fixed_headings.docx')

# Simulate Word's multilevel list engine for abstractNum 11 (numId 19)
# Level 0: CHƯƠNG %1:
# Level 1: %1.%2.
# Level 2: %1.%2.%3.
# Level 3: %1.%2.%3.%4

counters = [0] * 9

for idx, p in enumerate(doc.paragraphs):
    st = p.style.name
    numPr = p._element.xpath('.//w:numPr')
    
    # Check if style or p has numId 19
    ilvl = None
    if st == 'Heading 1' and not (numPr and numPr[0].find('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}numId').attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val') == '0'):
        ilvl = 0
    elif st == 'Heading 2':
        ilvl = 1
    elif st == 'Heading 3':
        ilvl = 2
    elif st == 'Heading 4':
        ilvl = 3

    if ilvl is not None and idx > 150:
        counters[ilvl] += 1
        # reset lower levels
        for k in range(ilvl + 1, 9):
            counters[k] = 0

        if ilvl == 0:
            prefix = f"CHƯƠNG {counters[0]}: "
        elif ilvl == 1:
            prefix = f"{counters[0]}.{counters[1]}. "
        elif ilvl == 2:
            prefix = f"{counters[0]}.{counters[1]}.{counters[2]}. "
        elif ilvl == 3:
            prefix = f"{counters[0]}.{counters[1]}.{counters[2]}.{counters[3]} "

        indent = "  " * ilvl
        print(f"{indent}{prefix}{p.text[:50]}")
