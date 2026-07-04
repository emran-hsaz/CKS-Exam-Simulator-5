#!/bin/bash
echo "Setting up Q16 — insecure API server..."
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
if [ -f "$APISERVER" ]; then
  cp "$APISERVER" "${APISERVER}.bak.q16"
  sed -i 's/--authorization-mode=.*/--authorization-mode=AlwaysAllow/' "$APISERVER"
  grep -q 'anonymous-auth' "$APISERVER" \
    && sed -i 's/--anonymous-auth=.*/--anonymous-auth=true/' "$APISERVER" \
    || sed -i '/- kube-apiserver/a\    - --anonymous-auth=true' "$APISERVER"
fi
sleep 20
kubectl --kubeconfig /etc/kubernetes/admin.conf create clusterrolebinding system:anonymous \
  --clusterrole=cluster-admin --user=system:anonymous 2>/dev/null || true
echo ""
echo "Done. The API server allows anonymous, unauthorized access. Secure it."
