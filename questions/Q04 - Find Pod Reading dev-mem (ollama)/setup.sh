#!/bin/bash
echo "Setting up Q4 — ollama application, one Pod reading /dev/mem..."
kubectl create namespace ollama --dry-run=client -o yaml | kubectl apply -f -
for name in ollama-api ollama-web; do
kubectl apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $name
  namespace: ollama
  labels:
    app.kubernetes.io/part-of: ollama
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $name
  template:
    metadata:
      labels:
        app: $name
        app.kubernetes.io/part-of: ollama
    spec:
      containers:
        - name: main
          image: busybox:latest
          command: ["sh", "-c", "while true; do echo serving; sleep 10; done"]
YAML
done
# the offender
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama-batch
  namespace: ollama
  labels:
    app.kubernetes.io/part-of: ollama
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama-batch
  template:
    metadata:
      labels:
        app: ollama-batch
        app.kubernetes.io/part-of: ollama
    spec:
      containers:
        - name: main
          image: busybox:latest
          command:
            - sh
            - -c
            - |
              while true; do
                head -c 1 /dev/mem 2>/dev/null || dd if=/dev/mem bs=1 count=1 2>/dev/null || true
                sleep 5
              done
          securityContext:
            privileged: true
YAML
echo ""
echo "Done. Three Deployments run in namespace ollama. One reads /dev/mem — find it with Falco."
