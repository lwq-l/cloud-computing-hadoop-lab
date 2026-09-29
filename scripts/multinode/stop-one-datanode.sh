#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ] || ! [[ "$1" =~ ^[123]$ ]]; then
  echo "Usage: bash scripts/multinode/stop-one-datanode.sh 1|2|3"
  exit 1
fi

source "$HOME/.hadoop_lab_env" 2>/dev/null || true
export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"
BASE="$HOME/hadoop-multi"
ID="$1"

HADOOP_CONF_DIR="$BASE/conf/dn$ID" HADOOP_IDENT_STRING="multi-dn$ID" HADOOP_LOG_DIR="$BASE/logs/dn$ID" hdfs --daemon stop datanode

sleep 3
echo "DataNode-$ID stopped."
echo
HADOOP_CONF_DIR="$BASE/conf/client" hdfs dfsadmin -report | sed -n '1,70p'
