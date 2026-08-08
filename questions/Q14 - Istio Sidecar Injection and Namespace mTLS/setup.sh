#!/bin/bash
echo "Setting up Q14 — Istio sidecar injection + namespace-wide mTLS..."
# Minimal PeerAuthentication CRD so the resource can be created even without a full Istio install
kubectl get crd peerauthentications.security.istio.io >/dev/null 2>&1 || kubectl apply -f - <<'YAML'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: peerauthentications.security.istio.io
spec:
  group: security.istio.io
  names:
    kind: PeerAuthentication
    listKind: PeerAuthenticationList
    plural: peerauthentications
    singular: peerauthentication
  scope: Namespaced
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          x-kubernetes-preserve-unknown-fields: true
    - name: v1beta1
      served: true
      storage: false
      schema:
        openAPIV3Schema:
          type: object
          x-kubernetes-preserve-unknown-fields: true
YAML

# app-ns WITHOUT the injection label — candidate must add it
kubectl create namespace app-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace app-ns istio-injection- >/dev/null 2>&1 || true

kubectl -n app-ns create deployment target-app --image=nginx:alpine --dry-run=client -o yaml | kubectl apply -f -
kubectl -n app-ns rollout status deployment target-app --timeout=60s >/dev/null 2>&1

echo ""
echo "Done. Namespace app-ns and Deployment target-app exist; injection is NOT yet enabled."
