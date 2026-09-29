#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.hadoop_lab_env" 2>/dev/null || true

echo "WARNING: this will delete all HDFS lab data."
read -r -p "Type RESET to continue: " answer
if [ "$answer" != "RESET" ]; then
  echo "Cancelled."
  exit 0
fi

stop-dfs.sh >/dev/null 2>&1 || true
rm -rf "$HOME/hdfs-data/namenode" "$HOME/hdfs-data/datanode"
mkdir -p "$HOME/hdfs-data/namenode" "$HOME/hdfs-data/datanode"
hdfs namenode -format -force -nonInteractive
echo "HDFS has been reset."
echo "Run ./scripts/start-hdfs.sh to start again."
