{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}
{% set FILE_UPLOAD_MAX_MEMORY_SIZE = salt['environ.get']('FILE_UPLOAD_MAX_MEMORY_SIZE') %}
{% set MDE_DISCLAIMER_HEADER = salt['environ.get']('MDE_DISCLAIMER_HEADER') %}
{% set MDE_DISCLAIMER_MESSAGE = salt['environ.get']('MDE_DISCLAIMER_MESSAGE') %}
{% set MDE_SERVER_HOME_DIRECTORY = salt['environ.get']('HOME') %}


{% set POSTGIS_SERVICE_NAME = 'tethys_postgis' %}



Set_Tethys_Settings_For_Apps:
  cmd.run:
    - name: >
        tethys settings --set FILE_UPLOAD_MAX_MEMORY_SIZE {{ FILE_UPLOAD_MAX_MEMORY_SIZE }} --set DATA_UPLOAD_MAX_MEMORY_SIZE {{ FILE_UPLOAD_MAX_MEMORY_SIZE }}
    - unless: /bin/bash -c "[ -f "${TETHYS_PERSIST}/init_apps_setup_complete" ];"

Sync_Apps:
  cmd.run:
    - name: tethys db sync
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/init_apps_setup_complete" ];"

Set_Custom_Settings:
  cmd.run:
    - name: >
        tethys app_settings set metdataexplorer disclaimer_header {{ MDE_DISCLAIMER_HEADER }} &&
        tethys app_settings set metdataexplorer disclaimer_message {{ MDE_DISCLAIMER_MESSAGE }} &&
        tethys app_settings set metdataexplorer server_home_directory {{ MDE_SERVER_HOME_DIRECTORY }}
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/init_apps_setup_complete" ];"

Link_Tethys_Services_to_Apps:
  cmd.run:
    - name: >
        tethys link persistent:{{ POSTGIS_SERVICE_NAME }} water_data_explorer:ps_database:catalog_db
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