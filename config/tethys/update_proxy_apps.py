import yaml
import logging
import os
import re
from typing import Any
import psycopg2


logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)
script_dir = os.environ['TETHYS_PERSIST']
TETHYS_DB_HOST = os.environ['TETHYS_DB_HOST']
TETHYS_DB_PORT = os.environ['TETHYS_DB_PORT']
# TETHYS_DB_USERNAME = os.environ['TETHYS_DB_USERNAME']
# TETHYS_DB_PASSWORD = os.environ['TETHYS_DB_PASSWORD']
# TETHYS_DB_SUPERUSER = os.environ['TETHYS_DB_SUPERUSER']
# TETHYS_DB_SUPERUSER_PASS = os.environ['TETHYS_DB_SUPERUSER_PASS']
TETHYS_DB_NAME = os.environ['TETHYS_DB_NAME']
POSTGRES_PASSWORD = os.environ['POSTGRES_PASSWORD']

portal_change_path = os.path.join(script_dir, 'portal_changes.yml')

_var_matcher = re.compile(r"\${([^}^{]+)}")
_tag_matcher = re.compile(r"[^$]*\${([^}^{]+)}.*")


def _path_constructor(_loader: Any, node: Any):
    def replace_fn(match):
        envparts = f"{match.group(1)}:".split(":")
        return os.environ.get(envparts[0], envparts[1])
    return _var_matcher.sub(replace_fn, node.value)

def replace_last(string, delimiter, replacement):
    start, _, end = string.rpartition(delimiter)
    return start + replacement + end

def create_sql_insert_query():
    query = 'insert into tethys_apps_proxyapp (id,name,endpoint,logo_url,description,tags,enabled,show_in_apps_library,\"order\",back_url,open_in_new_tab) VALUES'
    
    with open(portal_change_path) as portal_changes:
        ymlportal_changes = yaml.safe_load(portal_changes)
        # logging.info(f'{setting_name} updating with the portal_change.yaml file')
        proxy_apps = ymlportal_changes.get('proxy_apps',{})
        counter_id = 1
        for proxy_app in proxy_apps:
            app_name=proxy_apps[proxy_app]['name']
            endpoint=proxy_apps[proxy_app]['endpoint']
            logo_url=proxy_apps[proxy_app]['logo_url']
            description=proxy_apps[proxy_app]['description']
            tags=proxy_apps[proxy_app]['tags']
            enabled=proxy_apps[proxy_app]['enabled']
            show_in_apps_library=proxy_apps[proxy_app]['show_in_apps_library']
            app_order=proxy_apps[proxy_app]['app_order']
            back_url=proxy_apps[proxy_app]['back_url']
            open_new_tab=proxy_apps[proxy_app]['open_new_tab']

            query+=f"({counter_id}, '{app_name}', '{endpoint}', '{logo_url}', '{description}', '{tags}', '{enabled}', '{show_in_apps_library}', '{app_order}', '{back_url}', '{open_new_tab}'),"
            counter_id+=1
        query = replace_last(query,',',';')   
    
    return query

def create_sql_update_query():
    query = 'udpate tethys_apps_proxyapp'
    with open(portal_change_path) as portal_changes:
        ymlportal_changes = yaml.safe_load(portal_changes)
        proxy_apps = ymlportal_changes.get('proxy_apps',{})
        for proxy_app in proxy_apps:
            for setting in proxy_apps[proxy_app]:
                setting_to_update = proxy_apps[proxy_app][setting]
                if setting_to_update:
                    query+=f'set {setting}={setting_to_update}'
        query += f'where name={proxy_app}'   
    
    return query

#check if there is already rows in tethys_apps_proxyapp table, so we can choose between update and insert records
def check_for_proxy_apps(database):
    is_there_proxy_apps = database.execute("select exists(select * from information_schema.tables where table_name=%s)", ('tethys_apps_proxyapp',))
    return is_there_proxy_apps

def update_state(database):
    is_first_time = check_for_proxy_apps(database)
    sql_query=''
    if is_first_time:
        sql_query+=create_sql_insert_query()
    else:
        sql_query+=create_sql_update_query()
    database.execute(sql_query)
    

def main():
    yaml.add_implicit_resolver("!envvar", _tag_matcher, None, yaml.SafeLoader)
    yaml.add_constructor("!envvar", _path_constructor, yaml.SafeLoader)    
    conn = psycopg2.connect(host=f'{TETHYS_DB_HOST}', port = f'{TETHYS_DB_HOST}', database=f'{TETHYS_DB_NAME}', user="postgres", password=f'{POSTGRES_PASSWORD}')
    cur = conn.cursor()
    update_state(cur)
    cur.close()
    conn.close()
if __name__ == '__main__':
    main()
