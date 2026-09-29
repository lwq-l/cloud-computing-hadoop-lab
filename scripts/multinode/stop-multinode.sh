#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.hadoop_lab_env" 2>/dev/null || true
export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"
BASE="$HOME/hadoop-multi"

stop_dn() {
  local id="$1"
  HADOOP_CONF_DIR="$BASE/conf/dn$id"   HADOOP_IDENT_STRING="multi-dn$id"   HADOOP_LOG_DIR="$BASE/logs/dn$id"   hdfs --daemon stop datanode >/dev/null 2>&1 || true
}

stop_dn 3
stop_dn 2
stop_dn 1

HADOOP_CONF_DIR="$BASE/conf/namenode" HADOOP_IDENT_STRING="multi-nn" HADOOP_LOG_DIR="$BASE/logs/nn" hdfs --daemon stop namenode >/dev/null 2>&1 || true

echo "Multi-node HDFS stopped."
