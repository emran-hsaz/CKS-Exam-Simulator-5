# Cilium Ingress with TLS Termination and HTTP-to-HTTPS Redirect

**Domain:** Cluster Hardening · **Weight:** 7

## Context
You must expose a web application using HTTPS routes. A default Cilium IngressClass is configured in the cluster.

## Requirements

Create an Ingress resource named `web` in the `prod` namespace and configure it as follows:

1. Route traffic for host `web.k8s.local` and **all paths** to the existing Service `web`.
2. Enable TLS termination using the existing Secret `web-cert`.
3. Redirect HTTP requests to HTTPS.

You can test your Ingress configuration with:
```bash
curl -L http://web.k8s.local
```
