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
passed=0; checks=5
hdr "Q16 | Secure the API Server (6 pts)"
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
K="kubectl --kubeconfig /etc/kubernetes/admin.conf"
chk "--anonymous-auth=false" "$(grep -q 'anonymous-auth=false' "$APISERVER" 2>/dev/null && echo true || echo false)" && ((passed++))
chk "--authorization-mode=Node,RBAC" "$(grep -q 'authorization-mode=Node,RBAC' "$APISERVER" 2>/dev/null && echo true || echo false)" && ((passed++))
plugins=$(grep -oP 'enable-admission-plugins=\K\S+' "$APISERVER" 2>/dev/null | head -1)
chk "NodeRestriction admission controller enabled" "$(echo "$plugins" | grep -q NodeRestriction && echo true || echo false)" && ((passed++))
chk "ClusterRoleBinding system:anonymous removed" "$($K get clusterrolebinding system:anonymous >/dev/null 2>&1 && echo false || echo true)" && ((passed++))
chk "Cluster is functional via admin.conf" "$($K get nodes >/dev/null 2>&1 && echo true || echo false)" && ((passed++))
score_line $passed $checks
