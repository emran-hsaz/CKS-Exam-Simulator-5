#!/bin/bash
echo "Setting up Q8 — web Service + web-cert Secret in prod..."
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace prod env=prod --overwrite
kubectl -n prod create deployment web --image=nginx:alpine --dry-run=client -o yaml | kubectl apply -f -
kubectl -n prod expose deployment web --port=80 --dry-run=client -o yaml | kubectl apply -f -
TMP=$(mktemp -d)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$TMP/tls.key" -out "$TMP/tls.crt" -subj "/CN=web.k8s.local" 2>/dev/null
kubectl -n prod create secret tls web-cert --cert="$TMP/tls.crt" --key="$TMP/tls.key" \
  --dry-run=client -o yaml | kubectl apply -f -
rm -rf "$TMP"
echo ""
echo "Done. Service web and Secret web-cert exist in namespace prod. Create the Ingress."
