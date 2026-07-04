#!/bin/bash
kubectl delete netpol deny-policy -n prod --ignore-not-found
kubectl delete netpol allow-from-prod -n data --ignore-not-found
kubectl delete namespace data --ignore-not-found
kubectl delete deployment prod-app -n prod --ignore-not-found
echo "Q7 reset done. (namespace prod kept if Q8 is active)"
