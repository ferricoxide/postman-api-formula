nosql-booster:
  lookup:
    {%- if grains.os_family == "RedHat" %}
    pkg:
      download_uri: https://dl.pstmn.io/download/version/10.24.16/linux_64
    config:
      sandbox_enabled: true
      install_root: '/opt/Desktop Applications/Postman'
    {%- elif grains.os_family == "Windows" %}
    {%- endif %}
