#!/bin/bash
B=/etc/kubernetes/bouncer
[ -f "$B/scanner.pid" ] && kill "$(cat "$B/scanner.pid")" 2>/dev/null
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
[ -f "${APISERVER}.bak.q15" ] && cp "${APISERVER}.bak.q15" "$APISERVER"
kubectl delete pod vulnerable -n default --ignore-not-found 2>/dev/null
sed -i '/smooth-yak.local/d' /etc/hosts 2>/dev/null
rm -rf "$B" /home/candidate/vulnerable.yaml /var/log/nginx/access_log
echo "Q15 reset done. (API server restarts — wait ~60s.)"
