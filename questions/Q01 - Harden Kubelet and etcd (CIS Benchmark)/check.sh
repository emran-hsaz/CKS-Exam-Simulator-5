#!/bin/bash
MARKS=6
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
pass() { echo -e "  ${GREEN}✔ CORRECT${NC}  $1"; }
fail() { echo -e "  ${RED}✘ WRONG${NC}    $1"; }
hdr()  { echo ""; echo -e "${CYAN}════════════════════════════════════════════════${NC}"; echo -e "${BOLD}$1${NC}"; echo -e "${CYAN}════════════════════════════════════════════════${NC}"; }
chk() { if [ "$2" = "true" ]; then pass "$1"; return 0; else fail "$1"; return 1; fi; }
score_line() {
  local passed=$1 checks=$2 score=0 p=0
  [ "$checks" -gt 0 ] && score=$(( passed * MARKS / checks ))
  [ "$passed" -eq "$checks" ] && score=$MARKS
  [ "$MARKS" -gt 0 ] && p=$(( score * 100 / MARKS ))
  if [ "$score" -eq "$MARKS" ]; then echo -e "\n  ${GREEN}${BOLD}Score: $score/$MARKS ($p%) — Perfect!${NC}\n"
  elif [ "$score" -gt 0 ]; then  echo -e "\n  ${YELLOW}${BOLD}Score: $score/$MARKS ($p%) — Keep going!${NC}\n"
  else                           echo -e "\n  ${RED}${BOLD}Score: $score/$MARKS ($p%) — Try again!${NC}\n"; fi
}
passed=0; checks=4
hdr "Q1 | Harden the Kubelet and etcd (6 pts)"
KUBELET_CONFIG="/var/lib/kubelet/config.yaml"
ETCD="/etc/kubernetes/manifests/etcd.yaml"
anon=$(python3 -c "import yaml; c=yaml.safe_load(open('$KUBELET_CONFIG')); print(c.get('authentication',{}).get('anonymous',{}).get('enabled','not-set'))" 2>/dev/null)
chk "Kubelet authentication.anonymous.enabled = false" "$([ "$anon" = "False" ] || [ "$anon" = "false" ] && echo true || echo false)" && ((passed++))
mode=$(python3 -c "import yaml; c=yaml.safe_load(open('$KUBELET_CONFIG')); print(c.get('authorization',{}).get('mode','not-set'))" 2>/dev/null)
chk "Kubelet authorization.mode = Webhook (not AlwaysAllow)" "$([ "$mode" = "Webhook" ] && echo true || echo false)" && ((passed++))
chk "Kubelet service is active" "$(systemctl is-active kubelet 2>/dev/null | grep -q active && echo true || echo false)" && ((passed++))
f=$(grep -c 'client-cert-auth=false' "$ETCD" 2>/dev/null || echo 0)
t=$(grep -c 'client-cert-auth=true' "$ETCD" 2>/dev/null || echo 0)
chk "etcd --client-cert-auth=true (and not false)" "$([ "$f" = "0" ] && [ "$t" -ge 1 ] && echo true || echo false)" && ((passed++))
score_line $passed $checks
