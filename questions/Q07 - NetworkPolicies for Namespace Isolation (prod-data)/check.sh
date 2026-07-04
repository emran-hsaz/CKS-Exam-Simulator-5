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
passed=0; checks=4
hdr "Q7 | NetworkPolicies for Namespace Isolation (7 pts)"
chk "NetworkPolicy deny-policy exists in prod" "$(kubectl get netpol deny-policy -n prod >/dev/null 2>&1 && echo true || echo false)" && ((passed++))
ing=$(kubectl get netpol deny-policy -n prod -o jsonpath='{.spec.ingress}' 2>/dev/null)
pt=$(kubectl get netpol deny-policy -n prod -o jsonpath='{.spec.policyTypes}' 2>/dev/null)
chk "deny-policy blocks all ingress (empty podSelector, no ingress rules)" "$([ -z "$ing" ] && echo "$pt" | grep -q Ingress && echo true || echo false)" && ((passed++))
chk "NetworkPolicy allow-from-prod exists in data" "$(kubectl get netpol allow-from-prod -n data >/dev/null 2>&1 && echo true || echo false)" && ((passed++))
sel=$(kubectl get netpol allow-from-prod -n data -o jsonpath='{.spec.ingress[0].from[0].namespaceSelector.matchLabels.env}' 2>/dev/null)
chk "allow-from-prod allows only namespaces labeled env=prod" "$([ "$sel" = "prod" ] && echo true || echo false)" && ((passed++))
score_line $passed $checks
