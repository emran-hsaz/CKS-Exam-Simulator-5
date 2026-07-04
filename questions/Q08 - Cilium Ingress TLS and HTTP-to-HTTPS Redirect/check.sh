#!/bin/bash
MARKS=7
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
hdr "Q8 | Cilium Ingress with TLS + HTTPS Redirect (7 pts)"
chk "Ingress web exists in prod" "$(kubectl get ingress web -n prod >/dev/null 2>&1 && echo true || echo false)" && ((passed++))
host=$(kubectl get ingress web -n prod -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
svc=$(kubectl get ingress web -n prod -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
chk "Routes host web.k8s.local to Service web" "$([ "$host" = "web.k8s.local" ] && [ "$svc" = "web" ] && echo true || echo false)" && ((passed++))
tsec=$(kubectl get ingress web -n prod -o jsonpath='{.spec.tls[0].secretName}' 2>/dev/null)
thost=$(kubectl get ingress web -n prod -o jsonpath='{.spec.tls[0].hosts[0]}' 2>/dev/null)
chk "TLS termination with Secret web-cert for web.k8s.local" "$([ "$tsec" = "web-cert" ] && [ "$thost" = "web.k8s.local" ] && echo true || echo false)" && ((passed++))
cls=$(kubectl get ingress web -n prod -o jsonpath='{.spec.ingressClassName}' 2>/dev/null)
chk "ingressClassName: cilium" "$([ "$cls" = "cilium" ] && echo true || echo false)" && ((passed++))
ann=$(kubectl get ingress web -n prod -o jsonpath='{.metadata.annotations}' 2>/dev/null)
chk "HTTP→HTTPS redirect enabled (ingress.cilium.io/force-https)" "$(echo "$ann" | grep -q 'force-https.*enabled' && echo true || echo false)" && ((passed++))
score_line $passed $checks
