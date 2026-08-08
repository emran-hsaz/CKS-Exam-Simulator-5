# Configure Istio Sidecar Injection and Namespace-wide mTLS

**Domain:** Cluster Hardening · **Weight:** 7

## Task
Istio is installed in the cluster. Deployment `target-app` runs in namespace `app-ns`, but the namespace was never enabled for sidecar injection, so its pods are not in the mesh.

## Requirements

1. Enable Istio sidecar injection on namespace `app-ns` (the namespace label documented on Istio's sidecar-injection page)
2. Roll the `target-app` workload so its pods are recreated and would be admitted with the sidecar injected — existing pods are never injected retroactively
3. Create a `PeerAuthentication` named `default` in namespace `app-ns` that enforces **STRICT** mutual TLS for the whole namespace

> Note: This lab ships the Istio security CRDs without the istiod webhook, so no istio-proxy container is literally added to the pods — do not wait for 2/2. Grading checks the work you do: the namespace label, the re-roll, and the policy.

## Verify
```bash
kubectl get ns app-ns --show-labels
kubectl -n app-ns get deployment target-app -o jsonpath='{.spec.template.metadata.annotations}'
kubectl -n app-ns get peerauthentication default -o yaml
```
