import json
import yaml
import logging
import os
import re
from typing import Any

logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)
# script_dir = os.path.dirname(__file__)
script_dir = os.environ['TETHYS_PERSIST']


portal_change_path = os.path.join(script_dir, 'portal_changes.yml')

# env_pattern = re.compile(r".*?\${(.*?)}.*?")

_var_matcher = re.compile(r"\${([^}^{]+)}")
_tag_matcher = re.compile(r"[^$]*\${([^}^{]+)}.*")


def _path_constructor(_loader: Any, node: Any):
    def replace_fn(match):
        envparts = f"{match.group(1)}:".split(":")
        return os.environ.get(envparts[0], envparts[1])
    return _var_matcher.sub(replace_fn, node.value)


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
            update_settings(json_setting, app_name)
        except:
            logging.error(f'updating {json_setting["Name"]} setting not possible')

def update_settings(current_setting, app_name):

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
        ymlportal['apps'][app_name]['services'][service_type][setting_name] = setting_new_value

def main():
    yaml.add_implicit_resolver("!envvar", _tag_matcher, None, yaml.SafeLoader)
    yaml.add_constructor("!envvar", _path_constructor, yaml.SafeLoader)    


if __name__ == '__main__':
    main()
