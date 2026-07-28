#!/bin/bash
K="kubectl --kubeconfig /etc/kubernetes/admin.conf"

[ -f /etc/kubernetes/manifests/kube-apiserver.yaml.bak.q16 ] && \
  mv /etc/kubernetes/manifests/kube-apiserver.yaml.bak.q16 /etc/kubernetes/manifests/kube-apiserver.yaml

echo -n "Waiting for API server to restart"
for i in $(seq 1 24); do
  $K get --raw='/readyz' >/dev/null 2>&1 && break
  echo -n "."
  sleep 5
done
echo ""

$K delete clusterrolebinding system:anonymous --ignore-not-found 2>/dev/null
echo "Q16 reset done."
