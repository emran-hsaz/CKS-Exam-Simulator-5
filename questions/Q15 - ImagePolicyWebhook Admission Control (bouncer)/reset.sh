#!/bin/bash
[ -f /etc/kubernetes/manifests/kube-apiserver.yaml.bak.q15 ] && mv /etc/kubernetes/manifests/kube-apiserver.yaml.bak.q15 /etc/kubernetes/manifests/kube-apiserver.yaml
rm -rf /etc/kubernetes/bouncer /home/candidate/vulnerable.yaml
kubectl delete pod vulnerable -n default --ignore-not-found 2>/dev/null
echo "Q15 reset done. (API server restarts — wait ~60s)"
