# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

postman_api_environment_path:
  environ.setenv:
    - name: PATH
    - update_with: path
    - value: '{{ postman_api.config.install_root }}'

postman_api_telemetry_opt_out:
  environ.setenv:
    - name: POSTMAN_DISABLE_TELEMETRY
    - update_with: xappend
    - value: '1'
