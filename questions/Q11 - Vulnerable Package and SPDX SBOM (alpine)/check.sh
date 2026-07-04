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
hdr "Q11 | Vulnerable Package + SPDX SBOM (7 pts)"
F=/home/candidate/alpine.spdx
chk "SPDX document exists at /home/candidate/alpine.spdx" "$([ -s "$F" ] && echo true || echo false)" && ((passed++))
chk "Document is valid SPDX (SPDXVersion header)" "$(grep -q 'SPDXVersion' "$F" 2>/dev/null && echo true || echo false)" && ((passed++))
chk "SBOM was generated for alpine:3.19.1 (ships libcrypto3 3.1.4-r5)" "$(grep -qi '3.19.1' "$F" 2>/dev/null && echo true || echo false)" && ((passed++))
n=$(kubectl get deploy alpine -n alpine -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | wc -w)
chk "alpine Deployment untouched (3 containers)" "$([ "$n" = "3" ] && echo true || echo false)" && ((passed++))
score_line $passed $checks
