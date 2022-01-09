```bash
# example of pulling out the packages and their version
jq -r '.packages[] | {name, versionInfo}' jsloan117-docker-openvpn-client_v1.7.1.spdx.json
```

```json
{
  "name": "unzip",
  "versionInfo": "6.0-r9"
}
{
  "name": "xz-libs",
  "versionInfo": "5.2.5-r0"
}
{
  "name": "zlib",
  "versionInfo": "1.2.11-r3"
}
```
