import json
import yaml
import argparse
import logging
import os
import pdb

logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)
script_dir = os.path.dirname(__file__)
portal_config_path = os.path.join(script_dir, 'portal_config.yaml')
portal_change_path = os.path.join(script_dir, 'portal_changes.yaml')
custom_settings_type = ['custom_settings', 'ds_spatial', 'ps_database','json_custom_setting','secret_custom_setting']

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--linked_settings', nargs='+')
    parser.add_argument('--unlinked_settings', nargs='+')
    parser.add_argument('--app_name', nargs='+')
    args = parser.parse_args()
    return args

def get_service(setting_type):
    service_type = 'custom_settings'

    if setting_type == 'ps_database':
        service_type = 'persistent'
    if service_type == 'ds_spatial':
        service_type = 'spatial'
    
    return service_type

def validate_setting(string):
    if "json_custom_setting" in string:
        string = string.replace("True", "true").replace("False", "false")
    return string


# def check_for_json_setting(current_setting):
def get_current_setting_val(current_setting):
    setting_type = current_setting['Type']
    setting_new_value = current_setting.get('Linked With', {})

    if setting_type == 'json_custom_setting':
        setting_new_value = json.dumps(setting_new_value)
    return setting_new_value

def update_state(array_string,app_name):
    for setting in array_string:
        try:
            json_setting = json.loads(validate_setting(setting))
            logging.info(f'updating {json_setting["Name"]} setting')
            update_settings(json_setting, app_name)
        except:
            logging.warning(f'updating {json_setting["Name"]} setting not possible')

def update_settings(current_setting, app_name):
    with open(portal_config_path) as portal_configuration:
        #Update the current portal configuration yaml file using the tethys app_settings list
        ymlportal = yaml.safe_load(portal_configuration)
        service_type = get_service(current_setting['Type'])
        settings_dict = ymlportal.get('apps',{}).get(f'{app_name}',{}).get('services',{}).get(service_type,{})
        setting_name = current_setting['Name']
        if settings_dict:
            logging.info(f'{setting_name} updating with the portal_config.yaml file')
            setting_new_value = get_current_setting_val(current_setting)
        # #Update using the portal changes yaml file
        with open(portal_change_path) as portal_changes:
            ymlportal_changes = yaml.safe_load(portal_changes)
            logging.info(f'{setting_name} updating with the portal_change.yaml file')
            setting_new_value = ymlportal_changes.get('apps',{}).get(f'{app_name}',{}).get('services',{}).get(service_type,{}).get(setting_name,{})
        
        change_single_setting(ymlportal,app_name,service_type,setting_name,setting_new_value)
    #write the new values of the setting    
    with open(portal_config_path, "w") as portal_configuration:
        yaml.dump(ymlportal, portal_configuration)

def change_single_setting(ymlportal,app_name,service_type,setting_name,setting_new_value):
    ymlportal['apps'] = ymlportal.get('apps', {})
    ymlportal['apps'][app_name] = ymlportal['apps'].get(app_name, {})
    ymlportal['apps'][app_name]['services'] = ymlportal['apps'][app_name].get('services', {})
    ymlportal['apps'][app_name]['services'][service_type] = ymlportal['apps'][app_name]['services'].get(service_type, {})
    if setting_new_value:
        logging.info(f'{setting_name} updating with {setting_new_value}')
        ymlportal['apps'][app_name]['services'][service_type][setting_name] = setting_new_value

def main():
    inputs=parse_args()
    if inputs.linked_settings:
        update_state(inputs.linked_settings, inputs.app_name[0])
    if inputs.unlinked_settings:
        update_state(inputs.unlinked_settings, inputs.app_name[0])

    return f'{inputs.app_name[0]} successfully updated'
if __name__ == '__main__':
    main()

