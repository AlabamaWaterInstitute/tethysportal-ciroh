{% set TETHYS_PERSIST = salt['environ.get']('TETHYS_PERSIST') %}
{% set NGINX_READ_TIME_OUT = salt['environ.get']('NGINX_READ_TIME_OUT') %}
{% set PREFIX_URL = salt['environ.get']('PREFIX_URL') %}

Patch_NGINX_TimeOut:
  cmd.run:
    - name: >
        sed -i 'N;/location \@proxy_to_app.*$/a \        proxy_read_timeout {{ NGINX_READ_TIME_OUT }};\n        proxy_connect_timeout {{ NGINX_READ_TIME_OUT }};\n        proxy_send_timeout {{ NGINX_READ_TIME_OUT }};\n' /etc/nginx/sites-enabled/tethys_nginx.conf &&
        cat /etc/nginx/sites-enabled/tethys_nginx.conf
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/apply_nginx_patches_complete" ];"

# necesary for the hydrocompute app
Add_Wasm_MIME_Type:
  cmd.run:
    - name: >
        sed -i '1s/^/#include mime.types;\n\n/' /etc/nginx/sites-enabled/tethys_nginx.conf && sed -i '2s/^/types {\n    application\/wasm wasm;\n}\n\n/' /etc/nginx/sites-enabled/tethys_nginx.conf &&
        cat /etc/nginx/sites-enabled/tethys_nginx.conf
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/apply_nginx_patches_complete" ];"
# necesary for prefix path:
Add_Prefix_to_static:
  cmd.run:
    - name: >
          sed -i 's/location \/static/location \/{{ PREFIX_URL }}\/static/g' /etc/nginx/sites-enabled/tethys_nginx.conf &&
          cat /etc/nginx/sites-enabled/tethys_nginx.conf
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/apply_nginx_patches_complete" ];"

Apply_NGINX_Patches_Complete_Setup:
  cmd.run:
    - name: touch {{ TETHYS_PERSIST }}/apply_nginx_patches_complete
    - shell: /bin/bash
    - unless: /bin/bash -c "[ -f "{{ TETHYS_PERSIST }}/apply_nginx_patches_complete" ];"

# if the config needs to be after
# sed -i '/proxy_pass http:\/\/channels-backend;/a         proxy_read_timeout 300;\n         proxy_connect_timeout 300;\n         proxy_send_timeout 300;\n' tethys_nginx.conf
#https://serverfault.com/questions/1103442/sed-add-a-line-after-match-that-contains-a-new-line