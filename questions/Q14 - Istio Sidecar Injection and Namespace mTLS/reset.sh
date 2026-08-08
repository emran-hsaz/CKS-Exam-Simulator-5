#!/bin/bash
kubectl delete peerauthentication target-mtls -n app-ns --ignore-not-found 2>/dev/null
kubectl delete authorizationpolicy allow-client -n app-ns --ignore-not-found 2>/dev/null
kubectl delete namespace app-ns client-ns --ignore-not-found
echo "Q14 reset done."
