# Identify a Vulnerable Package and Generate an SPDX SBOM

**Domain:** Supply Chain Security · **Weight:** 7

## Task
The `alpine` Deployment in the `alpine` namespace has three containers that run different versions of the alpine image.

## Requirements

1. Find out which version of the `alpine` image contains the `libcrypto3` package at version `3.1.4-r5`.

2. Use the pre-installed `bom` tool to create an **SPDX document** for the identified image version at:
   ```
   /home/candidate/alpine.spdx
   ```

You can find the bom tool documentation with `bom --help`.

## Hints
```bash
# inspect packages per image, e.g.:
crictl pull alpine:3.19.1
# or: docker run --rm alpine:3.19.1 apk list | grep libcrypto3
# or: trivy image alpine:3.19.1 | grep libcrypto3
```
