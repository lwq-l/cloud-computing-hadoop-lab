#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.hadoop_lab_env" 2>/dev/null || true
sudo /usr/sbin/sshd || true
echo "Starting HDFS..."
start-dfs.sh
sleep 2
echo
echo "Java processes:"
jps
echo
echo "NameNode Web UI: port 9870 (open it from the Codespaces PORTS panel)"
