#!/bin/bash
echo "Setting up Q2 — clever-cactus TLS scenario..."
kubectl create namespace clever-cactus --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /home/candidate/clever-cactus
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /home/candidate/clever-cactus/web.k8s.local.key \
  -out    /home/candidate/clever-cactus/web.k8s.local.crt \
  -subj "/CN=web.k8s.local/O=clever-cactus" 2>/dev/null
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: clever-cactus
  namespace: clever-cactus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: clever-cactus
  template:
    metadata:
      labels:
        app: clever-cactus
    spec:
      containers:
        - name: web
          image: nginx:alpine
          volumeMounts:
            - name: tls
              mountPath: /etc/tls
              readOnly: true
      volumes:
        - name: tls
          secret:
            secretName: clever-cactus
YAML
echo ""
echo "Done. Deployment clever-cactus is failing — Secret clever-cactus does not exist yet."
