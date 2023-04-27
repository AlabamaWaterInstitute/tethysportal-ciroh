{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}
{% set TETHYS_DB_NAME = salt['environ.get']('TETHYS_DB_NAME') %}
{% set TETHYS_DB_HOST = salt['environ.get']('TETHYS_DB_HOST') %}
{% set TETHYS_DB_SUPERUSER = salt['environ.get']('TETHYS_DB_SUPERUSER') %}
{% set TETHYS_DB_SUPERUSER_PASS = salt['environ.get']('TETHYS_DB_SUPERUSER_PASS') %}

{% set PROXY_APP_1_NAME = salt['environ.get']('PROXY_APP_1_NAME') %}
{% set PROXY_APP_1_ENDPOINT = salt['environ.get']('PROXY_APP_1_ENDPOINT') %}
{% set PROXY_APP_1_LOGO_URL = salt['environ.get']('PROXY_APP_1_LOGO_URL') %}
{% set PROXY_APP_1_DESCRIPTION = salt['environ.get']('PROXY_APP_1_DESCRIPTION') %}
{% set PROXY_APP_1_TAGS = salt['environ.get']('PROXY_APP_1_TAGS') %}
{% set PROXY_APP_1_ENABLED = salt['environ.get']('PROXY_APP_1_ENABLED') %}
{% set PROXY_APP_1_SHOW_IN_APPS_LIBRARY = salt['environ.get']('PROXY_APP_1_SHOW_IN_APPS_LIBRARY') %}
{% set PROXY_APP_1_ORDER = salt['environ.get']('PROXY_APP_1_ORDER') %}
{% set PROXY_APP_1_BACK_URL = salt['environ.get']('PROXY_APP_1_BACK_URL') %}
{% set PROXY_APP_1_OPEN_IN_NEW_TAB = salt['environ.get']('PROXY_APP_1_OPEN_IN_NEW_TAB') %}

{% set PROXY_APP_2_NAME = salt['environ.get']('PROXY_APP_2_NAME') %}
{% set PROXY_APP_2_ENDPOINT = salt['environ.get']('PROXY_APP_2_ENDPOINT') %}
{% set PROXY_APP_2_LOGO_URL = salt['environ.get']('PROXY_APP_2_LOGO_URL') %}
{% set PROXY_APP_2_DESCRIPTION = salt['environ.get']('PROXY_APP_2_DESCRIPTION') %}
{% set PROXY_APP_2_TAGS = salt['environ.get']('PROXY_APP_2_TAGS') %}
{% set PROXY_APP_2_ENABLED = salt['environ.get']('PROXY_APP_2_ENABLED') %}
{% set PROXY_APP_2_SHOW_IN_APPS_LIBRARY = salt['environ.get']('PROXY_APP_2_SHOW_IN_APPS_LIBRARY') %}
{% set PROXY_APP_2_ORDER = salt['environ.get']('PROXY_APP_2_ORDER') %}
{% set PROXY_APP_2_BACK_URL = salt['environ.get']('PROXY_APP_2_BACK_URL') %}
{% set PROXY_APP_2_OPEN_IN_NEW_TAB = salt['environ.get']('PROXY_APP_2_OPEN_IN_NEW_TAB') %}

{% set PROXY_APP_3_NAME = salt['environ.get']('PROXY_APP_3_NAME') %}
{% set PROXY_APP_3_ENDPOINT = salt['environ.get']('PROXY_APP_3_ENDPOINT') %}
{% set PROXY_APP_3_LOGO_URL = salt['environ.get']('PROXY_APP_3_LOGO_URL') %}
{% set PROXY_APP_3_DESCRIPTION = salt['environ.get']('PROXY_APP_3_DESCRIPTION') %}
{% set PROXY_APP_3_TAGS = salt['environ.get']('PROXY_APP_3_TAGS') %}
{% set PROXY_APP_3_ENABLED = salt['environ.get']('PROXY_APP_3_ENABLED') %}
{% set PROXY_APP_3_SHOW_IN_APPS_LIBRARY = salt['environ.get']('PROXY_APP_3_SHOW_IN_APPS_LIBRARY') %}
{% set PROXY_APP_3_ORDER = salt['environ.get']('PROXY_APP_3_ORDER') %}
{% set PROXY_APP_3_BACK_URL = salt['environ.get']('PROXY_APP_3_BACK_URL') %}
{% set PROXY_APP_3_OPEN_IN_NEW_TAB = salt['environ.get']('PROXY_APP_3_OPEN_IN_NEW_TAB') %}


Add_Proxy_Apps:
  cmd.run:
    - name: >
        PGPASSWORD={{ TETHYS_DB_SUPERUSER_PASS }} psql -U {{ TETHYS_DB_SUPERUSER}} -d {{ TETHYS_DB_NAME }} -h {{ TETHYS_DB_HOST }} -c \
        "INSERT into tethys_apps_proxyapp (id,name,endpoint,logo_url,description,tags,enabled,show_in_apps_library,\"order\",back_url,open_in_new_tab) \
        VALUES (1, {{ PROXY_APP_1_NAME }}, {{ PROXY_APP_1_ENDPOINT }}, {{ PROXY_APP_1_LOGO_URL }}, {{ PROXY_APP_1_DESCRIPTION }}, {{ PROXY_APP_1_TAGS }}, {{ PROXY_APP_1_ENABLED }}, {{ PROXY_APP_1_SHOW_IN_APPS_LIBRARY }}, {{ PROXY_APP_1_ORDER }}, {{ PROXY_APP_1_BACK_URL }}, {{ PROXY_APP_1_OPEN_IN_NEW_TAB }}), \
        VALUES (2, {{ PROXY_APP_2_NAME }}, {{ PROXY_APP_2_ENDPOINT }}, {{ PROXY_APP_2_LOGO_URL }}, {{ PROXY_APP_2_DESCRIPTION }}, {{ PROXY_APP_2_TAGS }}, {{ PROXY_APP_2_ENABLED }}, {{ PROXY_APP_2_SHOW_IN_APPS_LIBRARY }}, {{ PROXY_APP_2_ORDER }}, {{ PROXY_APP_2_BACK_URL }}, {{ PROXY_APP_2_OPEN_IN_NEW_TAB }}), \
        VALUES (3, {{ PROXY_APP_3_NAME }}, {{ PROXY_APP_3_ENDPOINT }}, {{ PROXY_APP_3_LOGO_URL }}, {{ PROXY_APP_3_DESCRIPTION }}, {{ PROXY_APP_3_TAGS }}, {{ PROXY_APP_3_ENABLED }}, {{ PROXY_APP_3_SHOW_IN_APPS_LIBRARY }}, {{ PROXY_APP_3_ORDER }}, {{ PROXY_APP_3_BACK_URL }}, {{ PROXY_APP_3_OPEN_IN_NEW_TAB }});"
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/add_proxy_apps_setup_complete" ];"

Flag_Add_Proxy_Apps:
  cmd.run:
    - name: touch {{ TETHYS_PERSIST }}/add_proxy_apps_setup_complete
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/add_proxy_apps_setup_complete" ];"