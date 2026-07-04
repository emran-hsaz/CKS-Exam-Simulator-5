# Harden the Kubelet and etcd (CIS Benchmark)

**Domain:** Cluster Setup · **Weight:** 6

## Context
You must resolve issues that a CIS Benchmark tool found for the kubeadm provisioned cluster.
Fix all issues via configuration and restart the affected components to ensure the new settings take effect.

## Requirements

Fix all of the following violations found against the **kubelet**:

- Ensure that the `anonymous-auth` argument is set to `false` — **FAIL**
- Ensure that the `--authorization-mode` argument is not set to `AlwaysAllow` — **FAIL**

Use Webhook authentication/authorization where possible.

Fix the following violation found against **etcd**:

- Ensure that the `--client-cert-auth` argument is set to `true` — **FAIL**

> This node runs containerd — use `crictl` (or `kubectl`) where the exam says `docker`.

## Verify
```bash
kubectl get nodes
```
The node must be `Ready` (allow up to 60 seconds after restarting the kubelet).
