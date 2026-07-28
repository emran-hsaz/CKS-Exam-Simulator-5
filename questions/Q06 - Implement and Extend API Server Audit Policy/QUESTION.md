# Implement and Extend an API Server Audit Policy

**Domain:** Monitoring, Logging and Runtime Security · **Weight:** 7

## Context
You must implement auditing for the kubeadm provisioned cluster.

## Requirements

**First**, reconfigure the cluster's API server so that:

- the basic audit policy located at `/etc/kubernetes/logpolicy/audit-policy.yaml` is used,
- logs are stored at `/var/log/kubernetes/audit-logs.txt`,
- a maximum of **2** logs are retained for **10** days.

The basic policy only specifies what **not** to log.

**Next**, edit and extend the basic policy to log:

- `namespaces` interactions at `RequestResponse` level
- the request body (`Request` level) of `deployments` interactions in the namespace `webapps`
- `ConfigMap` and `Secret` interactions in **all** namespaces at the `Metadata` level
- all other requests at the `Metadata` level

Make sure the API server uses the extended policy. Failure to do so may result in a reduced score.

> **Important — restart gotcha:** the API server reads the audit policy file **only at startup**. The kubelet only watches the *manifest* `kube-apiserver.yaml`, not the referenced policy file. So after you edit `/etc/kubernetes/logpolicy/audit-policy.yaml`, you must force an API server restart for the new policy to take effect — e.g. `touch /etc/kubernetes/manifests/kube-apiserver.yaml` (or briefly move it out and back). The `audit-logs.txt` file only appears once the API server restarts with the flags in place.

## Verify
```bash
ls -l /var/log/kubernetes/audit-logs.txt
kubectl get nodes
```
