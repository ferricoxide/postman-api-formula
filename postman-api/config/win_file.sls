# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

Configure Postman Desktop Shortcut:
  shortcut.present:
    - name: 'C:\Users\Public\Desktop\Postman.lnk'
    - target: '{{ postman_api.config.install_root }}\Postman.exe'
    - working_dir: '{{ postman_api.config.install_root }}'

Configure Process Mitigation Exclusions:
  cmd.run:
    - name: >-
        Set-ProcessMitigation
        -Name Postman.exe
        -Disable DisallowChildProcessCreation
    - shell: powershell
    - unless: >-
        $m = Get-ProcessMitigation -Name Postman.exe
        -ErrorAction SilentlyContinue;
        if ($m.ChildProcess.DisallowChildProcessCreation
        -eq 'OFF') { exit 0 } else { exit 1 }

Configure Protocol Deep Linking Base:
  reg.present:
    - name: 'HKLM\SOFTWARE\Classes\postman'
    - vdata: 'URL:postman Protocol'
    - vname: '(Default)'
    - vtype: REG_SZ

Configure Protocol Deep Linking Command:
  reg.present:
    - name: 'HKLM\SOFTWARE\Classes\postman\shell\open\command'
    - vdata: '"{{ postman_api.config.install_root }}\Postman.exe" "%1"'
    - vname: '(Default)'
    - vtype: REG_SZ

Configure Protocol Deep Linking Protocol Value:
  reg.present:
    - name: 'HKLM\SOFTWARE\Classes\postman'
    - vdata: ''
    - vname: 'URL Protocol'
    - vtype: REG_SZ

Configure Start Menu Shortcut:
  shortcut.present:
    - name: 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Postman.lnk'
    - target: '{{ postman_api.config.install_root }}\Postman.exe'
    - working_dir: '{{ postman_api.config.install_root }}'

Harden Postman Directory Permissions:
  file.directory:
    - name: '{{ postman_api.config.install_root }}'
    - win_inheritance: true
    - win_owner: 'BUILTIN\Administrators'
    - win_perms:
        BUILTIN\Administrators:
          perms: full_control
        BUILTIN\Users:
          perms: read_execute

Suppress Automatic Updates Globally:
  host.present:
    - ip: '127.0.0.1'
    - name: 'dl.pstmn.io'
