# ImagePolicyWebhook Admission Control

**Domain:** Supply Chain Security · **Weight:** 7

## Context
You must fully integrate a container image scanner into the kubeadm provisioned cluster.

## Requirements

Given an incomplete configuration located at `/etc/kubernetes/bouncer` and a functional container image scanner with an HTTPS endpoint at `https://smooth-yak.local/review`:

1. Re-configure the API server to enable all admission plugin(s) needed to support the provided AdmissionConfiguration.
2. Re-configure the ImagePolicyWebhook configuration to **deny images on backend failure**.
3. Complete the backend configuration to point to the scanner's endpoint at `https://smooth-yak.local/review`.
4. To test, deploy the resource defined in `/home/candidate/vulnerable.yaml` — it uses an image that should be denied. You may delete and re-create the resource as often as needed.

The scanner's log file is located at `/var/log/nginx/access_log`. The scanner denies any image whose name contains `vulnerable`.

> **Restart gotcha:** the API server reads the admission config and its webhook kubeconfig **only at startup**. The kubelet watches the *manifest* `kube-apiserver.yaml`, not the files it references. After you edit `admission_config.yaml` (set `defaultAllow: false`) and `kubeconfig.yaml` (set the `server:`), you MUST restart the API server for the changes to take effect — e.g. `touch /etc/kubernetes/manifests/kube-apiserver.yaml`, then wait ~60s. If you skip this, the files will look correct but the running API server will still use the old config and the vulnerable Pod will NOT be denied.

## Verify
```bash
kubectl get pod -n kube-system | grep apiserver
kubectl apply -f /home/candidate/vulnerable.yaml   # should be DENIED
```
