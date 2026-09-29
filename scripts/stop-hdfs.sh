#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.hadoop_lab_env" 2>/dev/null || true
export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-$HADOOP_HOME/etc/hadoop}"
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"

hdfs --daemon stop secondarynamenode || true
hdfs --daemon stop datanode || true
hdfs --daemon stop namenode || true
echo "HDFS stopped."
