import docx

doc = docx.Document('file_coso_v4_perfect.docx')
p190 = doc.paragraphs[190]
print("p190 drawing elements:", p190._element.xpath('.//w:drawing | .//w:pict'))

# Now find an actual image paragraph
for idx, p in enumerate(doc.paragraphs[188:], 188):
    drawings = p._element.xpath('.//w:drawing | .//w:pict')
    if len(drawings) > 0:
        print(f"Image paragraph found at {idx}: {drawings}")
        break
