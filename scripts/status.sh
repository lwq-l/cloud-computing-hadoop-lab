#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.hadoop_lab_env" 2>/dev/null || true
echo "=== Java processes ==="
jps || true
echo
echo "=== HDFS report ==="
hdfs dfsadmin -report || true
