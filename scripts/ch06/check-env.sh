#!/usr/bin/env bash
# 第六章环境检查：只读，不修改 HDFS、第五章容器或宿主网络。
set -euo pipefail
cd "$(dirname "$0")/../.."
echo "=== Chapter 6: Network and Storage Virtualization ==="
printf 'Project: '; pwd
printf 'User: '; id -un
printf 'Kernel: '; uname -r
printf 'Python: '; python3 --version
printf 'CPU count: '; nproc
echo "=== Docker ==="
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker CLI not found. Switch to CNB terminal." >&2
  exit 2
fi
if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker daemon unreachable. Ask the teacher; do not install or start a privileged daemon." >&2
  exit 3
fi
docker version --format 'Client={{.Client.Version}} Server={{.Server.Version}}'
docker info --format 'CgroupDriver={{.CgroupDriver}} CgroupVersion={{.CgroupVersion}}'
docker network ls
for p in scripts/ch06/network-demo.sh scripts/ch06/network-fallback.py scripts/ch06/network-sim.py scripts/ch06/storage-demo.py scripts/ch06/cloud-storage-demo.py scripts/ch06/cleanup.sh; do
  test -f "$p" || { echo "ERROR: missing $p" >&2; exit 4; }
done
echo "PASS: CH6 prerequisites found."
echo "NOTE: custom bridge creation must be tested separately; Docker connectivity alone does not guarantee it."
