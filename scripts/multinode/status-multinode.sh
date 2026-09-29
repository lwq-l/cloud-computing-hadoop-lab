#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.hadoop_lab_env" 2>/dev/null || true
export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"
BASE="$HOME/hadoop-multi"

echo "=== Java processes ==="
jps -lv

echo
echo "=== HDFS report ==="
HADOOP_CONF_DIR="$BASE/conf/client" hdfs dfsadmin -report
