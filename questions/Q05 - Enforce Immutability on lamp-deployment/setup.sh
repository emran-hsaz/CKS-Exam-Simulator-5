#!/bin/bash
echo "Setting up Q5 — lamp-deployment (mutable containers)..."
kubectl create namespace lamp --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /home/candidate/finer-sunbeam
cat > /home/candidate/finer-sunbeam/lamp-deployment.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lamp-deployment
  namespace: lamp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lamp
  template:
    metadata:
      labels:
        app: lamp
    spec:
      containers:
        - name: lamp
          image: busybox:latest
          command: ["sh", "-c", "sleep 3600"]
YAML
kubectl apply -f /home/candidate/finer-sunbeam/lamp-deployment.yaml
echo ""
echo "Done. Manifest: /home/candidate/finer-sunbeam/lamp-deployment.yaml"
