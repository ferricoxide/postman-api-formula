# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

Deploy Postman Wrapper Script:
  file.managed:
    - contents: |
        #!/bin/bash
        FLAGS=("--log-level=3")
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
        exec /opt/Postman/Postman "${FLAGS[@]}" "$@" 2>/dev/null
    - group: 'root'
    - mode: '0755'
    - name: '/usr/local/bin/postman'
    - require:
      - archive: 'Extract Postman Archive'
    - user: 'root'

Extract Postman Archive:
  archive.extracted:
    - archive_format: 'tar'
    - enforce_toplevel: False
    - group: 'root'
    - keep_source: False
    - name: '/opt'
    - require:
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
