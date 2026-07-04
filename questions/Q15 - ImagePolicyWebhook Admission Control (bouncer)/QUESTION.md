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

The scanner's log file is located at `/var/log/nginx/access_log`.

## Verify
```bash
kubectl get pod -n kube-system | grep apiserver
kubectl apply -f /home/candidate/vulnerable.yaml   # should be DENIED
```
