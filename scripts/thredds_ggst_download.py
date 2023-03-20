import gdown
import json
import sys
import os

parent_location = sys.argv[1]
print(parent_location)
# thredds_data_file= open('scripts/usa_thredds.json')
thredds_data_file= open('usa_ggst_regions.json')

thredds_data_json =  json.load(thredds_data_file)

list_ggst_essentials_files={
    "GRC_canopy":"18ry8RcbZhPMJrqAPRVWjxJPeIP_P35_1",
    "GRC_grace":"1FKDUDVV_Y3HUDMZDsjozq0U5Xh3syBVz",
    "GRC_gw":"1Uz9xROhHHdFDF7LFIAJJ81bYjT-d1PBi",
    "GRC_sm":"1g0PyIZYZsVj5Gy5RWyEIqzOVZ0M9BV7k",
    "GRC_sw":"1xMr8r3bdU91RQm8Ycvl0_Yy5Z2lLYGtu",
    "GRC_swe":"1lkVMFkchfps6yk8vU8LycsHPI922BDjc",
    "GRC_tws":"1hROfDyhTkwVTUHgJVfP3M_PGpO9LH6eY"
}

for file_id in list_ggst_essentials_files:
    if os.path.exists(parent_location):
        os.makedirs(parent_location)
    gdown.download(id=list_ggst_essentials_files[file_id], output=parent_location, quiet=False,use_cookies=True)

for key in thredds_data_json:
    final_destination_folder = parent_location + "/" + key
    print(f'Downloading {key} at {final_destination_folder} . . .')
    if os.path.exists(final_destination_folder):
        os.makedirs(final_destination_folder)
    gdown.download_folder(thredds_data_json[key], output= final_destination_folder,quiet=True,use_cookies=True)
    
    
