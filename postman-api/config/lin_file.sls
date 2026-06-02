# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as postman_api with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

{#- Dynamically check if the host has the SELinux kernel subsystem live #}
{%- set selinux_live = salt['grains.get']('selinux:enabled', False) %}

Configure Postman Desktop Shortcut:
  file.managed:
    - context:
        postman_api: {{ postman_api | json }}
    - group: 'root'
    - makedirs: True
    - mode: '0644'
    - name: {{ postman_api.config.desktop_entry }}
    - source:
{{ files_switch(['postman.desktop', 'postman.desktop.jinja'],
                lookup='desktop_shortcut') }}
    - template: 'jinja'
    - user: 'root'

{%- if selinux_live and postman_api.config.get('selinux_fcontext', False) %}
Configure Postman SELinux File Contexts:
  selinux.fcontext_policy_present:
    - filetype: 'a'
    - name: '{{ postman_api.config.install_root }}(/.*)?'
    - sel_type: {{ postman_api.config.selinux_fcontext }}
{%- endif %}

{%- if postman_api.config.get('whitelist_enabled', False) %}
Configure Whitelist Daemon Policy:
  file.managed:
    - contents: |
        # Allow execution of system-wide Postman binaries and libraries
        allow perm=any uid=all : dir={{ postman_api.config.install_root }}/
        allow perm=any uid=all : path={{ postman_api.config.wrapper_bin }}
    - group: 'root'
    - makedirs: True
    - mode: '0644'
    - name: '/etc/fapolicyd/rules.d/95-postman.rules'
    - onlyif: 'command -v fapolicyd-cli'
    - user: 'root'
{%- endif %}

{%- if postman_api.config.get('whitelist_enabled', False) %}
Refresh Whitelist Daemon Database:
  cmd.run:
    - name: 'fapolicyd-cli --update'
    - onchanges:
      - file: 'Configure Whitelist Daemon Policy'
    - onlyif: 'command -v fapolicyd-cli'
{%- endif %}

Register Protocol Deep Linking:
  cmd.run:
    - name: '{{ postman_api.config.update_mime_database }} /usr/share/applications'
    - onchanges:
      - file: 'Configure Postman Desktop Shortcut'

{%- if selinux_live %}
{%- set root_path = postman_api.config.install_root %}
{%- set wrap_path = postman_api.config.wrapper_bin %}
Restore SELinux Security Contexts:
  cmd.run:
    - name: 'restorecon -R {{ root_path }} {{ wrap_path }}'
    - onchanges:
      - file: 'Configure Postman Desktop Shortcut'
      {%- if postman_api.config.get('selinux_fcontext', False) %}
      - selinux: 'Configure Postman SELinux File Contexts'
      {%- endif %}
{%- endif %}

Suppress Automatic Updates Globally:
  file.managed:
    - contents: |
        # Suppress automatic update background downloads for Postman
        export POSTMAN_DISABLE_AUTO_UPDATES=true
    - group: 'root'
    - mode: '0644'
    - name: '/etc/profile.d/postman_enterprise.sh'
    - user: 'root'
