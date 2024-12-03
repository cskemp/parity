import re
import csv

# Input and output files
input_file = "austkin_scrape.txt"
output_file = "output.csv"

# Define regex patterns to capture each part of the data
entry_pattern = re.compile(r"\*\*(\d+):\s*(.*?)\n([A-Za-z0-9]+)\n", re.DOTALL)

# Expanded category pattern to capture all listed categories
category_pattern = re.compile(
    r"(sections|underspecified sections|subsections|totems|matri-moieties|patri-moieties|generational moieties|matri-semi-moieties|patri-semi-moieties|phratries):\s*.*?\nTable.*?\n((?:\[.*?\][\n\r]*)*)",
    re.DOTALL
)

# Pattern to match each row within a table
#table_entry_pattern = re.compile(r"\[(?:'|\").*?(?:'|\")\]")
table_entry_pattern = re.compile(r"\[.*?\]")






# Prepare list to store rows for CSV output
data_rows = []

with open(input_file, "r", encoding="utf-8") as file:
    content = file.read()

    # Split content by each entry
    entries = re.split(r"\*\*(\d+):", content)[1:]

    # Iterate over each entry
    for i in range(0, len(entries), 2):
        lang_id = entries[i].strip()
        lang_data = entries[i + 1]

        # Capture the language name and code
        lang_name_match = entry_pattern.search(f"**{lang_id}: {lang_data}")
        if lang_name_match:
            lang_name = lang_name_match.group(2).strip()
            lang_code = lang_name_match.group(3).strip()

        # Find all categories within this language entry
        categories = category_pattern.findall(lang_data)

        # Process each category and count table rows
        for category, table_data in categories:
            num_entries = len(table_entry_pattern.findall(table_data)) if table_data else 0
            data_rows.append([lang_id, lang_name, lang_code, category.strip(), num_entries])

# Write parsed data to CSV
with open(output_file, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["ID", "Name", "Code", "Category", "NumEntries"])
    writer.writerows(data_rows)

print(f"Data has been written to {output_file}")


