#!/bin/bash
echo "Setting up Q12 — restricted-ns with non-compliant pss-app..."
kubectl create namespace restricted-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace restricted-ns \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/warn=restricted --overwrite
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pss-app
  namespace: restricted-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pss-app
  template:
    metadata:
      labels:
        app: pss-app
    spec:
      containers:
        - name: pss-app
          image: busybox:latest
          command: ["sh", "-c", "sleep 3600"]
          securityContext:
            privileged: true
            allowPrivilegeEscalation: true
YAML
echo ""
echo "Done. pss-app Pods are rejected by the restricted PSS — fix the Deployment."
