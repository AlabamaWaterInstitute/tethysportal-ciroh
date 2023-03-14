{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}
{% set TETHYS_DB_HOST = salt['environ.get']('TETHYS_DB_HOST') %}
{% set TETHYS_DB_PORT = salt['environ.get']('TETHYS_DB_PORT') %}
{% set TETHYS_DB_SUPERUSER = salt['environ.get']('TETHYS_DB_SUPERUSER') %}
{% set TETHYS_DB_SUPERUSER_PASS = salt['environ.get']('TETHYS_DB_SUPERUSER_PASS') %}

{% set THREDDS_TDS_USERNAME = salt['environ.get']('THREDDS_TDS_USERNAME') %}
{% set THREDDS_TDS_PASSWORD = salt['environ.get']('THREDDS_TDS_PASSWORD') %}
{% set THREDDS_TDS_CATALOG = salt['environ.get']('THREDDS_TDS_CATALOG') %}
{% set THREDDS_TDS_PRIVATE_PROTOCOL = salt['environ.get']('THREDDS_TDS_PRIVATE_PROTOCOL') %}
{% set THREDDS_TDS_PRIVATE_HOST = salt['environ.get']('THREDDS_TDS_PRIVATE_HOST') %}
{% set THREDDS_TDS_PRIVATE_PORT = salt['environ.get']('THREDDS_TDS_PRIVATE_PORT') %}
{% set THREDDS_TDS_PUBLIC_PROTOCOL = salt['environ.get']('THREDDS_TDS_PUBLIC_PROTOCOL') %}
{% set THREDDS_TDS_PUBLIC_HOST = salt['environ.get']('THREDDS_TDS_PUBLIC_HOST') %}
{% set THREDDS_TDS_PUBLIC_PORT = salt['environ.get']('THREDDS_TDS_PUBLIC_PORT') %}
{% set THREDDS_SERVICE_NAME = 'tethys_thredds' %}

{% set THREDDS_SERVICE_PRIVATE_URL = THREDDS_TDS_USERNAME + ':' + THREDDS_TDS_PASSWORD + '@' + THREDDS_TDS_PRIVATE_PROTOCOL +'://' + THREDDS_TDS_PRIVATE_HOST + ':' + THREDDS_TDS_PRIVATE_PORT + THREDDS_TDS_CATALOG %}
{% set THREDDS_SERVICE_PUBLIC_URL = THREDDS_TDS_PUBLIC_PROTOCOL +'://' + THREDDS_TDS_PUBLIC_HOST + ':' + THREDDS_TDS_PUBLIC_PORT + THREDDS_TDS_CATALOG %}

{% set POSTGIS_SERVICE_NAME = 'tethys_postgis' %}
{% set POSTGIS_SERVICE_URL = TETHYS_DB_SUPERUSER + ':' + TETHYS_DB_SUPERUSER_PASS + '@' + TETHYS_DB_HOST + ':' + TETHYS_DB_PORT %}



Create_PostGIS_Database_Service:
  cmd.run:
    - name: "tethys services create persistent -n {{ POSTGIS_SERVICE_NAME }} -c {{ POSTGIS_SERVICE_URL }}"
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/tethys_services_complete" ];"

Create_THREDDS_Spatial_Dataset_Service:
  cmd.run:
    - name: "tethys services create spatial -t THREDDS -n {{ THREDDS_SERVICE_NAME }} -c {{ THREDDS_SERVICE_PRIVATE_URL }} -p {{ THREDDS_SERVICE_PUBLIC_URL }}"
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/tethys_services_complete" ];"

Flag_Tethys_Services_Setup_Complete:
  cmd.run:
    - name: touch {{ TETHYS_PERSIST }}/tethys_services_complete
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/tethys_services_complete" ];"