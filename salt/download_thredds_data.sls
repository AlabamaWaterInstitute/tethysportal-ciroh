{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}
{% set NGINX_READ_TIME_OUT = salt['environ.get']('NGINX_READ_TIME_OUT') %}
{% set TETHYS_HOME = salt['environ.get']('TETHYS_HOME') %}

Download_Thredds_Data:
  cmd.run:
    - name: >
        cd {{ TETHYS_HOME }}/scripts &&
        python thredds_ggst_download.py {{ TETHYS_PERSIST }}/thredds_data/ggst/ggst_thredds_directory
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/donwloaded_thredds_data" ];"

Download_Thredds_Data_Complete_Setup:
  cmd.run:
    - name: touch {{ TETHYS_PERSIST }}/donwloaded_thredds_data_complete
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/donwloaded_thredds_data_complete" ];"