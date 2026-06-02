# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

{#- Calculate the parent directory for extraction destination drops #}
{%- set install_dir = postman_api.config.install_root %}
{%- set parent_dir = install_dir.split('/')[:-1] | join('/') %}

Deploy Postman Wrapper Script:
  file.managed:
    - contents: |
        #!/bin/bash
        FLAGS=("--log-level=3")
        {%- if not postman_api.config.get('sandbox_enabled', True) %}
        FLAGS+=("--no-sandbox")
        {%- endif %}
        {%- if postman_api.config.get('ssl_min_version', False) %}
        FLAGS+=("--ssl-version-min={{ postman_api.config.ssl_min_version }}")
        {%- endif %}
        # Disable GPU if connected via SSH or an X11 tunnel
        if [ -n "$SSH_CLIENT" ] || \
           [ -n "$SSH_TTY" ] || \
           [[ "$DISPLAY" =~ ^localhost ]];
        then
          FLAGS+=("--disable-gpu")
        fi
        exec "{{ install_dir }}/Postman" "${FLAGS[@]}" "$@" 2>/dev/null
    - group: 'root'
    - mode: '0755'
    - name: '{{ postman_api.config.wrapper_bin }}'
    - require:
      - archive: 'Extract Postman Archive'
    - user: 'root'

Extract Postman Archive:
  archive.extracted:
    - archive_format: 'tar'
    - enforce_toplevel: False
    - group: 'root'
    - keep_source: False
    - name: '{{ parent_dir }}'
    - require:
      - host: 'Permit Download Domain Access'
      - pkg: 'Install Postman Dependencies'
    {%- if postman_api.pkg.download_sig %}
    - source: '{{ postman_api.pkg.download_uri }}'
    - source_hash: '{{ postman_api.pkg.download_sig }}'
    {%- else %}
    - skip_verify: True
    - source: '{{ postman_api.pkg.download_uri }}'
    {%- endif %}
    - user: root

Install Postman Dependencies:
  pkg.installed:
    - pkgs:
      - alsa-lib
      - at-spi2-atk
      - at-spi2-core
      - atk
      - cairo
      - cups-libs
      - dbus-glib
      - dejavu-sans-fonts
      - gdk-pixbuf2
      - gtk3
      - libX11
      - libX11-xcb
      - libXScrnSaver
      - libXcomposite
      - libXcursor
      - libXdamage
      - libXext
      - libXfixes
      - libXi
      - libXrandr
      - libXrender
      - libXtst
      - libdrm
      - libsecret
      - libva
      - libxcb
      - libxkbcommon
      - libxshmfence
      - mesa-libgbm
      - nspr
      - nss
      - nss-tools
      - pango
      - vulkan-loader
      - xdg-utils
      - xorg-x11-xauth

Permit Download Domain Access:
  host.absent:
    - ip: '127.0.0.1'
    - name: 'dl.pstmn.io'
