# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

Remove Postman Application Directory:
  file.absent:
    - name: '{{ postman_api.config.install_root }}'

Remove Postman Wrapper Script:
  file.absent:
    - name: '{{ postman_api.config.wrapper_bin }}'
