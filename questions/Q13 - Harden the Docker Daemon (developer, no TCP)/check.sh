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
hdr "Q13 | Harden the Docker Daemon (7 pts)"
g=$(id developer 2>/dev/null)
chk "developer is NOT in the docker group" "$(echo "$g" | grep -qw docker && echo false || echo true)" && ((passed++))
chk "developer still in other group 'staff' (not over-removed)" "$([ -n "$g" ] && echo "$g" | grep -qw staff && echo true || echo false)" && ((passed++))
DJ=/etc/docker/daemon.json
grp=$(python3 -c "import json;print(json.load(open('$DJ')).get('group',''))" 2>/dev/null)
sockgrp=$(stat -c '%G' /var/run/docker.sock 2>/dev/null)
chk "Docker socket belongs to group root (daemon.json group=root or socket group root)" "$([ "$grp" = "root" ] || [ "$sockgrp" = "root" ] && echo true || echo false)" && ((passed++))
tcp=$(python3 -c "
import json
h=json.load(open('$DJ')).get('hosts',[])
print('true' if not any('tcp://' in x for x in h) else 'false')" 2>/dev/null)
unit_tcp=$(grep -rs 'tcp://' /etc/systemd/system/docker.service.d/ /lib/systemd/system/docker.service 2>/dev/null | wc -l)
chk "Docker daemon does not listen on any TCP port" "$([ "${tcp:-true}" = "true" ] && [ "$unit_tcp" = "0" ] && echo true || echo false)" && ((passed++))
score_line $passed $checks
