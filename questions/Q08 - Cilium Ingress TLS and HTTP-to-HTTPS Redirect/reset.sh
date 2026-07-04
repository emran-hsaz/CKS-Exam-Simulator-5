#!/bin/bash
kubectl delete ingress web -n prod --ignore-not-found
kubectl delete svc web -n prod --ignore-not-found
kubectl delete deployment web -n prod --ignore-not-found
kubectl delete secret web-cert -n prod --ignore-not-found
echo "Q8 reset done."
