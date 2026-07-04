#!/bin/bash
echo "Setting up Q14 — Istio mTLS scenario..."
# Minimal Istio security CRDs so the resources can be created even without a full Istio install
for kind in peerauthentications:PeerAuthentication authorizationpolicies:AuthorizationPolicy; do
  plural=${kind%%:*}; k=${kind##*:}
  kubectl get crd ${plural}.security.istio.io >/dev/null 2>&1 || kubectl apply -f - <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: ${plural}.security.istio.io
spec:
  group: security.istio.io
  names:
    kind: ${k}
    listKind: ${k}List
    plural: ${plural}
    singular: $(echo ${k} | tr 'A-Z' 'a-z')
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
done
kubectl create namespace app-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace client-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl -n app-ns create deployment target-app --image=nginx:alpine --dry-run=client -o yaml | kubectl apply -f -
kubectl -n client-ns run client-pod --image=busybox:latest --command -- sh -c "sleep 3600" 2>/dev/null || true
echo ""
echo "Done. Create the PeerAuthentication and AuthorizationPolicy."
