#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.hadoop_lab_env" 2>/dev/null || true
export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-$HADOOP_HOME/etc/hadoop}"
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"

echo "WARNING: this will delete all HDFS lab data."
read -r -p "Type RESET to continue: " answer
if [ "$answer" != "RESET" ]; then
  echo "Cancelled."
  exit 0
fi

bash scripts/stop-hdfs.sh >/dev/null 2>&1 || true
rm -rf "$HOME/hdfs-data/namenode" "$HOME/hdfs-data/datanode"
mkdir -p "$HOME/hdfs-data/namenode" "$HOME/hdfs-data/datanode"
hdfs namenode -format -force -nonInteractive >/tmp/hdfs-format.log 2>&1
echo "HDFS reset complete."
echo "Run: bash scripts/start-hdfs.sh"
