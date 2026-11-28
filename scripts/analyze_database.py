import json
import os
import re

def main():
    with open('docs/database/erd/raw_metadata.json', 'r', encoding='utf-8-sig') as f:
        meta = json.load(f)

    # Exclude system tables
    system_tables = {'__EFMigrationsHistory', 'sysdiagrams'}
    tables = [t for t in meta['Tables'] if t['TableName'] not in system_tables]
    
    print("=" * 80)
    print("PROGROUP AI - SQL SERVER METADATA AUDIT")
    print(f"Server: {meta['Server']} | Database: {meta['Database']} | Extract Time: {meta['ExtractTime']}")
    print(f"Total Tables (including system): {len(meta['Tables'])} | Business Tables: {len(tables)}")
    print("=" * 80)

    # Map tables
    table_map = {}
    for t in tables:
        tname = t['TableName']
        cols = [c for c in meta['Columns'] if c['TableName'] == tname]
        pks = [p['ColumnName'] for p in meta['PrimaryKeys'] if p['TableName'] == tname]
        fks_out = [fk for fk in meta['ForeignKeys'] if fk['ParentTable'] == tname]
        fks_in = [fk for fk in meta['ForeignKeys'] if fk['ReferencedTable'] == tname]
        idxs = [idx for idx in meta['Indexes'] if idx['TableName'] == tname and not idx['IsPrimaryKey']]
        
        table_map[tname] = {
            'info': t,
            'columns': cols,
            'pks': pks,
            'fks_out': fks_out,
            'fks_in': fks_in,
            'indexes': idxs
        }

    for tname, data in table_map.items():
        print(f"\nTABLE: {tname} (Rows: {data['info']['RowCount']})")
        print(f"  Primary Key: {', '.join(data['pks'])}")
        print(f"  Columns ({len(data['columns'])}):")
        for c in data['columns']:
            pk_flag = " [PK]" if c['ColumnName'] in data['pks'] else ""
            fk_matches = [fk for fk in data['fks_out'] if fk['ParentColumn'] == c['ColumnName']]
            fk_flag = f" [FK -> {fk_matches[0]['ReferencedTable']}.{fk_matches[0]['ReferencedColumn']}]" if fk_matches else ""
            id_flag = " [IDENTITY]" if c['IsIdentity'] else ""
            null_flag = "NULL" if c['IsNullable'] else "NOT NULL"
            
            # format type
            type_str = c['DataType']
            if c['MaxLength']:
                type_str += f"({c['MaxLength'] if c['MaxLength'] != -1 else 'max'})"
            elif c['Precision'] and c['Scale']:
                type_str += f"({c['Precision']},{c['Scale']})"
            elif c['Precision']:
                type_str += f"({c['Precision']})"
                
            def_str = f" DEFAULT {c['ColumnDefault']}" if c['ColumnDefault'] else ""
            print(f"    - {c['ColumnName']}: {type_str} {null_flag}{pk_flag}{fk_flag}{id_flag}{def_str}")

    print("\n" + "=" * 80)
    print("FOREIGN KEY RELATIONSHIPS (30 FKs):")
    print("=" * 80)
    for fk in meta['ForeignKeys']:
        if fk['ParentTable'] in system_tables or fk['ReferencedTable'] in system_tables:
            continue
        print(f"{fk['ForeignKeyName']}:")
        print(f"  {fk['ParentTable']}.{fk['ParentColumn']}  ===>  {fk['ReferencedTable']}.{fk['ReferencedColumn']} (Delete: {fk['DeleteRule']}, Update: {fk['UpdateRule']})")

if __name__ == '__main__':
    main()
