{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}
{% set TETHYS_HOME = salt['environ.get']('TETHYS_HOME') %}
{% set CONDA_HOME = salt['environ.get']('CONDA_HOME') %}
{% set CONDA_ENV_NAME = salt['environ.get']('CONDA_ENV_NAME') %}

{% set FILE_UPLOAD_MAX_MEMORY_SIZE = salt['environ.get']('FILE_UPLOAD_MAX_MEMORY_SIZE') %}
{% set CHANNEL_LAYERS_BACKEND = salt['environ.get']('CHANNEL_LAYERS_BACKEND') %}
{% set CHANNEL_LAYERS_CONFIG = salt['environ.get']('CHANNEL_LAYERS_CONFIG') %}
{% set PREFIX_TO_PATH = salt['environ.get']('PREFIX_TO_PATH') %}


Pre_Apps_Settings:
  cmd.run:
    - name: cat {{ TETHYS_HOME }}/portal_config.yml
    - shell: /bin/bash

Set_Tethys_Settings_For_Apps:
  cmd.run:
    - name: >
        tethys settings --set FILE_UPLOAD_MAX_MEMORY_SIZE {{ FILE_UPLOAD_MAX_MEMORY_SIZE }} &&
        tethys settings --set DATA_UPLOAD_MAX_MEMORY_SIZE {{ FILE_UPLOAD_MAX_MEMORY_SIZE }} &&
        tethys settings --set DATA_UPLOAD_MAX_NUMBER_FIELDS {{ FILE_UPLOAD_MAX_MEMORY_SIZE }} &&
        tethys settings --set PREFIX_TO_PATH {{ PREFIX_TO_PATH }}
    - unless: /bin/bash -c "[ -f "${TETHYS_PERSIST}/init_apps_setup_complete" ];"

Sync_Apps:
  cmd.run:
    - name: tethys db sync
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/init_apps_setup_complete" ];"

Update_Tethys_Apps:
  file.managed:
    - name: {{ TETHYS_PERSIST }}/portal_changes.yml
    - source: {{ TETHYS_HOME }}/portal_changes.yml

run_on_changes:
  cmd.run:
    - name: {{ TETHYS_HOME }}/update_state.sh 
    - shell: /bin/bash
    - onchanges:
      - file: Update_Tethys_Apps

# /srv/salt/my_file.sls

Flag_Init_Apps_Setup_Complete:
  cmd.run:
    - name: touch {{ TETHYS_PERSIST }}/init_apps_setup_complete
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/init_apps_setup_complete" ];"