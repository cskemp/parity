from selenium import webdriver
from bs4 import BeautifulSoup
import time
import re 


# List of IDs
ids = [418, 972]  # add your IDs here

with open('austkin_ids.txt', 'r') as file:
    ids = [line.strip() for line in file if line.strip().isdigit()]

# Base URL for the pages
base_url = "http://www.austkin.net/index.php?loc=language&id="

driver = webdriver.Chrome()  # Or provide path like webdriver.Chrome('/path/to/chromedriver')

# Loop over each ID
for id in ids:
    print(f"**{id}:")

    # Construct the URL for the specific ID
    url = f"{base_url}{id}"
    driver.get(url)

    # Wait for the page to load
    time.sleep(5)  # Adjust based on loading speed
    soup = BeautifulSoup(driver.page_source, 'html.parser')


    # Extract and print the <h1> title text
    h1_title = soup.find("h1")
    if h1_title:
        print(f"{h1_title.get_text(strip=True)}")
    else:
        print("-----")

    # Extract and print the AIATSIS Language code
    aiatsis_text = soup.find(text=re.compile("AIATSIS Language code:"))
    if aiatsis_text:
        # Extract the code following the label
        code_match = re.search(r"AIATSIS Language code:\s*(\w+)", aiatsis_text)
        if code_match:
            aiatsis_code = code_match.group(1)
            print(f"{aiatsis_code}")
        else:
            print("++++++++++++")
    else:
        print("++++++++++++")

    try:
        # Find and click the link
        #link = driver.find_element("xpath", "//span[@class='linkType' and contains(text(), 'matri-moieties')]")
        #links = driver.find_elements("xpath", "//span[@class='linkType' and (contains(text(), 'matri-moieties') or contains(text(), 'totems'))]")
        links = driver.find_elements("xpath", "//span[@class='linkType' and (contains(text(), 'generational moieties') or contains(text(), 'matri-moieties') or contains(text(), 'matri-semi-moieties') or contains(text(), 'patri-moieties') or contains(text(), 'patri-semi-moieties') or contains(text(), 'phratries') or contains(text(), 'sections') or contains(text(), 'underspecified sections') or contains(text(), 'subsections') or contains(text(), 'totems'))]")

        for link_num, link in enumerate(links, start=1):
            link_text = link.text
            print(f"{link_text}: Link {link_num}")

            # Scroll to the link (if needed) and click it
            driver.execute_script("arguments[0].scrollIntoView();", link)
            link.click()
        
            # Wait for the AJAX content to load
            time.sleep(6)  # Adjust based on loading speed

            # Get page source after the AJAX call and parse it with BeautifulSoup
            soup = BeautifulSoup(driver.page_source, 'html.parser')
            
            # Find the table with the specific attributes
            tables = soup.find_all("table", {"class": "kin_terms"})

            if tables:
            # Iterate over each table found
                for table_num, table in enumerate(tables, start=1):
                    print(f"Table {table_num} on page {url}")
                    # Process each row in the table
                    for row in table.find_all("tr"):
                        cells = [cell.get_text(strip=True) for cell in row.find_all(["td", "th"])]
                        print(cells)  # Process the cell data as needed
            else:
                print(f"No tables found on page {url}")
    
    except Exception as e:
        print(f"Error on page {url}: {e}")

# Close the WebDriver
driver.quit()

