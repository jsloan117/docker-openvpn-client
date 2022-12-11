---
hide:
  - navigation
  # - toc
---

All of these things (signing, scanning, etc) are pretty new to me and this page may not always reflect the truth.

Mainly at this time, that is how/where security reports are handled within Github. Where/how do I share them etc.

## Image Signing

---

The image is signed using cosign by [sigstore](https://www.sigstore.dev). You can verify any v3+ image using the below key or the key with that release.

### Public key

```bash
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEPU9CpTEhHeNOpkQ7/oiBSbhYuxnC
4jnZ1BB7oOK91iLMEI3YjoqFvRRBQbmba8Cjh3HOvmLBFEukA1cOi+6J+g==
-----END PUBLIC KEY-----
```

### Verify image

```bash
cosign verify --key cosign.pub jsloan117/docker-openvpn-client:v3
```

## Vulnerability Scanning

---

Image scanning is handled using [grype](https://github.com/anchore/grype) by [Anchore](https://anchore.com/).
If any critical vulnerabilities are found the pipeline will fail.

The results of the scan should be available in the security tab of Github and as an artifact with each run of the pipeline.

## Software Bill Of Materials (SBOM)

---

SBOM generation is handled using [syft](https://github.com/anchore/syft) by [Anchore](https://anchore.com/), in spdx-json format.

It will be uploaded as an artifact with each run of the pipeline. For releases it will be uploaded as an asset.

### Check package name and their version

```bash
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

