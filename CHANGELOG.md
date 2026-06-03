## postman-api-formula

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

### 0.1.0

**Released**: 2026.06.02

**Summary**:

*   Added ("Enterprise") Linux functionality
    *   Installs the Postman API binary (as downloaded from [vendor site](https://www.postman.com/downloads/))
        *   Install-location defaults to `/opt/postman`
        *   Install-location overrideable via Pillar's `install_root` parameter
        *   For RHEL 9 (and related distros), latest installable version is 10.24.26 (override via Pillar's `download_uri` parameter)
    *   Creates a wrapper-script at `/usr/local/bin/postman` to ensure appropriate launch-time arguments. For example:
        *   "don't try to use GPU on X-over-SSH tunnels"
        *   "disable sandboxing on STIGed operating systems" ( override via Pillar's `sandbox_enabled` parameter)
        *   "require use of TLS v1.2+" ( override via Pillar's `ssl_min_version` parameter)
    *   Sets appropriate file-modes and SELinux contexts on binaries and wrappers
    *   Implements "cleanup" for all of the preceeding
*   Adds pillar.example to explain parameters/inputs that may be specified via Pillar
*   Update README with platform-notes


### 0.0.1

**Released**: 2026.06.01

**Summary**:

*   Cloned project from https://github.com/plus3it/repo-template
*   Created postman-api directory-tree contents by:
    1.   Cloning https://github.com/saltstack-formulas/template-formula.git
    2.   Executing `bin/convert-formula.sh postman-api` in the new repo-copy
    3.   Moving the resulting `postman-api` directory into this project's space
    4.   Updating all imports from "`postman__api`" to "`postman_api`"
*   Update [LICENSE](LICENSE), CHANGELOG.md (this file), [README.md](README.md) and [.bumpversion.cfg](.bumpversion.cfg) per the P3 repo-template guidance
*   Update the `.github` and `tests` directories' contents  per the P3 repo-template guidance

