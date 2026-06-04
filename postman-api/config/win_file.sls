# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

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
