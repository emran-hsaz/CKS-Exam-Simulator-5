# Configure Istio Mutual TLS (mTLS) Authentication

**Domain:** Cluster Hardening · **Weight:** 7

## Task
Istio is installed in the cluster. Deployment `target-app` runs in namespace `app-ns`; `client-pod` runs in namespace `client-ns`.

## Requirements

1. Create a `PeerAuthentication` named `target-mtls` in namespace `app-ns` that requires **STRICT** mutual TLS for the `target-app` workload (selector `app: target-app`)
2. Add a **port-level exception** so port `8080` uses **PERMISSIVE** mode (allowing non-mTLS health/probe traffic)
3. Create an `AuthorizationPolicy` named `allow-client` in namespace `app-ns` that allows requests to `target-app` only from namespace `client-ns`

## Verify
```bash
kubectl -n app-ns get peerauthentication
kubectl -n app-ns get authorizationpolicy
```
