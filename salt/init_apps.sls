{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}
{% set TETHYS_HOME = salt['environ.get']('TETHYS_HOME') %}
{% set CONDA_HOME = salt['environ.get']('CONDA_HOME') %}
{% set CONDA_ENV_NAME = salt['environ.get']('CONDA_ENV_NAME') %}

{% set FILE_UPLOAD_MAX_MEMORY_SIZE = salt['environ.get']('FILE_UPLOAD_MAX_MEMORY_SIZE') %}
{% set CHANNEL_LAYERS_BACKEND = salt['environ.get']('CHANNEL_LAYERS_BACKEND') %}
{% set CHANNEL_LAYERS_CONFIG = salt['environ.get']('CHANNEL_LAYERS_CONFIG') %}

{% set MDE_DISCLAIMER_HEADER = salt['environ.get']('MDE_DISCLAIMER_HEADER') %}
{% set MDE_DISCLAIMER_MESSAGE = salt['environ.get']('MDE_DISCLAIMER_MESSAGE') %}
{% set MDE_SERVER_HOME_DIRECTORY = salt['environ.get']('HOME') %}

{% set THREDDS_TDS_PUBLIC_PROTOCOL = salt['environ.get']('THREDDS_TDS_PUBLIC_PROTOCOL') %}
{% set THREDDS_TDS_PUBLIC_HOST = salt['environ.get']('THREDDS_TDS_PUBLIC_HOST') %}
{% set THREDDS_TDS_PUBLIC_PORT = salt['environ.get']('THREDDS_TDS_PUBLIC_PORT') %}

{% set GRACE_THREDDS_CATALOG = salt['environ.get']('GRACE_THREDDS_CATALOG')%}
{% set GRACE_THREDDS_CATALOG_PATH = THREDDS_TDS_PUBLIC_PROTOCOL +'://' + THREDDS_TDS_PUBLIC_HOST + ':' + THREDDS_TDS_PUBLIC_PORT + GRACE_THREDDS_CATALOG %}

{% set GRACE_THREDDS_DIRECTORY_RELATIVE_PATH = salt['environ.get']('GRACE_THREDDS_DIRECTORY_RELATIVE_PATH') %}
{% set GRACE_THREDDS_DIRECTORY_PATH = TETHYS_PERSIST + GRACE_THREDDS_DIRECTORY_RELATIVE_PATH %}

{% set CONDA_PYTHON_PATH = CONDA_HOME + "/envs/" + CONDA_ENV_NAME + '/bin/python'%}
{% set EARTHDATA_USERNAME = salt['environ.get']('EARTHDATA_USERNAME')%}
{% set EARTHDATA_PASS = salt['environ.get']('EARTHDATA_PASS')%}

{% set ENCRYPTION_KEY = salt['environ.get']('ENCRYPTION_KEY')%}
{% set STORES_JSON_STRING = salt['environ.get']('STORES_JSON_STRING')%}


{% set POSTGIS_SERVICE_NAME = 'tethys_postgis' %}


Pre_Apps_Settings:
  cmd.run:
    - name: cat {{ TETHYS_HOME }}/portal_config.yml
    - shell: /bin/bash

Set_Tethys_Settings_For_Apps:
  cmd.run:
    - name: >
        tethys settings  --set FILE_UPLOAD_MAX_MEMORY_SIZE {{ FILE_UPLOAD_MAX_MEMORY_SIZE }} &&
        tethys settings  --set DATA_UPLOAD_MAX_MEMORY_SIZE {{ FILE_UPLOAD_MAX_MEMORY_SIZE }} &&
        tethys settings --set DATA_UPLOAD_MAX_NUMBER_FIELDS {{ FILE_UPLOAD_MAX_MEMORY_SIZE }}
    - unless: /bin/bash -c "[ -f "${TETHYS_PERSIST}/init_apps_setup_complete" ];"

Sync_Apps:
  cmd.run:
    - name: tethys db sync
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/init_apps_setup_complete" ];"

Set_Custom_Settings:
  cmd.run:
    - name: >
        tethys app_settings set metdataexplorer disclaimer_header "{{ MDE_DISCLAIMER_HEADER }}" &&
        tethys app_settings set metdataexplorer disclaimer_message "{{ MDE_DISCLAIMER_MESSAGE }}" &&
        tethys app_settings set metdataexplorer server_home_directory {{ MDE_SERVER_HOME_DIRECTORY }} &&
        tethys app_settings set ggst grace_thredds_directory {{ GRACE_THREDDS_DIRECTORY_PATH }} &&
        tethys app_settings set ggst grace_thredds_catalog {{ GRACE_THREDDS_CATALOG_PATH }} &&
        tethys app_settings set ggst global_output_directory {{ TETHYS_PERSIST }} &&
        tethys app_settings set ggst earthdata_username {{ EARTHDATA_USERNAME }} &&
        tethys app_settings set ggst earthdata_pass {{ EARTHDATA_PASS }} &&
        tethys app_settings set ggst conda_python_path {{ CONDA_PYTHON_PATH }} &&
        tethys app_settings set app_store encryption_key {{ ENCRYPTION_KEY }} &&
        tethys app_settings set app_store stores_settings $(echo "{{ STORES_JSON_STRING }}" | base64 --decode)
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/init_apps_setup_complete" ];"

Link_Tethys_Services_to_Apps:
  cmd.run:
    - name: >
        tethys link persistent:{{ POSTGIS_SERVICE_NAME }} water_data_explorer:ps_database:catalog_db &&
        tethys link persistent:{{ POSTGIS_SERVICE_NAME }} metdataexplorer:ps_database:thredds_db
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/init_apps_setup_complete" ];"

Sync_App_Persistent_Stores:
  cmd.run:
    - name: tethys syncstores all
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/init_apps_setup_complete" ];"

Flag_Init_Apps_Setup_Complete:
  cmd.run:
    - name: touch {{ TETHYS_PERSIST }}/init_apps_setup_complete
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/init_apps_setup_complete" ];"