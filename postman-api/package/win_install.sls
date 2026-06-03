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
    - unless: |
        powershell -ExecutionPolicy Bypass -Command "
        $PostmanExePath = '{{ postman_api.config.install_root }}\Postman.exe';
        if (Test-Path $PostmanExePath) {
            $FileInfo = Get-Item $PostmanExePath;
            $InstalledProductVersion = $FileInfo.VersionInfo.ProductVersion;
            if ($InstalledProductVersion -match '{{ postman_api.pkg.version }}') {
                exit 0
            }
        }; exit 1"

Execute Postman Installation:
  cmd.script:
    - args: >-
        -InstallRoot "{{ postman_api.config.install_root }}"
        -TargetVersion "{{ postman_api.pkg.version }}"
    - require:
      - file: Download Postman Installer
    - shell: powershell
    - source: salt://postman-api/files/install_postman.ps1
    - unless: |
        powershell -ExecutionPolicy Bypass -Command "
        $PostmanExePath = '{{ postman_api.config.install_root }}\Postman.exe';
        if (Test-Path $PostmanExePath) {
            $FileInfo = Get-Item $PostmanExePath;
            $InstalledProductVersion = $FileInfo.VersionInfo.ProductVersion;
            if ($InstalledProductVersion -match '{{ postman_api.pkg.version }}') {
                exit 0
            }
        }; exit 1"
