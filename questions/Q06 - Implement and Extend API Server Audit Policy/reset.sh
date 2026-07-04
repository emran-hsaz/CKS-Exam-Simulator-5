#!/bin/bash
[ -f /etc/kubernetes/manifests/kube-apiserver.yaml.bak.q6 ] && mv /etc/kubernetes/manifests/kube-apiserver.yaml.bak.q6 /etc/kubernetes/manifests/kube-apiserver.yaml
rm -rf /etc/kubernetes/logpolicy /var/log/kubernetes/audit-logs.txt
echo "Q6 reset done. (API server restarts — wait ~60s)"
