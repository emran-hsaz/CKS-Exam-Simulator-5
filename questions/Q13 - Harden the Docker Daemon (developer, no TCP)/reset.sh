#!/bin/bash
userdel -r developer 2>/dev/null
rm -f /etc/docker/daemon.json
echo "Q13 reset done."
