postman-api-formula
==================

A SaltStack formula designed to install and configure the [Postman API package](https://www.postman.com/) on installation-targets.

It is primarily expected that this formula will be run via [P3](https://www.plus3it.com/)'s "[watchmaker](https://watchmaker.readthedocs.io/en/stable/)" framework.

This formula is able to install the Postman API utility on Linux[^1] and Windows Server[^2] operating environments. Installation for internet-connected systems may come from the Postman API's ["Downloads" page](https://www.postman.com/downloads/). Alternately:

* Sites whose installation-targets won't be able to reach the Postman API product's "Downloads" page will need to self-host copies of the desired content.
* Sites that wish to use a specific version of the Postman API will need to target that content

Targeting specific versions of the Postman API or local copies of the install-archives can be directed to do so by adding appropriate content to the formula's associated Pillar-data (see this projct's [pillar.example](pillar.example) file for guidance).


## Available states

- [postman-api](#postman-api)
- [postman-api.clean](#postman-api.clean)
- [postman-api.package](#postman-api.package)
- [postman-api.package.clean](#postman-api.package.clean)
- [postman-api.config](#postman-api.config)
- [postman-api.config.clean](#postman-api.config.clean)

### postman-api

Executes the `package` and `config` states to install and configure the Postman API

### postman-api.clean

Executes the `package` and `config` states' `clean` actions to fully uninstall the Postman API and remove previously-installed browser policy-configs (and, on Windows, associated registry entries)

### postman-api.package

Executes _just_ the `package` state to install the Postman API package.

### postman-api.package.clean

Executes _just_ the `package.clean` state to uninstall the Postman API package.

### postman-api.config

Executes _just_ the `config` state to install/configure the Postman API client-configuration (etc.) files

### postman-api.config.clean

Executes _just_ the `config` state to uninstall the Postman API client-configuration (etc.) files and, on Windows, remove any registry-keys set by prior install-runs of the formula.

## Compatibility Notes:

### Linux

1. Due to library compatibilities, the installable version of Postman on RHEL 9 (and derivatives) is constrained to < `11.x`. This formula defaults the RHEL 9 (and derivatives) installation to Postman version `10.24.26`
1. To support hardened enterprise baselines (such as the DISA STIG or CIS profiles), this formula defaults to disabling the Chromium application sandbox (`sandbox_enabled: false`) on Red Hat family distributions. These security profiles typically disable unprivileged user namespaces (`user.max_user_namespaces = 0`), which causes Electron-based applications to crash instantly on startup. For less restrictive environments where user namespaces are permitted, the sandbox can be safely re-enabled by setting `sandbox_enabled: true` via Pillar data.


[^1]: As of this README's writing, only Enterprise Linux and related distros (Red Hat and Oracle Enterprise, CentOS Stream, Rocky and Alma Linux). It has only been specifically tested with EL **_9_** variants.
[^2]: As of this README's writing, this functionality has only been tested on Windows Server 2022
