#!/bin/bash
kubectl delete namespace clever-cactus --ignore-not-found
rm -rf /home/candidate/clever-cactus
echo "Q2 reset done."
