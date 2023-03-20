import gdown
import json
import sys
import os

parent_location = sys.argv[1]
print(parent_location)
thredds_data_file= open('scripts/usa_thredds.json')

thredds_data_json =  json.load(thredds_data_file)
  
for key in thredds_data_json:
    final_destination_folder = parent_location + "/" + key
    print(f'Downloading {key} at {final_destination_folder} . . .')
    if os.path.exists(final_destination_folder):
        os.makedirs(final_destination_folder)
    gdown.download_folder(thredds_data_json[key], output= final_destination_folder,quiet=True,use_cookies=True)
    break
    
