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
hdr "Q15 | ImagePolicyWebhook Admission Control (7 pts)"
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
CFG="/etc/kubernetes/bouncer/admission_config.yaml"
KC="/etc/kubernetes/bouncer/kubeconfig.yaml"
plugins=$(grep -oP 'enable-admission-plugins=\K\S+' "$APISERVER" 2>/dev/null | head -1)
chk "ImagePolicyWebhook enabled in --enable-admission-plugins" "$(echo "$plugins" | grep -q ImagePolicyWebhook && echo true || echo false)" && ((passed++))
chk "--admission-control-config-file points to the bouncer config" "$(grep -q 'admission-control-config-file=/etc/kubernetes/bouncer/admission_config.yaml' "$APISERVER" 2>/dev/null && echo true || echo false)" && ((passed++))
da=$(python3 -c "
import yaml
c=yaml.safe_load(open('$CFG'))
p=[x for x in c.get('plugins',[]) if x.get('name')=='ImagePolicyWebhook'][0]
print(p['configuration']['imagePolicy'].get('defaultAllow'))" 2>/dev/null)
chk "defaultAllow: false (deny on backend failure)" "$([ "$da" = "False" ] && echo true || echo false)" && ((passed++))
chk "Backend server = https://smooth-yak.local/review" "$(grep -q 'server: https://smooth-yak.local/review' "$KC" 2>/dev/null && echo true || echo false)" && ((passed++))
api=$(kubectl get pod -n kube-system 2>/dev/null | grep apiserver | grep -c Running)
chk "API server is running" "$([ "${api:-0}" -ge 1 ] && echo true || echo false)" && ((passed++))
score_line $passed $checks
