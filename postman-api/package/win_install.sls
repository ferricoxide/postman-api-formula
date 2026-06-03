# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

Download Postman Installer:
  file.managed:
    - makedirs: true
    - name: 'C:\Windows\Temp\PostmanSetup.exe'
    {%- if postman_api.pkg.download_sig %}
    - source: '{{ postman_api.pkg.download_uri }}'
    - source_hash: '{{ postman_api.pkg.download_sig }}'
    {%- else %}
    - skip_verify: true
    - source: '{{ postman_api.pkg.download_uri }}'
    {%- endif %}

Execute Postman Installation:
  cmd.script:
    - args: '-InstallRoot "{{ postman_api.config.install_root }}"'
    - require:
      - file: Download Postman Installer
    - shell: powershell
    - source: salt://postman-api/files/install_postman.ps1
