{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}
{% set FILE_UPLOAD_MAX_MEMORY_SIZE = salt['environ.get']('FILE_UPLOAD_MAX_MEMORY_SIZE') %}
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

# Set_Custom_Settings:
#   cmd.run:
#     - name: >
#         tethys app_settings set dam_inventory max_dams {{ DAM_INVENTORY_MAX_DAMS }} &&
#         tethys app_settings set earth_engine service_account_email {{ EARTH_ENGINE_SERVICE_ACCOUNT_EMAIL }} &&
#         tethys app_settings set earth_engine private_key_file {{ EARTH_ENGINE_PRIVATE_KEY_FILE }}
#     - shell: /bin/bash
#     - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/init_apps_setup_complete" ];"

Link_Tethys_Services_to_Apps:
  cmd.run:
    - name: >
        tethys link persistent:{{ POSTGIS_SERVICE_NAME }} water_data_explorer:ps_database:catalog_db
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