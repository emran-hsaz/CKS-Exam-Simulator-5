#!/bin/bash
echo "Setting up Q15 — ImagePolicyWebhook with a REAL scanner backend at /etc/kubernetes/bouncer..."
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
B=/etc/kubernetes/bouncer
mkdir -p "$B" /home/candidate /var/log/nginx

# ---------------------------------------------------------------------------
# 1. Real PKI so the API server can actually establish TLS to the scanner
# ---------------------------------------------------------------------------
if [ ! -s "$B/ca.crt" ]; then
  openssl genrsa -out "$B/ca.key" 2048 2>/dev/null
  openssl req -x509 -new -nodes -key "$B/ca.key" -days 3650 -subj "/CN=bouncer-ca" -out "$B/ca.crt" 2>/dev/null
  # server cert for smooth-yak.local (with SAN)
  openssl genrsa -out "$B/server.key" 2048 2>/dev/null
  openssl req -new -key "$B/server.key" -subj "/CN=smooth-yak.local" -out "$B/server.csr" 2>/dev/null
  openssl x509 -req -in "$B/server.csr" -CA "$B/ca.crt" -CAkey "$B/ca.key" -CAcreateserial \
    -out "$B/server.crt" -days 3650 -extfile <(printf "subjectAltName=DNS:smooth-yak.local") 2>/dev/null
  # client cert the API server presents (referenced by the incomplete kubeconfig)
  openssl genrsa -out "$B/apiserver-client.key" 2048 2>/dev/null
  openssl req -new -key "$B/apiserver-client.key" -subj "/CN=kube-apiserver" -out "$B/apiserver-client.csr" 2>/dev/null
  openssl x509 -req -in "$B/apiserver-client.csr" -CA "$B/ca.crt" -CAkey "$B/ca.key" -CAcreateserial \
    -out "$B/apiserver-client.crt" -days 3650 2>/dev/null
fi

# ---------------------------------------------------------------------------
# 2. Resolve smooth-yak.local -> localhost so the API server can reach it
# ---------------------------------------------------------------------------
grep -q 'smooth-yak.local' /etc/hosts || echo "127.0.0.1 smooth-yak.local" >> /etc/hosts

# ---------------------------------------------------------------------------
# 3. A real HTTPS ImageReview webhook: denies any image containing 'vulnerable'
# ---------------------------------------------------------------------------
cat > "$B/scanner.py" <<'PY'
#!/usr/bin/env python3
import ssl, json
from http.server import BaseHTTPRequestHandler, HTTPServer
from datetime import datetime, timezone
LOG = "/var/log/nginx/access_log"
class H(BaseHTTPRequestHandler):
    def do_POST(self):
        n = int(self.headers.get('Content-Length', 0) or 0)
        raw = self.rfile.read(n) if n else b'{}'
        try: review = json.loads(raw)
        except Exception: review = {}
        imgs = [c.get('image','') for c in review.get('spec',{}).get('containers',[])]
        bad = any('vulnerable' in i for i in imgs)
        allowed = not bad
        reason = "" if allowed else "image rejected by smooth-yak scanner (known vulnerabilities)"
        out = {"apiVersion": review.get('apiVersion','imagepolicy.k8s.io/v1alpha1'),
               "kind":"ImageReview",
               "status":{"allowed":allowed,"reason":reason}}
        try:
            with open(LOG,"a") as f:
                f.write(f'{datetime.now(timezone.utc).isoformat()} POST /review images={imgs} allowed={allowed}\n')
        except Exception: pass
        body = json.dumps(out).encode()
        self.send_response(200); self.send_header('Content-Type','application/json')
        self.send_header('Content-Length',str(len(body))); self.end_headers()
        self.wfile.write(body)
    def log_message(self,*a): pass
if __name__ == '__main__':
    srv = HTTPServer(('0.0.0.0',443), H)
    ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ctx.load_cert_chain('/etc/kubernetes/bouncer/server.crt','/etc/kubernetes/bouncer/server.key')
    srv.socket = ctx.wrap_socket(srv.socket, server_side=True)
    srv.serve_forever()
PY

# (re)start the scanner idempotently
if [ -f "$B/scanner.pid" ] && kill -0 "$(cat "$B/scanner.pid")" 2>/dev/null; then
  kill "$(cat "$B/scanner.pid")" 2>/dev/null; sleep 1
fi
touch /var/log/nginx/access_log
nohup python3 "$B/scanner.py" >/var/log/nginx/scanner.out 2>&1 &
echo $! > "$B/scanner.pid"
sleep 2
if kill -0 "$(cat "$B/scanner.pid")" 2>/dev/null; then
  echo "  ✔ scanner backend running on https://smooth-yak.local/review (denies images containing 'vulnerable')"
else
  echo "  ⚠️  scanner backend failed to start — check /var/log/nginx/scanner.out (port 443 may be in use)"
fi

# ---------------------------------------------------------------------------
# 4. The INCOMPLETE config the candidate must finish
#    - defaultAllow: true  (must be changed to false)
#    - server: <empty>     (must be set to https://smooth-yak.local/review)
# ---------------------------------------------------------------------------
cat > "$B/admission_config.yaml" <<'CFG'
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
cat > "$B/kubeconfig.yaml" <<'KC'
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

[ -f "$APISERVER" ] && cp "$APISERVER" "${APISERVER}.bak.q15"

echo ""
echo "Done. Complete /etc/kubernetes/bouncer/{admission_config.yaml,kubeconfig.yaml} and enable the plugin."
echo "IMPORTANT: after editing those files, RESTART the API server (touch $APISERVER) —"
echo "           kubelet does not watch referenced config files, only the manifest itself."
