# Secure the API Server (Anonymous Auth, Node,RBAC, NodeRestriction)

**Domain:** Cluster Setup · **Weight:** 6

## Context
For testing purposes, the kubeadm provisioned cluster's API server was configured to allow unauthenticated and unauthorized access.

## Requirements

**First**, secure the cluster's API server, configuring it as follows:

- Forbid anonymous authentication (`--anonymous-auth=false`)
- Use authorization mode `Node,RBAC`
- Use admission controller `NodeRestriction`

`kubectl` is configured to use unauthenticated and unauthorized access. You do not have to change it, but be aware that `kubectl` will stop working once you have secured the cluster. You can use the cluster's original kubectl configuration file at `/etc/kubernetes/admin.conf` to access the secured cluster.

**Next**, to clean up, remove the ClusterRoleBinding `system:anonymous`.

## Verify
```bash
kubectl --kubeconfig /etc/kubernetes/admin.conf get nodes
kubectl --kubeconfig /etc/kubernetes/admin.conf get clusterrolebinding system:anonymous
```
