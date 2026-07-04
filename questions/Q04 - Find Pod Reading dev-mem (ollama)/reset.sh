#!/bin/bash
kubectl delete namespace ollama --ignore-not-found
rm -f /etc/falco/rules.d/devmem*.yaml 2>/dev/null
echo "Q4 reset done."
