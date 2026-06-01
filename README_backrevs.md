# How to Find/Install back-rev versions

It is primarily expected that this formula will be used to install the "latest and greatest" version of the Postman API application from the vendor's web-site. If, however, a site requires the ability to install a specific &mdash; and almost certainly "back rev" &mdash; version of the Postman API application, it will be necessary to step through some hoops to find the desired download URL.

## Identifying available point-releases

To grab an exhustive list of available Postman versions, execute:

```bash
$ curl -sL "https://dl.pstmn.io/changelog?channel=stable&platform=linux" | \
tr '"' '\n' | \
grep -oE '^[0-9]+\.[0-9]+\.[0-9]+' | \
sort -rV | \
uniq
```

As mentioned in the main README file's notes for Linux, RHEL 9 distros require a Postman version less than `11.x`

## Constructing the download URL

To fetch an arbitrary Postman version from the Vendor's download-service, you will need to construct an appropriate URL path. The general URL path will look like:

```
    https://dl.pstmn.io/download/version/<VERSION>/<PLATFORM>'
```

* The value of `<VERSION>` is as taken from the list output from the BASH scriptlet in the preceding, "Identifying available point-releases", section.
*   The value of `<PLATFORM>` will be either of
    * `linux64` for Linux distributions using the x86_64 CPU-architecture
    * `windows` for all Windows versions

By way of example:

* The URL `https://dl.pstmn.io/download/version/10.24.26/linux64` would be used to pull Postman `10.24.26` for Linux distros
* The URL `https://dl.pstmn.io/download/version/12.12.5/windows` would be used to pull Postman `12.12.5` for Windows systems
