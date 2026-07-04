# Lock Down ServiceAccount Token Automounting

**Domain:** Minimize Microservice Vulnerabilities · **Weight:** 7

## Context
A security audit has identified a Deployment improperly handling service account tokens, which could lead to security vulnerabilities.

## Requirements

1. Modify the existing ServiceAccount `stats-monitor-sa` in the namespace `monitoring` to **turn off automounting** of API credentials.

2. Modify the existing Deployment `stats-monitor` in the namespace `monitoring` to inject a ServiceAccount token mounted at `/var/run/secrets/kubernetes.io/serviceaccount/token`.

3. Use a **Projected Volume named `token`** to inject the ServiceAccount token and ensure that it is mounted **read-only**.

## Verify
```bash
kubectl -n monitoring get pods
kubectl -n monitoring get pod -l app=stats-monitor -o yaml | grep -A10 projected
```
