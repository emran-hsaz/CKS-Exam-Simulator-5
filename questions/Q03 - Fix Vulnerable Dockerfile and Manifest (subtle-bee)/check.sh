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
hdr "Q3 | Fix Vulnerable Dockerfile and Manifest (7 pts)"
DF=/home/candidate/subtle-bee/build/Dockerfile
DY=/home/candidate/subtle-bee/deployment.yaml
chk "Dockerfile no longer runs as root (USER root removed)" "$(grep -qE '^USER[[:space:]]+root[[:space:]]*$' "$DF" 2>/dev/null && echo false || echo true)" && ((passed++))
chk "Dockerfile uses unprivileged user (nobody or 65535)" "$(grep -qE '^USER[[:space:]]+(nobody|65535)' "$DF" 2>/dev/null && echo true || echo false)" && ((passed++))
chk "Deployment manifest: privileged is no longer true" "$(grep -qE 'privileged:[[:space:]]*true' "$DY" 2>/dev/null && echo false || echo true)" && ((passed++))
chk "Deployment manifest: privileged: false is set" "$(grep -qE 'privileged:[[:space:]]*false' "$DY" 2>/dev/null && echo true || echo false)" && ((passed++))
score_line $passed $checks
