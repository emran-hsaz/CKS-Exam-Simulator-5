#!/bin/bash
echo "Setting up Q7 — prod/data namespaces..."
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace data --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace prod env=prod --overwrite
kubectl label namespace data env=data --overwrite
kubectl -n prod create deployment prod-app --image=nginx:alpine --dry-run=client -o yaml | kubectl apply -f -
kubectl -n data create deployment data-app --image=nginx:alpine --dry-run=client -o yaml | kubectl apply -f -
echo ""
echo "Done. Create the two NetworkPolicies."
