# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

include:
{%- if grains.kernel == "Linux" %}
  - postman-api.package.lin_install
{%- elif grains.kernel == "Windows" %}
  - postman-api.package.win_install
{%- endif %}

Avoid being a null-router (package/install) - Postman API:
  test.nop: []
