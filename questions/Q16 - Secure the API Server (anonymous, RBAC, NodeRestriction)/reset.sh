#!/bin/bash
[ -f /etc/kubernetes/manifests/kube-apiserver.yaml.bak.q16 ] && mv /etc/kubernetes/manifests/kube-apiserver.yaml.bak.q16 /etc/kubernetes/manifests/kube-apiserver.yaml
sleep 20
kubectl --kubeconfig /etc/kubernetes/admin.conf delete clusterrolebinding system:anonymous --ignore-not-found 2>/dev/null
echo "Q16 reset done. (API server restarts — wait ~60s)"
