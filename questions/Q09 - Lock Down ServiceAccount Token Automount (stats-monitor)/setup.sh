#!/bin/bash
echo "Setting up Q9 — stats-monitor ServiceAccount scenario..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl -n monitoring create serviceaccount stats-monitor-sa --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stats-monitor
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stats-monitor
  template:
    metadata:
      labels:
        app: stats-monitor
    spec:
      serviceAccountName: stats-monitor-sa
      containers:
        - name: stats-monitor
          image: busybox:latest
          command: ["sh", "-c", "sleep 3600"]
YAML
echo ""
echo "Done. Disable automount on the SA, then inject the token via a projected volume."
