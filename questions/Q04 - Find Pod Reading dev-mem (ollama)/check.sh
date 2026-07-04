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
hdr "Q4 | Contain the Pod Reading /dev/mem (7 pts)"
rep=$(kubectl get deploy ollama-batch -n ollama -o jsonpath='{.spec.replicas}' 2>/dev/null)
chk "Offending Deployment scaled to 0 replicas" "$([ "$rep" = "0" ] && echo true || echo false)" && ((passed++))
a=$(kubectl get deploy ollama-api -n ollama -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
w=$(kubectl get deploy ollama-web -n ollama -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
chk "Other ollama Deployments still running" "$([ "${a:-0}" -ge 1 ] && [ "${w:-0}" -ge 1 ] && echo true || echo false)" && ((passed++))
n=$(kubectl get deploy -n ollama --no-headers 2>/dev/null | wc -l)
chk "No Deployments were deleted (3 still exist)" "$([ "$n" = "3" ] && echo true || echo false)" && ((passed++))
score_line $passed $checks
