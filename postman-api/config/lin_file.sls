# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

{%- set shortcut_sources = files_switch(
      ['postman.desktop', 'postman.desktop.jinja'],
      lookup='Configure Postman Desktop Shortcut'
    )
%}

Configure Postman Desktop Shortcut:
  file.managed:
    - context:
        postman_api: {{ postman_api | json }}
    - group: 'root'
    - makedirs: True
    - mode: '0644'
    - name: {{ postman_api.config.desktop_entry }}
    - source: {{ shortcut_sources }}
    - template: 'jinja'
    - user: 'root'
