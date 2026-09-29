#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.hadoop_lab_env" 2>/dev/null || true
echo "Stopping HDFS..."
stop-dfs.sh || true
echo "Done."
