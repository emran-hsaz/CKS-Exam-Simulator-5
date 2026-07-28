# Upgrade a Worker Node by One Patch Version (apt + kubeadm)

**Domain:** Cluster Setup · **Weight:** 6

> **Environment requirement:** this task needs a **multi-node cluster** (control plane + a separate worker one patch version behind). It cannot be practiced on a single-node Killercoda playground — use a killer.sh-style 2-node environment. On a single-node cluster the grader will tell you the environment is unsupported instead of failing your answer.

## Task
The worker node is running an older kubelet patch version (`v1.30.0`) and must be upgraded to `v1.30.1`.

## Access
The upgrade is performed on the worker node itself. SSH access is enabled — connect from this node with:
```bash
ssh root@<worker-node>   # password: Kd7wA3fX
```
The Kubernetes apt repository (v1.30) is already configured on the worker, so you can install specific package versions with `apt-get`.

## Requirements

1. Identify the worker node name with `kubectl get nodes`
2. **Drain** the worker node
3. SSH to the worker; upgrade `kubeadm`, run `kubeadm upgrade node`, then upgrade `kubelet` and `kubectl` to `v1.30.1` with the package manager and restart the kubelet
4. **Uncordon** the node

Verify that the worker node is `Ready` and running `v1.30.1`.

> After restarting the kubelet, the node may take up to 60 seconds to report the new version and return to Ready.
