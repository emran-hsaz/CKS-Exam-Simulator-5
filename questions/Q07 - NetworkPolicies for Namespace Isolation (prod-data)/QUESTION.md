# NetworkPolicies for Namespace Isolation

**Domain:** Cluster Hardening · **Weight:** 7

## Context
You must implement NetworkPolicies controlling the traffic flow of existing Deployments across namespaces.

## Requirements

1. Create a NetworkPolicy named `deny-policy` in the `prod` namespace to **block all ingress traffic**. The `prod` namespace is labeled `env: prod`.

2. Create a NetworkPolicy named `allow-from-prod` in the `data` namespace to **allow ingress traffic only from Pods in the `prod` namespace**. Use the label of the `prod` namespace to allow traffic. The `data` namespace is labeled `env: data`.

Do not modify or delete any namespaces or Pods. Only create the required NetworkPolicies.

## Verify
```bash
kubectl -n prod get networkpolicy
kubectl -n data get networkpolicy
```
