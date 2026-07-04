# CKS Exam Simulator 5

16 exam-style CKS questions transcribed from real exam screenshots — with the **original exam resource names, namespaces, file paths and weights** (clever-cactus, subtle-bee, ollama, lamp-deployment, stats-monitor, bouncer/smooth-yak …).

> ⚠️ **Requires a real Kubernetes cluster with root access** — use [killercoda.com/playgrounds/scenario/kubernetes](https://killercoda.com/playgrounds/scenario/kubernetes) or the CKS playground.

---

## Quick Start

```bash
git clone https://github.com/emran-hsaz/CKS-Exam-Simulator-5.git
cd CKS-Exam-Simulator-5
chmod +x cks check-all setup-all
```

Set aliases:

```bash
alias k=kubectl
echo 'set expandtab tabstop=2 shiftwidth=2' > ~/.vimrc
```

---

## Workflow

```bash
./cks list           # see all 16 questions and marks
./cks setup 1        # prepare cluster for Q1
./cks q 1            # read the question
                     # ... solve it ...
./cks check 1        # grade your answer
./cks reset 1        # clean up and start over
./setup-all          # set up ALL questions at once
./check-all          # grade ALL questions at once
```

---

## Questions

| #  | Topic                                                       | Domain                                 | Weight |
|----|-------------------------------------------------------------|----------------------------------------|--------|
| 1  | Harden the Kubelet and etcd (CIS Benchmark)                 | Cluster Setup                          | 6      |
| 2  | Create a TLS Secret for clever-cactus                       | Cluster Hardening                      | 7      |
| 3  | Fix Vulnerable Dockerfile & Manifest (subtle-bee)           | Supply Chain Security                  | 7      |
| 4  | Find & Contain the Pod Reading /dev/mem (ollama)            | Monitoring, Logging & Runtime Security | 7      |
| 5  | Enforce Container Immutability on lamp-deployment           | Minimize Microservice Vulnerabilities  | 7      |
| 6  | Implement and Extend an API Server Audit Policy             | Monitoring, Logging & Runtime Security | 7      |
| 7  | NetworkPolicies for Namespace Isolation (prod / data)       | Cluster Hardening                      | 7      |
| 8  | Cilium Ingress with TLS Termination + HTTP→HTTPS Redirect   | Cluster Hardening                      | 7      |
| 9  | Lock Down ServiceAccount Token Automounting (stats-monitor) | Minimize Microservice Vulnerabilities  | 7      |
| 10 | Upgrade a Worker Node by One Patch Version (apt + kubeadm)  | Cluster Setup                          | 6      |
| 11 | Vulnerable Package (libcrypto3 3.1.4-r5) + SPDX SBOM        | Supply Chain Security                  | 7      |
| 12 | Fix Deployment for Restricted Pod Security Standard         | Minimize Microservice Vulnerabilities  | 7      |
| 13 | Harden the Docker Daemon (developer, root group, no TCP)    | System Hardening                       | 7      |
| 14 | Configure Istio Mutual TLS (mTLS) Authentication            | Cluster Hardening                      | 7      |
| 15 | ImagePolicyWebhook Admission Control (bouncer)              | Supply Chain Security                  | 7      |
| 16 | Secure the API Server (anonymous, Node,RBAC, NodeRestriction)| Cluster Setup                         | 6      |
|    | **Total**                                                   |                                         | **109**|

---

## Key Differences from CKS-Exam-Simulator-4

Same 16 core topics — but Simulator 5 uses the real exam wording, resource names, paths and marks (weights 6–7 instead of 3–5):

| Q  | Simulator 4                                                   | This Simulator (5)                                                                 |
|----|---------------------------------------------------------------|------------------------------------------------------------------------------------|
| 1  | Generic "insecure node" wording                               | Framed as **CIS Benchmark FAIL findings**; explicitly requires etcd `--client-cert-auth=true` |
| 2  | ns `web-app`, secret `tls-secret`, certs in `/root/`          | ns/secret/deploy all named **clever-cactus**; certs `/home/candidate/clever-cactus/web.k8s.local.{crt,key}` |
| 3  | Dockerfile `/root/Dockerfile`; also edits a live Deployment (runAsUser 65535 etc.) | Files only: `/home/candidate/subtle-bee/build/Dockerfile` + `deployment.yaml`; fix exactly **one instruction and one field**, do **not** build |
| 4  | 3 deployments `nvidia`/`cpu`/`gpu` in `default`; Falco rule is graded | App **ollama** (ns `ollama`, deployments ollama-api/web/batch); Falco is a tool, **only containment is graded** |
| 5  | Deployment `mutable-app`, runAsUser **30000**, ns default     | Deployment **lamp-deployment**, ns **lamp**, runAsUser **20000**, manifest at `/home/candidate/finer-sunbeam/lamp-deployment.yaml` |
| 6  | Policy `/etc/kubernetes/audit-policy.yaml`, log `audit.log`, maxbackup only | Policy `/etc/kubernetes/logpolicy/audit-policy.yaml`, log `audit-logs.txt`, maxbackup **2** + maxage **10**, and you must **extend the policy** (namespaces RequestResponse, deployments in `webapps` at Request, ConfigMaps/Secrets Metadata, catch-all Metadata) |
| 7  | ns `secure-ns` / `allowed-ns`, pod label `access=granted`, unnamed policies | Named policies **deny-policy** (ns `prod`) and **allow-from-prod** (ns `data`), namespace label `env: prod` |
| 8  | Ingress `web-ingress`, host `web.example.com`, secret `app-tls`, no redirect | Ingress **web** in ns `prod`, host `web.k8s.local`, secret `web-cert`, **Cilium** IngressClass + **HTTP→HTTPS redirect** |
| 9  | SA `app-sa` / deploy `token-app` in `default`                 | SA **stats-monitor-sa** / deploy **stats-monitor** in ns **monitoring**; projected volume **must be named `token`** |
| 10 | Binary swap: staged `/usr/local/bin/kubelet-1.30.1`           | Package-manager upgrade: `apt-get` + **`kubeadm upgrade node`**, then kubelet & kubectl v1.30.1 |
| 11 | Deploy `multi-alpine` in `default`; **remove** the vulnerable container; SBOM to `/root/alpine.spdx` | Deploy **alpine** in ns **alpine**; deployment stays **untouched** — identify the image + SBOM to `/home/candidate/alpine.spdx` |
| 12 | Same scenario                                                 | Same (restricted-ns / pss-app) — weight raised to 7                                |
| 13 | User `testuser`; socket ownership only                        | User **developer**; socket group **root** *and* daemon must **not listen on any TCP port** (daemon.json ships `tcp://0.0.0.0:2375`) |
| 14 | Same scenario                                                 | Same names (target-mtls / allow-client / app-ns / client-ns); setup now auto-installs minimal Istio CRDs |
| 15 | Config `/etc/kubernetes/admission-config.yaml`; no backend/test step | Config dir **`/etc/kubernetes/bouncer`**; point kubeconfig backend to **`https://smooth-yak.local/review`**; test with `/home/candidate/vulnerable.yaml` |
| 16 | Flags only                                                    | Flags **plus** removing the ClusterRoleBinding **system:anonymous**; hints at `/etc/kubernetes/admin.conf` |
|    | Marks 3–5 per Q (total 61)                                    | Real exam weights **6–7** per Q (total **109**)                                    |

---

## Companion Repos

| Repo                                                                        | Questions | Notes                                                       |
|-----------------------------------------------------------------------------|-----------|-------------------------------------------------------------|
| [CKS-Exam-Simulator](https://github.com/emran-hsaz/CKS-Exam-Simulator)      | 16        | Core CKS topics                                             |
| [CKS-Exam-Simulator-2](https://github.com/emran-hsaz/CKS-Exam-Simulator-2)  | 9         | AppArmor, Seccomp, gVisor, etcd encryption, kube-bench, OPA |
| [CKS-Exam-Simulator-3](https://github.com/emran-hsaz/CKS-Exam-Simulator-3)  | 4         | Real exam twists                                            |
| [CKS-Exam-Simulator-4](https://github.com/emran-hsaz/CKS-Exam-Simulator-4)  | 16        | Different resource names and scenarios                      |
| **CKS-Exam-Simulator-5**                                                    | **16**    | **Real exam names, paths and weights (from exam screenshots)** |

---

## ⚠️ Important Notes

- **Q1, Q6, Q15, Q16** modify `/etc/kubernetes/manifests/kube-apiserver.yaml`, kubelet config or etcd — wait ~60 seconds after saving.
- **Q4** requires the Falco DaemonSet in namespace `falco` (rules dir `/etc/falco/rules.d/`). Scale ONLY the offending deployment.
- **Q10** requires SSH access to the worker node and the v1.30 apt repo.
- **Q11** requires the `bom` CLI (and optionally `trivy`) installed on the node.
- **Q14** works even without a full Istio install — setup applies minimal `security.istio.io` CRDs.
- **Q16** breaks unauthenticated kubectl — use `kubectl --kubeconfig /etc/kubernetes/admin.conf`.
- Always use `kubectl apply` — never `kubectl replace --force` for Deployments.

---

## CKS Exam Domains

| Domain                                | Weight |
|---------------------------------------|--------|
| Cluster Setup                         | 10%    |
| Cluster Hardening                     | 15%    |
| System Hardening                      | 15%    |
| Minimize Microservice Vulnerabilities | 20%    |
| Supply Chain Security                 | 20%    |
| Monitoring, Logging, Runtime Security | 20%    |
