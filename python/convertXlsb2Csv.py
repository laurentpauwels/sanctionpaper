import os
import zipfile
import pandas as pd

# Make sure path is correct. 
os.getcwd
os.chdir('./python')

def convert_xlsb_to_csv(input_file, output_file):
    df = pd.read_excel(input_file, engine='pyxlsb')
    df.to_csv(output_file, index=False)

# Path to the zip folder
zip_folder_path = "../matlab/data/raw/WIOD/WIOTS_in_EXCEL.zip"

# Extract the files from the zip folder
with zipfile.ZipFile(zip_folder_path, 'r') as zip_ref:
    zip_ref.extractall("../matlab/data/raw/WIOD/WIOT16")

# Directory containing the extracted files
extracted_files_dir = "../matlab/data/raw/WIOD/WIOT16"

# Iterate over the files in the directory
for file_name in os.listdir(extracted_files_dir):
    if file_name.endswith(".xlsb"):
        input_file = os.path.join(extracted_files_dir, file_name)
        output_file = os.path.splitext(input_file)[0] + ".csv"
        convert_xlsb_to_csv(input_file, output_file)
        os.remove(input_file)  # Delete the extracted .xlsb file

# Remove the directory containing the extracted files
#os.rmdir(extracted_files_dir)
