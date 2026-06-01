# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

include:
  - {{ sls_config_clean }}
{%- if grains.kernel == "Linux" %}
  - postman-api.package.lin_clean
{%- elif grains.kernel == "Windows" %}
  - postman-api.package.win_clean
{%- endif %}

Avoid being a null-router (package/clean) - Postman API:
  test.nop: []
