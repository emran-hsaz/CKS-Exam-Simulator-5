# Create a TLS Secret for clever-cactus

**Domain:** Cluster Hardening · **Weight:** 7

## Context
You must complete securing access to a web server using SSL files stored in a TLS Secret.

## Requirements

Create a TLS Secret named `clever-cactus` in the `clever-cactus` namespace for an existing Deployment named `clever-cactus`.

Use the following SSL files:

| File        | Path                                                |
|-------------|-----------------------------------------------------|
| Certificate | `/home/candidate/clever-cactus/web.k8s.local.crt`   |
| Key         | `/home/candidate/clever-cactus/web.k8s.local.key`   |

The Deployment is already configured to use the Secret as a volume.

## Verify
```bash
kubectl -n clever-cactus get pods
```
