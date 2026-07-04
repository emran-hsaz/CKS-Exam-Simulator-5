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
hdr "Q9 | Lock Down SA Token Automounting (7 pts)"
am=$(kubectl get sa stats-monitor-sa -n monitoring -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null)
chk "ServiceAccount automountServiceAccountToken: false" "$([ "$am" = "false" ] && echo true || echo false)" && ((passed++))
vol=$(kubectl get deploy stats-monitor -n monitoring -o json 2>/dev/null | python3 -c "
import sys, json
d=json.load(sys.stdin)
vols=d['spec']['template']['spec'].get('volumes',[]) or []
v=[x for x in vols if x.get('name')=='token' and 'projected' in x]
print('true' if v else 'false')" 2>/dev/null)
chk "Projected volume named 'token' exists" "$([ "$vol" = "true" ] && echo true || echo false)" && ((passed++))
sat=$(kubectl get deploy stats-monitor -n monitoring -o json 2>/dev/null | python3 -c "
import sys, json
d=json.load(sys.stdin)
vols=d['spec']['template']['spec'].get('volumes',[]) or []
ok=False
for v in vols:
    if v.get('name')!='token': continue
    for s in (v.get('projected',{}) or {}).get('sources',[]) or []:
        if 'serviceAccountToken' in s: ok=True
print('true' if ok else 'false')" 2>/dev/null)
chk "Projected volume uses a serviceAccountToken source" "$([ "$sat" = "true" ] && echo true || echo false)" && ((passed++))
mnt=$(kubectl get deploy stats-monitor -n monitoring -o json 2>/dev/null | python3 -c "
import sys, json
d=json.load(sys.stdin)
cs=d['spec']['template']['spec'].get('containers',[]) or []
ok=False
for c in cs:
    for m in c.get('volumeMounts',[]) or []:
        if m.get('name')=='token' and m.get('readOnly') is True and m.get('mountPath','').startswith('/var/run/secrets/kubernetes.io/serviceaccount'):
            ok=True
print('true' if ok else 'false')" 2>/dev/null)
chk "Mounted read-only at /var/run/secrets/kubernetes.io/serviceaccount" "$([ "$mnt" = "true" ] && echo true || echo false)" && ((passed++))
avail=$(kubectl get deploy stats-monitor -n monitoring -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
chk "Deployment stats-monitor Pods are running" "$([ -n "$avail" ] && [ "$avail" -gt 0 ] 2>/dev/null && echo true || echo false)" && ((passed++))
score_line $passed $checks
