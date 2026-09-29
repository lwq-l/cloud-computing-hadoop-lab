#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.hadoop_lab_env" 2>/dev/null || true
export HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"
BASE="$HOME/hadoop-multi"

echo "WARNING: this deletes all Experiment-2 HDFS data."
read -r -p "Type RESET2 to continue: " answer
if [ "$answer" != "RESET2" ]; then
  echo "Cancelled."
  exit 0
fi

bash scripts/multinode/stop-multinode.sh >/dev/null 2>&1 || true
rm -rf "$BASE"
bash scripts/multinode/setup-multinode.sh
echo "Experiment-2 multi-node environment reset."
