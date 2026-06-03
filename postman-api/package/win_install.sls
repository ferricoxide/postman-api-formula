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
        $RootPath = '{{ postman_api.config.install_root }}';
        $PostmanExePath = Join-Path $RootPath 'Postman.exe';
        if (Test-Path $PostmanExePath) {
            $TargetVersion = '{{ postman_api.pkg.version }}';
            $DownloadUri = '{{ postman_api.pkg.download_uri }}';
            $IsVendorUrl = $DownloadUri -like '*dl.pstmn.io*';
            if ($TargetVersion -eq 'latest' -and $IsVendorUrl) {
                $BaseUrl = 'https://dl.pstmn.io/update/status';
                $Query = '?currentVersion=12.0.0&platform=win64';
                $StatusUrl = $BaseUrl + $Query;
                $RestArgs = @{
                    ErrorAction = 'SilentlyContinue'
                    Uri         = $StatusUrl
                };
                $UpdateStatus = Invoke-RestMethod @RestArgs;
                if ($UpdateStatus -and $UpdateStatus.version) {
                    $TargetVersion = $UpdateStatus.version;
                }
            }
            if ($TargetVersion -eq 'latest') { exit 0 }
            $FileInfo = Get-Item $PostmanExePath;
            $InstalledProductVersion =
                $FileInfo.VersionInfo.ProductVersion;
            $IsMatch = $InstalledProductVersion -match
                $TargetVersion;
            if ($IsMatch) { exit 0 }
        }; exit 1"

Execute Postman Installation:
  cmd.script:
    - args: >-
        -DownloadUri "{{ postman_api.pkg.download_uri }}"
        -InstallRoot "{{ postman_api.config.install_root }}"
        -TargetVersion "{{ postman_api.pkg.version }}"
    - require:
      - file: Download Postman Installer
    - shell: powershell
    - source: salt://postman-api/files/install_postman.ps1
    - unless: |
        powershell -ExecutionPolicy Bypass -Command "
        $RootPath = '{{ postman_api.config.install_root }}';
        $PostmanExePath = Join-Path $RootPath 'Postman.exe';
        if (Test-Path $PostmanExePath) {
            $TargetVersion = '{{ postman_api.pkg.version }}';
            $DownloadUri = '{{ postman_api.pkg.download_uri }}';
            $IsVendorUrl = $DownloadUri -like '*dl.pstmn.io*';
            if ($TargetVersion -eq 'latest' -and $IsVendorUrl) {
                $BaseUrl = 'https://dl.pstmn.io/update/status';
                $Query = '?currentVersion=12.0.0&platform=win64';
                $StatusUrl = $BaseUrl + $Query;
                $RestArgs = @{
                    ErrorAction = 'SilentlyContinue'
                    Uri         = $StatusUrl
                };
                $UpdateStatus = Invoke-RestMethod @RestArgs;
                if ($UpdateStatus -and $UpdateStatus.version) {
                    $TargetVersion = $UpdateStatus.version;
                }
            }
            if ($TargetVersion -eq 'latest') { exit 0 }
            $FileInfo = Get-Item $PostmanExePath;
            $InstalledProductVersion =
                $FileInfo.VersionInfo.ProductVersion;
            $IsMatch = $InstalledProductVersion -match
                $TargetVersion;
            if ($IsMatch) { exit 0 }
        }; exit 1"
