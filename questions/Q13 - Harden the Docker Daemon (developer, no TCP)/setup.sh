#!/bin/bash
echo "Setting up Q13 — insecure Docker daemon configuration..."
id developer &>/dev/null || useradd -m developer
groupadd docker 2>/dev/null || true
usermod -aG docker developer
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<'JSON'
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"],
  "group": "docker",
  "log-driver": "json-file"
}
JSON
touch /var/run/docker.sock 2>/dev/null || true
chown root:docker /var/run/docker.sock 2>/dev/null || true
systemctl restart docker 2>/dev/null || true
echo ""
echo "Done."
echo "  developer groups: $(groups developer 2>/dev/null)"
echo "  daemon.json listens on tcp://0.0.0.0:2375 and uses group docker — fix it."
