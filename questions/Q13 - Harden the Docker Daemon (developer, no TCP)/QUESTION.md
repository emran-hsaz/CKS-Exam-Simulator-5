# Harden the Docker Daemon on a Node

**Domain:** System Hardening · **Weight:** 7

## Requirements

Perform the following tasks to secure the cluster node:

1. Remove user `developer` from the `docker` group. Do **not** remove the user from any other group.
2. Reconfigure and restart the Docker daemon to ensure that the Unix socket belongs to the group `root`.
3. Reconfigure and restart the Docker daemon to ensure it does **not** listen on any TCP port.

After completing your work, ensure the Kubernetes cluster is healthy.

> If the node has no live systemd/dockerd, edit the configuration directly — the grader inspects the on-disk config (`/etc/docker/daemon.json`).

## Verify
```bash
groups developer
cat /etc/docker/daemon.json
```
