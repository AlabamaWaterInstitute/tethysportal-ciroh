{% set CONDA_HOME = salt['environ.get']('CONDA_HOME') %}
{% set CONDA_ENV_NAME = salt['environ.get']('CONDA_ENV_NAME') %}
{% set TETHYS_PUBLIC_HOST = salt['environ.get']('TETHYS_PUBLIC_HOST') %}
{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}
{% set TETHYSEXT_DIR = salt['environ.get']('TETHYSEXT_DIR') %}

Site_Settings_CIROH_Theme:
  cmd.run:
    - name: >
        . {{ CONDA_HOME }}/bin/activate {{ CONDA_ENV_NAME }} &&
        tethys site
        --title "CIROH Portal"
        --tab-title "CIROH Portal"
        --library-title "Tools"
        --primary-color "#000000"
        --secondary-color "#aaaaaa"
        --background-color "#ffffff"
        --logo "/ciroh_theme/images/CIROHLogo.png"
        --favicon "/ciroh_theme/images/favicon.ico"
        --copyright "Copyright © 2021 CIROH"
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/ciroh_theme_complete" ];"

Flag_Complete_Setup_CIROH_Theme:
  cmd.run:
    - name: touch {{ TETHYS_PERSIST }}/ciroh_theme_complete
    - shell: /bin/bash
