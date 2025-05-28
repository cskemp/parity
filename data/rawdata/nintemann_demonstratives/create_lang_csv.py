import pandas as pd
from get_lang_data import get_lang_dict

def create_long_form_data(region):
    # Get the language data for the specified region
    lang_data = get_lang_dict(region)
    
    # Initialize lists to store the data
    data = []
    
    # Process each language's data
    for language, lang_info in lang_data.items():
        for (type_, modality, relation), words in lang_info.items():
            for word in words:
                data.append({
                    'Language': language,
                    'Type': type_,
                    'Modality': modality,
                    'Relation': relation,
                    'Word': word,
                    'Region': region
                })
    
    # Convert to DataFrame
    df = pd.DataFrame(data)
    return df

def main():
    # List of all regions
    regions = ['africa', 'americas', 'asia', 'europe', 'oceania']
    
    # Process each region and combine the data
    all_data = []
    for region in regions:
        print(f"Processing {region}...")
        df = create_long_form_data(region)
        all_data.append(df)
    
    # Combine all data
    final_df = pd.concat(all_data, ignore_index=True)
    
    # Save to CSV
    output_file = 'nintemann_demonstratives.csv'
    final_df.to_csv(output_file, index=False)
    print(f"Data saved to {output_file}")
    
    # Print some basic statistics
    print(f"\nTotal languages: {final_df['Language'].nunique()}")
    print(f"Total demonstratives: {len(final_df)}")
    print(f"Total unique words: {final_df['Word'].nunique()}")

if __name__ == "__main__":
    main() 
