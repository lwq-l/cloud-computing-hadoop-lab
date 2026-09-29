#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.hadoop_lab_env" 2>/dev/null || true
export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-$HADOOP_HOME/etc/hadoop}"
export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"

start_daemon() {
  local role="$1"
  local match="$2"
  if jps | grep -q "$match"; then
    echo "$role already running."
    return 0
  fi
  echo "Starting $role..."
  case "$role" in
    NameNode) hdfs --daemon start namenode ;;
    DataNode) hdfs --daemon start datanode ;;
    SecondaryNameNode) hdfs --daemon start secondarynamenode ;;
  esac
}

start_daemon NameNode '^.*NameNode$'
sleep 1
start_daemon DataNode '^.*DataNode$'
sleep 1
start_daemon SecondaryNameNode '^.*SecondaryNameNode$'
sleep 2

echo
echo "=== Java processes ==="
jps
echo
echo "=== HDFS report ==="
hdfs dfsadmin -report | sed -n '1,35p' || true
echo
echo "NameNode Web UI: port 9870"
