#!/bin/bash
kubectl delete namespace alpine --ignore-not-found
rm -f /home/candidate/alpine.spdx
echo "Q11 reset done."
