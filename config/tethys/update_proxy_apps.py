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
    query = 'insert into tethys_apps_proxyapp (id,name,endpoint,logo_url,description,tags,enabled,show_in_apps_library,\"order\",back_url,open_in_new_tab) VALUES '
    try:
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
                app_order=proxy_apps[proxy_app]['order']
                back_url=proxy_apps[proxy_app]['back_url']
                open_new_tab=proxy_apps[proxy_app]['open_in_new_tab']

                query+=f"({counter_id}, '{app_name}', '{endpoint}', '{logo_url}', '{description}', '{tags}', '{enabled}', '{show_in_apps_library}', '{app_order}', '{back_url}', '{open_new_tab}'),"
                counter_id+=1
            if query != 'insert into tethys_apps_proxyapp (id,name,endpoint,logo_url,description,tags,enabled,show_in_apps_library,\"order\",back_url,open_in_new_tab) VALUES ':
                query = replace_last(query,',',';')
    except Exception as e:
        logging.error(f'{e}')
    return query

def create_sql_update_query():
    query = ''
    # query_last_part = ' where name in ( '
    try:
        with open(portal_change_path) as portal_changes:
            ymlportal_changes = yaml.safe_load(portal_changes)
            proxy_apps = ymlportal_changes.get('proxy_apps',{})
            for proxy_app in proxy_apps:
                query += 'update tethys_apps_proxyapp set '
                for setting in proxy_apps[proxy_app]:
                    setting_to_update = proxy_apps[proxy_app].get(setting,{})
                    if setting_to_update:
                        # query+=f'{setting}'
                        # query+='(case '
                        # query_last_part += f"'{proxy_apps[proxy_app]['name']}',"
                        if setting == 'order':
                            # query+=f"\"{setting}\" when name = {proxy_apps[proxy_app]['name']} then'{setting_to_update}', "
                            query+=f"\"{setting}\" = '{setting_to_update}', "
                        else:
                            # query+=f"{setting} = when name = {proxy_apps[proxy_app]['name']} then'{setting_to_update}', "
                            query+=f"{setting} = '{setting_to_update}', "

                query = replace_last(query,',','')
            # query_last_part = replace_last(query_last_part,',','')
            # query += 'end) '
            # query_last_part += ')'
            # query = query + query_last_part
                query += f"where name = '{proxy_apps[proxy_app]['name']}';"
    except Exception as e:
        logging.error(f'{e}')
    return query

#check if there is already rows in tethys_apps_proxyapp table, so we can choose between update and insert records
def check_for_proxy_apps(database):
    database.execute("select exists(select * from information_schema.tables where table_name=%s)", ('tethys_apps_proxyapp',))
    return database.fetchone()[0]

def update_state(database):
    is_first_time = check_for_proxy_apps(database)
    query=''
    if not is_first_time:
        query+=create_sql_insert_query()
    else:
        query+=create_sql_update_query()

    logging.info(f'{query}')
    try:
        if query != '' and query != 'insert into tethys_apps_proxyapp (id,name,endpoint,logo_url,description,tags,enabled,show_in_apps_library,\"order\",back_url,open_in_new_tab) VALUES ':
            database.execute(query)
    except Exception as e:
        logging.error(f'{e}')
    pass

def main():
    yaml.add_implicit_resolver("!envvar", _tag_matcher, None, yaml.SafeLoader)
    yaml.add_constructor("!envvar", _path_constructor, yaml.SafeLoader)    
    conn = psycopg2.connect(host=f'{TETHYS_DB_HOST}', port = f'{TETHYS_DB_PORT}', database=f'{TETHYS_DB_NAME}', user="postgres", password=f'{POSTGRES_PASSWORD}')
    cur = conn.cursor()
    update_state(cur)
    conn.commit()
    cur.close()
    conn.close()
if __name__ == '__main__':
    main()
