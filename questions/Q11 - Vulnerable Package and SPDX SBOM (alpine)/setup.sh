#!/bin/bash
echo "Setting up Q11 — alpine Deployment with three image versions..."
kubectl create namespace alpine --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alpine
  namespace: alpine
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alpine
  template:
    metadata:
      labels:
        app: alpine
    spec:
      containers:
        - name: alpine-1
          image: alpine:3.18.4
          command: ["sh", "-c", "sleep 3600"]
        - name: alpine-2
          image: alpine:3.19.1
          command: ["sh", "-c", "sleep 3600"]
        - name: alpine-3
          image: alpine:3.20.0
          command: ["sh", "-c", "sleep 3600"]
YAML
mkdir -p /home/candidate
echo ""
echo "Done. Find the image shipping libcrypto3 3.1.4-r5, then generate the SPDX SBOM with bom."
