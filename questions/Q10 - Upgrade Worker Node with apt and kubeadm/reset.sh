#!/bin/bash
WORKER=$(kubectl get nodes --no-headers 2>/dev/null | grep -v 'control-plane\|master' | awk '{print $1}' | head -1)
[ -n "$WORKER" ] && kubectl uncordon "$WORKER" 2>/dev/null
echo "Q10 reset done (node uncordoned if needed; downgrade manually if you want to retry)."
