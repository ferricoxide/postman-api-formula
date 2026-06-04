# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}
{%- set image_execution_options_reg =
    'HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\'
    ~ 'Image File Execution Options\\Postman.exe' %}
{%- set start_menu_shortcut_path =
    'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Postman.lnk' %}

Remove Postman Desktop Shortcut:
  file.absent:
    - name: 'C:\Users\Public\Desktop\Postman.lnk'

Remove Process Mitigation Exclusions:
  reg.absent:
    - name: '{{ image_execution_options_reg }}'

Remove Protocol Deep Linking Registration:
  reg.absent:
    - name: 'HKLM\SOFTWARE\Classes\postman'

Remove Start Menu Shortcut:
  file.absent:
    - name: '{{ start_menu_shortcut_path }}'

Reverse Global Suppression of Automatic Updates:
  host.absent:
    - ip: '127.0.0.1'
    - name: 'dl.pstmn.io'
