#!/bin/bash
echo "Setting up Q10 — node upgrade scenario..."
echo ""
echo "Current node versions:"
kubectl get nodes -o wide 2>/dev/null || echo "(kubectl not available here — run from control plane)"
echo ""
echo "This question requires a worker node on kubelet v1.30.0 with the v1.30 apt repo configured."
echo "Steps: drain → ssh → apt-get install kubeadm=1.30.1-* → kubeadm upgrade node →"
echo "       apt-get install kubelet=1.30.1-* kubectl=1.30.1-* → restart kubelet → uncordon"
