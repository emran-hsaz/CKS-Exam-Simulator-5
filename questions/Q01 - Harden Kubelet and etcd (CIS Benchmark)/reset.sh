#!/bin/bash
[ -f /var/lib/kubelet/config.yaml.bak.q1 ] && mv /var/lib/kubelet/config.yaml.bak.q1 /var/lib/kubelet/config.yaml && systemctl restart kubelet 2>/dev/null
[ -f /etc/kubernetes/manifests/etcd.yaml.bak.q1 ] && mv /etc/kubernetes/manifests/etcd.yaml.bak.q1 /etc/kubernetes/manifests/etcd.yaml
echo "Q1 reset done."
