# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}

{#- Dynamically check if the host has the SELinux kernel subsystem live #}
{%- set selinux_live = salt['grains.get']('selinux:enabled', False) %}

Refresh Whitelist Daemon Database:
  cmd.run:
    - name: 'fapolicyd-cli --update'
    - onchanges:
      - file: 'Remove Whitelist Daemon Policy'
    - onlyif: 'command -v fapolicyd-cli'

Remove Postman Desktop Shortcut:
  file.absent:
    - name: '{{ postman_api.config.desktop_entry }}'

{%- if postman_api.config.get('selinux_fcontext', False) and selinux_live %}
Remove Postman SELinux File Contexts:
  selinux.fcontext_policy_absent:
    - name: '{{ postman_api.config.install_root | replace(" ", "\s") }}(/.*)?'
{%- endif %}

Remove Protocol Deep Linking Registration:
  cmd.run:
    - name: '{{ postman_api.config.update_mime_database }} /usr/share/applications'
    - onchanges:
      - file: 'Remove Postman Desktop Shortcut'

Remove Whitelist Daemon Policy:
  file.absent:
    - name: '/etc/fapolicyd/rules.d/95-postman.rules'
    - onlyif: 'command -v fapolicyd-cli'

Suppress Automatic Updates Globally:
  host.absent:
    - ip: '127.0.0.1'
    - name: 'dl.pstmn.io'
