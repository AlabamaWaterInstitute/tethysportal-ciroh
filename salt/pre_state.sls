{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}
{% set TETHYS_HOME = salt['environ.get']('TETHYS_HOME') %}

Persist_Portal_Changes:
  file.rename:
    - source: {{ TETHYS_HOME }}/portal_changes.yml
    - name: {{ TETHYS_PERSIST }}/portal_changes.yml
    - unless: /bin/bash -c "[ -f "${TETHYS_PERSIST}/portal_changes.yml" ];"

Restore_Portal_Changes:
  file.symlink:
    - name: {{ TETHYS_HOME }}/portal_changes.yml
    - target: {{ TETHYS_PERSIST }}/portal_changes.yml
    - force: True