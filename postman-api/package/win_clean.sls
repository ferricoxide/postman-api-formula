# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

Remove Postman Installation Directory:
  file.absent:
    - name: '{{ postman_api.config.install_root }}'

Remove Postman Staged Installer:
  file.absent:
    - name: 'C:\Windows\Temp\PostmanSetup.exe'

Remove Postman Staged Script:
  file.absent:
    - name: 'C:\Windows\Temp\install_postman.ps1'
