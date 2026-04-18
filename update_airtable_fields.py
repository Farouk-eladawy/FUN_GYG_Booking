import os
import csv
import requests
import json
import random
import string
from dotenv import load_dotenv
from pathlib import Path
from urllib.parse import quote

# Load environment variables
env_path = Path(__file__).parent / "config" / ".env"
load_dotenv(env_path)

def update_airtable_fields():
    csv_path = Path(__file__).parent / "Airtable Fields.csv"
    api_key = os.getenv("AIRTABLE_API_KEY")
    base_id = os.getenv("AIRTABLE_BASE_ID")
    table_name = os.getenv("AIRTABLE_TABLE", "Tito Sunny")
    
    if not api_key or not base_id:
        print("Missing AIRTABLE_API_KEY or AIRTABLE_BASE_ID in .env")
        return
        
    print(f"Connecting to Airtable base: {base_id}, table: {table_name}")
    
    # 1. Read existing CSV
    existing_fields = {}
    if csv_path.exists():
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                existing_fields[row['name']] = row
    
    print(f"Found {len(existing_fields)} existing fields in CSV.")

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    # 2. Try fetching schema from Meta API first (requires personal access token with schema.bases:read)
    meta_url = f"https://api.airtable.com/v0/meta/bases/{base_id}/tables"
    r_meta = requests.get(meta_url, headers=headers)
    
    new_fields_to_add = []
    
    if r_meta.status_code == 200:
        print("Successfully fetched schema using Meta API!")
        tables = r_meta.json().get('tables', [])
        target_table = next((t for t in tables if t['name'] == table_name), None)
        
        if target_table:
            fields = target_table.get('fields', [])
            for fld in fields:
                if fld['name'] not in existing_fields:
                    new_fields_to_add.append({
                        'id': fld['id'],
                        'name': fld['name'],
                        'type': fld['type']
                    })
        else:
            print(f"Table '{table_name}' not found in Meta API response.")
            return
    else:
        print("Meta API access denied or unavailable. Falling back to records probe method...")
        # 3. Fallback: Probe records to discover fields
        api_url = f"https://api.airtable.com/v0/{base_id}/{quote(table_name)}"
        params = {"maxRecords": 100}
        r_records = requests.get(api_url, headers=headers, params=params)
        
        if r_records.status_code == 200:
            data = r_records.json()
            records = data.get("records", [])
            found_fields = set()
            for rec in records:
                for k in rec.get("fields", {}).keys():
                    found_fields.add(k)
                    
            for fld_name in found_fields:
                if fld_name not in existing_fields:
                    # Generate a dummy field ID for the CSV
                    dummy_id = "fld" + "".join(random.choices(string.ascii_letters + string.digits, k=14))
                    new_fields_to_add.append({
                        'id': dummy_id,
                        'name': fld_name,
                        'type': 'singleLineText' # default guess
                    })
        else:
            print(f"Error fetching records: {r_records.status_code} - {r_records.text}")
            return
            
    # 4. Update CSV
    if new_fields_to_add:
        print(f"Found {len(new_fields_to_add)} NEW fields! Updating CSV...")
        file_is_empty = not csv_path.exists() or csv_path.stat().st_size == 0
        
        with open(csv_path, 'a', encoding='utf-8', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=['id', 'name', 'type'])
            if file_is_empty:
                writer.writeheader()
            for nf in new_fields_to_add:
                writer.writerow(nf)
                print(f"  + Added: {nf['name']} ({nf['type']})")
        print("CSV update complete.")
    else:
        print("No new fields found. CSV is up to date.")

if __name__ == "__main__":
    update_airtable_fields()
