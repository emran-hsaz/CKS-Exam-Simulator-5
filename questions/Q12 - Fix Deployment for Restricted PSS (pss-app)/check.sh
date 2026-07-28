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
hdr "Q12 | Fix Deployment for Restricted PSS (7 pts)"
j() { kubectl get deploy pss-app -n restricted-ns -o jsonpath="{$1}" 2>/dev/null; }
sc='.spec.template.spec.containers[0].securityContext'
chk "runAsNonRoot: true (pod or container level)" "$([ "$(j $sc.runAsNonRoot)" = "true" ] || [ "$(j .spec.template.spec.securityContext.runAsNonRoot)" = "true" ] && echo true || echo false)" && ((passed++))
chk "allowPrivilegeEscalation: false" "$([ "$(j $sc.allowPrivilegeEscalation)" = "false" ] && echo true || echo false)" && ((passed++))
sp=$(j $sc.seccompProfile.type); psp=$(j .spec.template.spec.securityContext.seccompProfile.type)
drop=$(kubectl get deploy pss-app -n restricted-ns -o jsonpath="{.spec.template.spec.containers[0].securityContext.capabilities.drop[*]}" 2>/dev/null)
chk "seccompProfile RuntimeDefault + capabilities drop ALL" "$({ [ "$sp" = "RuntimeDefault" ] || [ "$psp" = "RuntimeDefault" ]; } && echo "$drop" | grep -qw ALL && echo true || echo false)" && ((passed++))
avail=$(j .status.availableReplicas)
chk "pss-app Pods run in the restricted namespace" "$([ -n "$avail" ] && [ "$avail" -gt 0 ] 2>/dev/null && echo true || echo false)" && ((passed++))
score_line $passed $checks
