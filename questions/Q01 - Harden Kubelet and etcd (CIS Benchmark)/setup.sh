#!/bin/bash
echo "Setting up Q1 — introducing CIS violations in kubelet and etcd..."
KUBELET_CONFIG="/var/lib/kubelet/config.yaml"
if [ -f "$KUBELET_CONFIG" ]; then
  cp "$KUBELET_CONFIG" "${KUBELET_CONFIG}.bak.q1"
  python3 - <<PY 2>/dev/null || true
import yaml
p = "$KUBELET_CONFIG"
c = yaml.safe_load(open(p))
c.setdefault('authentication',{}).setdefault('anonymous',{})['enabled'] = True
c.setdefault('authorization',{})['mode'] = 'AlwaysAllow'
yaml.dump(c, open(p,'w'), default_flow_style=False)
print("kubelet made insecure: anonymous=true, mode=AlwaysAllow")
PY
  systemctl restart kubelet 2>/dev/null || true
fi
ETCD="/etc/kubernetes/manifests/etcd.yaml"
if [ -f "$ETCD" ]; then
  cp "$ETCD" "${ETCD}.bak.q1"
  sed -i 's/--client-cert-auth=true/--client-cert-auth=false/' "$ETCD" 2>/dev/null || true
  grep -q 'client-cert-auth' "$ETCD" || sed -i '/- etcd$/a\    - --client-cert-auth=false' "$ETCD" 2>/dev/null || true
  echo "etcd made insecure: --client-cert-auth=false"
fi
echo ""
echo "Done. Fix the kubelet config and etcd manifest, then restart the components."
