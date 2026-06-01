# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

Extract Postman Archive:
  archive.extracted:
    - archive_format: 'tar'
    - enforce_toplevel: False
    - group: root
    - keep_source: False
    - name: /opt
    {%- if postman_api.pkg.download_sig %}
    - source: '{{ postman_api.pkg.download_uri }}'
    - source_hash: '{{ postman_api.pkg.download_sig }}'
    {%- else %}
    - skip_verify: True
    - source: '{{ postman_api.pkg.download_uri }}'
    {%- endif %}
    - user: root
