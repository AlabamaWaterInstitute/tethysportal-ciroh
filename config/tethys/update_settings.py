import json
import yaml
import argparse
import logging
import os

logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)
script_dir = os.path.dirname(__file__)
portal_config_path = os.path.join(script_dir, 'portal_config.yaml')
portal_change_path = os.path.join(script_dir, 'portal_changes.yaml')


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--linked_settings', nargs='+')
    parser.add_argument('--unlinked_settings', nargs='+')
    parser.add_argument('--app_name', nargs='+')
    args = parser.parse_args()
    return args

def validate_json_string(string):
    if "json_custom_setting" in string:
        string = string.replace("True", "true").replace("False", "false")
    return string


def check_for_json_setting(current_setting):
    setting_type = current_setting['Type']

    if setting_type == 'json_custom_setting':
        setting_new_value = current_setting.get('Linked With', {})
        setting_new_value = json.dumps(setting_new_value)
    else:
        setting_new_value = current_setting.get('Linked With', 'None')
    return setting_new_value

def update_state(array_string,app_name):
    for setting in array_string:
        try:
            json_setting = json.loads(validate_json_string(setting))
            logging.info(f'updating {json_setting["Name"]} setting')
            update_settings(json_setting, app_name)
        except:
            logging.warning(f'updating {json_setting["Name"]} setting not possible')

def change_single_setting(ymlportal,app_name,setting_name,setting_new_value):
    ymlportal['apps'] = ymlportal.get('apps', {})
    ymlportal['apps'][app_name] = ymlportal['apps'].get(app_name, {})
    ymlportal['apps'][app_name]['services'] = ymlportal['apps'][app_name].get('services', {})
    ymlportal['apps'][app_name]['services']['custom_settings'] = ymlportal['apps'][app_name]['services'].get('custom_settings', {})
    ymlportal['apps'][app_name]['services']['custom_settings'][setting_name] = setting_new_value

def update_settings(current_setting, app_name):
    with open(portal_config_path) as portal_configuration:
        #Update the current portal configuration yaml file using the tethys app_settings list
        ymlportal = yaml.safe_load(portal_configuration)
        settings_dict = ymlportal.get('apps',{}).get(f'{app_name}',{}).get('services',{}).get('custom_settings',{})
        setting_name = current_setting['Name']
        if not settings_dict is False:
            logging.info(f'{app_name} updating with the portal_config.yaml file')
            setting_new_value = check_for_json_setting(current_setting)
        # #Update using the portal changes yaml file
        with open(portal_change_path) as portal_changes:
            ymlportal_changes = yaml.safe_load(portal_changes)
            new_val_for_setting = ymlportal_changes.get('apps',{}).get(f'{app_name}',{}).get('services',{}).get('custom_settings',{}).get(setting_name,'None')
            if not new_val_for_setting is False:
                logging.info(f'{app_name} updating with the portal_change.yaml file')
                setting_new_value = new_val_for_setting
                if current_setting['Type'] == 'json_custom_setting':
                    setting_new_value = {}
        # logging.info(f'{setting_new_value}')

        change_single_setting(ymlportal,app_name,setting_name,setting_new_value)
    #write the new values of the setting
    # logging.info(f'{ymlportal}')
    
    with open(portal_config_path, "w") as portal_configuration:
        yaml.dump(ymlportal, portal_configuration)

# def update_settings_with_portal_change(current_setting, app_name):
def main():
    inputs=parse_args()
    # logging.info(f'{inputs.linked_settings}')
    if inputs.linked_settings:
        update_state(inputs.linked_settings, inputs.app_name[0])
    if inputs.unlinked_settings:
        update_state(inputs.unlinked_settings, inputs.app_name[0])

    return f'{inputs.app_name[0]} successfully updated'
if __name__ == '__main__':
    main()

