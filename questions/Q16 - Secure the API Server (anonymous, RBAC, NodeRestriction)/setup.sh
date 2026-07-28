#!/bin/bash
echo "Setting up Q16 — insecure API server..."
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
K="kubectl --kubeconfig /etc/kubernetes/admin.conf"

if [ -f "$APISERVER" ]; then
  cp "$APISERVER" "${APISERVER}.bak.q16"
  sed -i 's/--authorization-mode=.*/--authorization-mode=AlwaysAllow/' "$APISERVER"
  grep -q 'anonymous-auth' "$APISERVER" \
    && sed -i 's/--anonymous-auth=.*/--anonymous-auth=true/' "$APISERVER" \
    || sed -i '/- kube-apiserver/a\    - --anonymous-auth=true' "$APISERVER"
fi

# --- Wait for the API server to actually come back up, instead of a blind sleep ---
echo -n "Waiting for API server to restart"
ready=false
for i in $(seq 1 24); do  # up to ~120s
  if $K get --raw='/readyz' >/dev/null 2>&1; then
    ready=true
    break
  fi
  echo -n "."
  sleep 5
done
echo ""

if [ "$ready" != "true" ]; then
  echo "⚠️  API server did not become ready within 120s."
  echo "    Check manually: crictl ps -a | grep kube-apiserver"
  echo "    Then re-run: ./cks setup 16"
fi

# --- Create the CRB, and report clearly if it fails (no more silent swallow) ---
if $K create clusterrolebinding system:anonymous \
     --clusterrole=cluster-admin --user=system:anonymous 2>/tmp/q16-crb-err.log; then
  echo "✔ ClusterRoleBinding system:anonymous created"
else
  if grep -q 'AlreadyExists' /tmp/q16-crb-err.log 2>/dev/null; then
    echo "✔ ClusterRoleBinding system:anonymous already exists"
  else
    echo "✘ FAILED to create ClusterRoleBinding system:anonymous:"
    cat /tmp/q16-crb-err.log
    echo "    Fix manually with:"
    echo "    kubectl --kubeconfig /etc/kubernetes/admin.conf create clusterrolebinding system:anonymous --clusterrole=cluster-admin --user=system:anonymous"
  fi
fi
rm -f /tmp/q16-crb-err.log

echo ""
echo "Done. The API server allows anonymous, unauthorized access. Secure it."
