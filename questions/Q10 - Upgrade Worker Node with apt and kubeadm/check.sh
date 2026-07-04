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
hdr "Q10 | Upgrade Worker Node (6 pts)"
WORKER=$(kubectl get nodes --no-headers 2>/dev/null | grep -v 'control-plane\|master' | awk '{print $1}' | head -1)
if [ -z "$WORKER" ]; then
  echo "  Could not determine worker node name."
  score_line 0 $checks; exit 0
fi
st=$(kubectl get node "$WORKER" --no-headers 2>/dev/null | awk '{print $2}')
chk "Worker node $WORKER is Ready" "$([ "$st" = "Ready" ] && echo true || echo false)" && ((passed++))
chk "Worker node $WORKER is not cordoned" "$(echo "$st" | grep -qw 'SchedulingDisabled' && echo false || echo true)" && ((passed++))
wv=$(kubectl get node "$WORKER" --no-headers 2>/dev/null | awk '{print $5}')
chk "Worker kubelet version is v1.30.1" "$([ "$wv" = "v1.30.1" ] && echo true || echo false)" && ((passed++))
nr=$(kubectl get nodes --no-headers 2>/dev/null | awk '{print $2}' | grep -v '^Ready$' | wc -l)
chk "All cluster nodes are Ready" "$([ "$nr" = "0" ] && echo true || echo false)" && ((passed++))
score_line $passed $checks
