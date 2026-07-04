# Find and Contain the Pod Reading /dev/mem (ollama)

**Domain:** Monitoring, Logging and Runtime Security · **Weight:** 7

## Context
A Pod is misbehaving and poses a security threat to the system.

## Requirements

One of the Pods belonging to the application `ollama` (namespace `ollama`) is misbehaving: it is directly accessing the system's memory, reading from the sensitive file `/dev/mem`.

1. Identify the misbehaving Pod accessing `/dev/mem`.
   - Falco is preinstalled as a DaemonSet (namespace `falco`) and loads rules from `/etc/falco/rules.d/` — writing a small detection rule is the fastest way to catch the offender (`crictl` works too).
2. Identify the Deployment managing the misbehaving Pod and **scale it to zero replicas**.

Do not modify the Deployment except for scaling it down. Do not modify or delete any other Deployments.

> Only the containment is graded: the offending Deployment at 0 replicas with the other Deployments untouched.

## Verify
```bash
kubectl -n ollama get deploy
```
