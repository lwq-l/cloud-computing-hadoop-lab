#!/usr/bin/env bash
# CNB 第5章预检查。只读，不修改或删除已有容器及HDFS数据。
set -euo pipefail
cd "$(dirname "$0")/../.."

echo "=== CH5: current environment ==="
printf 'Workspace: '; pwd
printf 'User: '; id -un
printf 'Kernel: '; uname -r
printf 'CPU count: '; nproc
printf 'Memory summary:\n'; free -h | head -n 2
echo
if [ -f /sys/fs/cgroup/cpu.max ]; then
  printf 'Current container cpu.max: '; cat /sys/fs/cgroup/cpu.max
fi
if [ -f /sys/fs/cgroup/memory.max ]; then
  printf 'Current container memory.max: '; cat /sys/fs/cgroup/memory.max
fi
echo
if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 not found. Please contact the teacher." >&2
  exit 2
fi
python3 --version
if ! command -v docker >/dev/null 2>&1; then
  echo "DOCKER_UNAVAILABLE: Docker CLI not found."
  echo "Ask the teacher to check .cnb.yml services: [vscode, docker]."
  exit 3
fi
if ! docker info >/dev/null 2>&1; then
  echo "DOCKER_UNAVAILABLE: Docker CLI exists but daemon is not reachable."
  echo "Do not run sudo/apt or install a Docker daemon inside this workspace."
  exit 4
fi
echo "=== Docker ==="
docker version --format 'Client={{.Client.Version}} Server={{.Server.Version}}'
docker info --format 'Cgroup driver={{.CgroupDriver}}; cgroup version={{.CgroupVersion}}'
echo "PASS: CH5 Docker daemon available."
