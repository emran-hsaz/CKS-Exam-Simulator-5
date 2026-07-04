#!/bin/bash
echo "Setting up Q15 — incomplete ImagePolicyWebhook config at /etc/kubernetes/bouncer..."
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
mkdir -p /etc/kubernetes/bouncer /home/candidate
cat > /etc/kubernetes/bouncer/admission_config.yaml <<'CFG'
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
  - name: ImagePolicyWebhook
    configuration:
      imagePolicy:
        kubeConfigFile: /etc/kubernetes/bouncer/kubeconfig.yaml
        allowTTL: 50
        denyTTL: 50
        retryBackoff: 500
        defaultAllow: true
CFG
cat > /etc/kubernetes/bouncer/kubeconfig.yaml <<'KC'
apiVersion: v1
kind: Config
clusters:
  - name: image-scanner
    cluster:
      certificate-authority: /etc/kubernetes/bouncer/ca.crt
      server:
contexts:
  - name: scanner
    context:
      cluster: image-scanner
      user: api-server
current-context: scanner
users:
  - name: api-server
    user:
      client-certificate: /etc/kubernetes/bouncer/apiserver-client.crt
      client-key: /etc/kubernetes/bouncer/apiserver-client.key
KC
touch /etc/kubernetes/bouncer/ca.crt /etc/kubernetes/bouncer/apiserver-client.crt /etc/kubernetes/bouncer/apiserver-client.key
cat > /home/candidate/vulnerable.yaml <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: vulnerable
  namespace: default
spec:
  containers:
    - name: vulnerable
      image: vulnerable-image:latest
YAML
if [ -f "$APISERVER" ]; then
  cp "$APISERVER" "${APISERVER}.bak.q15"
fi
echo ""
echo "Done. Complete the config in /etc/kubernetes/bouncer and enable the plugin on the API server."
