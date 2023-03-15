{% set CONDA_HOME = salt['environ.get']('CONDA_HOME') %}
{% set CONDA_ENV_NAME = salt['environ.get']('CONDA_ENV_NAME') %}
{% set TETHYS_PUBLIC_HOST = salt['environ.get']('TETHYS_PUBLIC_HOST') %}
{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}

Site_Settings_CIROH_Theme:
  cmd.run:
    - name: >
        tethys site --site-title "CIROH Portal"
        --apps-library-title "Tools"
        --primary-color "#255f9c"
        --secondary-color "#75acc4"
        --background-color "#ffffff"
        --brand-image "/ciroh_theme/images/CIROHLogo.png"
        --favicon "/ciroh_theme/images/favicon.ico"
        --copyright "Copyright © 2021 CIROH"
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/ciroh_theme_complete" ];"

Flag_Complete_Setup_CIROH_Theme:
  cmd.run:
    - name: touch {{ TETHYS_PERSIST }}/ciroh_theme_complete
    - shell: /bin/bash
