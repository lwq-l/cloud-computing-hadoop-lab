#!/usr/bin/env bash
BASE="$HOME/hadoop-multi"
if [ ! -f "$BASE/activate.sh" ]; then
  echo "Please run first: bash scripts/multinode/setup-multinode.sh"
  return 1 2>/dev/null || exit 1
fi
source "$BASE/activate.sh"
echo "Multi-node HDFS client environment activated."
echo "HADOOP_CONF_DIR=$HADOOP_CONF_DIR"
