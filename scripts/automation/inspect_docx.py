import docx
import shutil

# Make backup first
shutil.copyfile('file_coso_v4.docx', 'file_coso_v4_backup.docx')
print('Created backup: file_coso_v4_backup.docx')

doc = docx.Document('file_coso_v4.docx')
print(f'Total paragraphs: {len(doc.paragraphs)}')
print(f'Total tables: {len(doc.tables)}')
for i in range(560, 595):
    p = doc.paragraphs[i]
    print(f'{i}: [{p.style.name}] "{p.text}"')
