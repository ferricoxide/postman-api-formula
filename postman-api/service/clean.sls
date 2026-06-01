# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

postman-api-service-clean-service-dead:
  service.dead:
    - name: {{ postman_api.service.name }}
    - enable: False
