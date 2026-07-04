# Enforce Container Immutability on lamp-deployment

**Domain:** Minimize Microservice Vulnerabilities · **Weight:** 7

## Context
You must update an existing Pod to ensure the immutability of its containers.

## Requirements

Modify the existing Deployment named `lamp-deployment`, running in namespace `lamp`, so that its containers:

- run with user ID `20000`
- use a read-only root filesystem
- forbid privilege escalation

The Deployment's manifest file can be found at `/home/candidate/finer-sunbeam/lamp-deployment.yaml`.

## Verify
```bash
kubectl -n lamp get deploy lamp-deployment
```
