# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

Download Postman Installer:
  file.managed:
    - makedirs: true
    - name: 'C:\Windows\Temp\PostmanSetup.exe'
    - require:
      - file: Stage Installation Script
    {%- if postman_api.pkg.download_sig %}
    - source: '{{ postman_api.pkg.download_uri }}'
    - source_hash: '{{ postman_api.pkg.download_sig }}'
    {%- else %}
    - skip_verify: true
    - source: '{{ postman_api.pkg.download_uri }}'
    {%- endif %}
    - unless: >-
        powershell -ExecutionPolicy Bypass -File
        C:\Windows\Temp\install_postman.ps1
        -CheckOnly
        -DownloadUri "{{ postman_api.pkg.download_uri }}"
        -InstallRoot "{{ postman_api.config.install_root }}"
        -TargetVersion "{{ postman_api.pkg.version }}"

Execute Postman Installation:
  cmd.run:
    - name: >-
        powershell -ExecutionPolicy Bypass -File
        C:\Windows\Temp\install_postman.ps1
        -DownloadUri "{{ postman_api.pkg.download_uri }}"
        -InstallRoot "{{ postman_api.config.install_root }}"
        -TargetVersion "{{ postman_api.pkg.version }}"
    - require:
      - file: Download Postman Installer
      - file: Stage Installation Script
    - shell: powershell
    - unless: >-
        powershell -ExecutionPolicy Bypass -File
        C:\Windows\Temp\install_postman.ps1
        -CheckOnly
        -DownloadUri "{{ postman_api.pkg.download_uri }}"
        -InstallRoot "{{ postman_api.config.install_root }}"
        -TargetVersion "{{ postman_api.pkg.version }}"

Stage Installation Script:
  file.managed:
    - makedirs: true
    - name: 'C:\Windows\Temp\install_postman.ps1'
    - source: salt://postman-api/files/install_postman.ps1
