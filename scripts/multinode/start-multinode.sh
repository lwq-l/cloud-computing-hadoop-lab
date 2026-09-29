#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.hadoop_lab_env" 2>/dev/null || true
export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"
BASE="$HOME/hadoop-multi"

if [ ! -f "$BASE/activate.sh" ]; then
  echo "Multi-node environment is not initialized."
  echo "Run: bash scripts/multinode/setup-multinode.sh"
  exit 1
fi

# Stage 1 and Stage 2 both use NameNode ports 9000/9870.
# Stop Stage 1 cleanly before switching to the multi-node experiment.
if jps | grep -Eq 'NameNode|DataNode|SecondaryNameNode'; then
  echo "Stopping any running Stage-1 HDFS daemons before multi-node startup..."
  bash scripts/stop-hdfs.sh >/dev/null 2>&1 || true
fi

start_nn() {
  if jps -lv | grep -q 'multi-nn.*NameNode'; then
    echo "NameNode already running."
  else
    echo "Starting NameNode..."
    HADOOP_CONF_DIR="$BASE/conf/namenode"     HADOOP_IDENT_STRING="multi-nn"     HADOOP_LOG_DIR="$BASE/logs/nn"     hdfs --daemon start namenode
  fi
}

start_dn() {
  local id="$1"
  local conf="$BASE/conf/dn$id"
  local logs="$BASE/logs/dn$id"
  local ident="multi-dn$id"

  if jps -lv | grep -q "$ident.*DataNode"; then
    echo "DataNode-$id already running."
  else
    echo "Starting DataNode-$id..."
    HADOOP_CONF_DIR="$conf"     HADOOP_IDENT_STRING="$ident"     HADOOP_LOG_DIR="$logs"     hdfs --daemon start datanode
  fi
}

start_nn
sleep 2
start_dn 1
start_dn 2
start_dn 3
sleep 5

echo
echo "=== Java processes ==="
jps -lv

echo
echo "=== HDFS live DataNodes ==="
HADOOP_CONF_DIR="$BASE/conf/client" hdfs dfsadmin -report | sed -n '1,80p'

echo
echo "Expected result: Live datanodes (3)"
echo "NameNode Web UI: port 9870"
