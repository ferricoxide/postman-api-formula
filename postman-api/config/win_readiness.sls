# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

Configure Postman API into System PATH Entry:
  win_path.exists:
    - name: '{{ postman_api.config.install_root }}'

Opt Out of Postman API Telemetry:
  environ.setenv:
    - name: POSTMAN_DISABLE_TELEMETRY
    - permanent: HKLM
    - value: '1'
