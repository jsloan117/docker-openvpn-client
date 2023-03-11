---
hide:
  - navigation
  # - toc
---

## Image Signing

---

The image is signed using cosign by [sigstore](https://www.sigstore.dev). You can verify any v3+ image using the below or the key associated with that release.

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

We use [grype](https://github.com/anchore/grype) by [Anchore](https://anchore.com/) to handle image scanning.
If any critical vulnerabilities are detected, the pipeline will fail.

The scan results should be available in the security tab of Github and as an artifact with each pipeline run.

## Software Bill Of Materials (SBOM)

---

We use [syft](https://github.com/anchore/syft) by [Anchore](https://anchore.com/) to handle SBOM generation in spdx-json format.
We upload it as an artifact with every pipeline run and as an asset for releases.

???+ example "get package name and version"
    ```bash linenums="1"
    jq -r '.packages[] | {name, versionInfo}' jsloan117-docker-openvpn-client_v1.7.1.spdx.json
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

