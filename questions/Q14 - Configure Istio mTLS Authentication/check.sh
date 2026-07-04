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
hdr "Q14 | Istio mTLS Authentication (7 pts)"
pa=$(kubectl get peerauthentication target-mtls -n app-ns -o json 2>/dev/null)
mode=$(echo "$pa" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['spec'].get('mtls',{}).get('mode',''))" 2>/dev/null)
sel=$(echo "$pa" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['spec'].get('selector',{}).get('matchLabels',{}).get('app',''))" 2>/dev/null)
chk "PeerAuthentication target-mtls: STRICT for app=target-app" "$([ "$mode" = "STRICT" ] && [ "$sel" = "target-app" ] && echo true || echo false)" && ((passed++))
port=$(echo "$pa" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['spec'].get('portLevelMtls',{}).get('8080',{}).get('mode',''))" 2>/dev/null)
chk "Port 8080 uses PERMISSIVE mode" "$([ "$port" = "PERMISSIVE" ] && echo true || echo false)" && ((passed++))
ap=$(kubectl get authorizationpolicy allow-client -n app-ns -o json 2>/dev/null)
apsel=$(echo "$ap" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['spec'].get('selector',{}).get('matchLabels',{}).get('app',''))" 2>/dev/null)
chk "AuthorizationPolicy allow-client targets app=target-app" "$([ "$apsel" = "target-app" ] && echo true || echo false)" && ((passed++))
src=$(echo "$ap" | python3 -c "
import sys,json
d=json.load(sys.stdin)
ok=False
for r in d['spec'].get('rules',[]) or []:
    for f in r.get('from',[]) or []:
        if 'client-ns' in (f.get('source',{}).get('namespaces',[]) or []): ok=True
print('true' if ok else 'false')" 2>/dev/null)
chk "Only namespace client-ns is authorized" "$([ "$src" = "true" ] && echo true || echo false)" && ((passed++))
score_line $passed $checks
