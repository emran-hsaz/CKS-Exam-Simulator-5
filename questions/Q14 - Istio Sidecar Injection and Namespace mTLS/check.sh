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
passed=0; checks=3
hdr "Q14 | Istio Sidecar Injection + Namespace mTLS (7 pts)"

lbl=$(kubectl get ns app-ns -o jsonpath='{.metadata.labels.istio-injection}' 2>/dev/null)
chk "Namespace app-ns labeled istio-injection=enabled" "$([ "$lbl" = "enabled" ] && echo true || echo false)" && ((passed++))

gen=$(kubectl get deployment target-app -n app-ns -o jsonpath='{.metadata.generation}' 2>/dev/null)
ann=$(kubectl get deployment target-app -n app-ns -o jsonpath='{.spec.template.metadata.annotations.kubectl\.kubernetes\.io/restartedAt}' 2>/dev/null)
rdy=$(kubectl get deployment target-app -n app-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
rolled=false
{ [ -n "$ann" ] || { [ -n "$gen" ] && [ "$gen" -gt 1 ]; }; } && [ "${rdy:-0}" -ge 1 ] && rolled=true
chk "target-app was rolled after the label was set (Pods recreated, Running)" "$rolled" && ((passed++))

pa=$(kubectl get peerauthentication default -n app-ns -o json 2>/dev/null)
mode=$(echo "$pa" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('spec',{}).get('mtls',{}).get('mode',''))" 2>/dev/null)
haveSelector=$(echo "$pa" | python3 -c "import sys,json;d=json.load(sys.stdin);print('yes' if d.get('spec',{}).get('selector') else 'no')" 2>/dev/null)
chk "PeerAuthentication 'default' in app-ns: no selector, mtls.mode STRICT (namespace-wide)" "$([ "$mode" = "STRICT" ] && [ "$haveSelector" = "no" ] && echo true || echo false)" && ((passed++))

score_line $passed $checks
