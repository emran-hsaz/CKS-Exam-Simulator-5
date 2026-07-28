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

# --- Ensure bom and trivy are available (task assumes they are pre-installed) ---
if ! command -v bom >/dev/null 2>&1; then
  echo "Installing bom (SBOM tool)..."
  wget -qO /usr/local/bin/bom "https://github.com/kubernetes-sigs/bom/releases/download/v0.6.0/bom-amd64-linux" 2>/dev/null && chmod +x /usr/local/bin/bom ||     echo "  ⚠️  could not auto-install bom — install manually from https://github.com/kubernetes-sigs/bom/releases"
fi
if ! command -v trivy >/dev/null 2>&1; then
  echo "Installing trivy (for the hint; not strictly required)..."
  apt-get update -qq 2>/dev/null; apt-get install -y wget gnupg 2>/dev/null || true
  wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key 2>/dev/null | gpg --dearmor -o /usr/share/keyrings/trivy.gpg 2>/dev/null
  echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" > /etc/apt/sources.list.d/trivy.list 2>/dev/null
  apt-get update -qq 2>/dev/null; apt-get install -y trivy 2>/dev/null || true
fi
command -v bom   >/dev/null 2>&1 && echo "  ✔ bom installed:   $(bom version 2>/dev/null | head -1)" || echo "  ✘ bom NOT available"
command -v trivy >/dev/null 2>&1 && echo "  ✔ trivy installed" || echo "  ✘ trivy NOT available (optional)"
echo ""
echo "Done. Find the image shipping libcrypto3 3.1.4-r5, then generate the SPDX SBOM with bom."
