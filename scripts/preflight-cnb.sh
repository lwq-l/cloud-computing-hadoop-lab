#!/usr/bin/env bash
# CNB 候选环境启动检查；不启动或重置已有 HDFS 进程。
set -euo pipefail
cd "$(dirname "$0")/.."

command -v java >/dev/null || { echo "ERROR: Java missing" >&2; exit 1; }
command -v hdfs >/dev/null || { echo "ERROR: Hadoop CLI missing" >&2; exit 1; }
command -v python3 >/dev/null || { echo "ERROR: Python 3 missing" >&2; exit 1; }
command -v curl >/dev/null || { echo "ERROR: curl missing" >&2; exit 1; }

# Codespaces 会自动运行 postCreateCommand；CNB 不会读取该配置，
# 因此在 CNB 的启动流水线中显式完成初始化。
if [ ! -f "$HOME/.hadoop_lab_env" ]; then
  bash scripts/setup-hadoop.sh
fi
# shellcheck disable=SC1090
. "$HOME/.hadoop_lab_env"

echo "=== Java ==="
java -version
echo "=== Hadoop ==="
hadoop version | head -n 2
echo "=== Python ==="
python3 --version

for file in \
  scripts/start-hdfs.sh \
  scripts/multinode/setup-multinode.sh \
  scripts/multinode/start-multinode.sh \
  scripts/multinode/stop-one-datanode.sh \
  scripts/loadbalance/start-lb.sh \
  scripts/loadbalance/test-lb.sh \
  scripts/loadbalance/stop-lb.sh \
  data/hello.txt; do
  [ -f "$file" ] || { echo "ERROR: missing $file" >&2; exit 1; }
done

echo "PASS: basic tooling and chapter 3/4 scripts found."
echo "NOTE: HDFS and load-balancer runtime behavior still requires live tests."
