#!/bin/bash
echo "Setting up Q6 — audit policy scenario..."
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
mkdir -p /etc/kubernetes/logpolicy /var/log/kubernetes
cat > /etc/kubernetes/logpolicy/audit-policy.yaml <<'POLICY'
apiVersion: audit.k8s.io/v1
kind: Policy
omitStages:
  - "RequestReceived"
rules:
  # Do not log requests from the kube-proxy on endpoints/services
  - level: None
    users: ["system:kube-proxy"]
    verbs: ["watch"]
    resources:
      - group: ""
        resources: ["endpoints", "services"]
  # Do not log authenticated health checks
  - level: None
    userGroups: ["system:authenticated"]
    nonResourceURLs: ["/api*", "/version"]
POLICY
if [ -f "$APISERVER" ]; then
  cp "$APISERVER" "${APISERVER}.bak.q6"
  sed -i '/audit-policy-file/d;/audit-log-path/d;/audit-log-maxbackup/d;/audit-log-maxage/d;/audit-log-maxsize/d' "$APISERVER"
fi
echo "Done."
echo "  Basic policy: /etc/kubernetes/logpolicy/audit-policy.yaml"
echo "  Configure the API server flags, then extend the policy."
