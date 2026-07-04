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
passed=0; checks=8
hdr "Q6 | Implement and Extend Audit Policy (7 pts)"
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
POL="/etc/kubernetes/logpolicy/audit-policy.yaml"
chk "--audit-policy-file=/etc/kubernetes/logpolicy/audit-policy.yaml" "$(grep -q 'audit-policy-file=/etc/kubernetes/logpolicy/audit-policy.yaml' "$APISERVER" 2>/dev/null && echo true || echo false)" && ((passed++))
chk "--audit-log-path=/var/log/kubernetes/audit-logs.txt" "$(grep -q 'audit-log-path=/var/log/kubernetes/audit-logs.txt' "$APISERVER" 2>/dev/null && echo true || echo false)" && ((passed++))
mb=$(grep -oP 'audit-log-maxbackup=\K[0-9]+' "$APISERVER" 2>/dev/null | head -1)
chk "--audit-log-maxbackup=2" "$([ "$mb" = "2" ] && echo true || echo false)" && ((passed++))
ma=$(grep -oP 'audit-log-maxage=\K[0-9]+' "$APISERVER" 2>/dev/null | head -1)
chk "--audit-log-maxage=10" "$([ "$ma" = "10" ] && echo true || echo false)" && ((passed++))
py() { python3 - "$POL" <<'PY'
import sys, yaml, json
rules = (yaml.safe_load(open(sys.argv[1])) or {}).get('rules', [])
print(json.dumps(rules))
PY
}
rules=$(py 2>/dev/null)
has_rule() { echo "$rules" | python3 -c "
import sys, json
rules = json.load(sys.stdin)
level, res, ns = sys.argv[1], sys.argv[2], sys.argv[3] if len(sys.argv)>3 else ''
ok = False
for r in rules:
    if r.get('level') != level: continue
    resources = [x for grp in r.get('resources',[]) for x in grp.get('resources',[])]
    if res and res not in resources: continue
    if ns and ns not in r.get('namespaces',[]): continue
    ok = True
print('true' if ok else 'false')
" "$@" 2>/dev/null; }
chk "Policy: namespaces at RequestResponse" "$(has_rule RequestResponse namespaces)" && ((passed++))
chk "Policy: deployments in webapps at Request level" "$(has_rule Request deployments webapps)" && ((passed++))
cm=$(has_rule Metadata configmaps); se=$(has_rule Metadata secrets)
chk "Policy: ConfigMaps and Secrets at Metadata (all namespaces)" "$([ "$cm" = "true" ] && [ "$se" = "true" ] && echo true || echo false)" && ((passed++))
catchall=$(echo "$rules" | python3 -c "
import sys, json
rules = json.load(sys.stdin)
print('true' if rules and rules[-1].get('level')=='Metadata' and not rules[-1].get('resources') else 'false')" 2>/dev/null)
lf=false; [ -f /var/log/kubernetes/audit-logs.txt ] && lf=true
chk "Catch-all Metadata rule + audit log file exists" "$([ "$catchall" = "true" ] && [ "$lf" = "true" ] && echo true || echo false)" && ((passed++))
score_line $passed $checks
