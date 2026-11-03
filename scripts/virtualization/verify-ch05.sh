#!/usr/bin/env bash
# 第5章教师端一键功能验证。只使用带随机后缀的测试资源。
# 验证配置读取，不声称 CPU/内存配额已被内核强制执行。
set -euo pipefail
cd "$(dirname "$0")/../.."

if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
  echo "FAIL: Docker client or daemon unavailable" >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "FAIL: Python3 missing" >&2
  exit 1
fi

run_id="ch5check-$(date +%s)-$$"
image_name="$run_id:1.0"
demo="$run_id-demo"
limited="$run_id-limited"
vol="$run_id-vol"

cleanup() {
  docker rm -f "$demo" "$limited" >/dev/null 2>&1 || true
  docker volume rm "$vol" >/dev/null 2>&1 || true
  docker image rm "$image_name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "[1/7] Environment and conceptual model"
bash scripts/virtualization/check-env.sh
python3 scripts/virtualization/simulate.py | grep -F "PASS: CH5 conceptual simulation complete."
echo "PASS: prerequisites"

echo "[2/7] Alpine image retrieval"
docker pull alpine:3.22 >/dev/null
echo "PASS: alpine:3.22 available"

echo "[3/7] Dockerfile build and run"
docker build -q -f labs/ch05/Dockerfile -t "$image_name" . >/dev/null
output="$(docker run --rm "$image_name")"
case "$output" in
  *CH5_IMAGE_OK* ) echo "PASS: teaching image runs" ;;
  * ) echo "FAIL: teaching image output" >&2; exit 1 ;;
esac

echo "[4/7] Container lifecycle"
docker run -d --name "$demo" alpine:3.22 sh -c 'while :; do sleep 10; done' >/dev/null
docker ps --format '{{.Names}}' | grep -Fx "$demo" >/dev/null
docker exec "$demo" uname -r >/dev/null
docker exec "$demo" sh -c 'grep -q "^ID=alpine" /etc/os-release'
echo "PASS: container starts and accepts exec"

echo "[5/7] Resource configuration observation"
docker run -d --name "$limited" --cpus=0.50 --memory=128m --pids-limit=64 alpine:3.22 sh -c 'while :; do sleep 10; done' >/dev/null
config="$(docker inspect --format '{{.HostConfig.NanoCpus}} {{.HostConfig.Memory}} {{.HostConfig.PidsLimit}}' "$limited")"
if [ "$config" != "500000000 134217728 64" ]; then
  echo "FAIL: Docker requested resource configuration mismatch: $config" >&2
  exit 1
fi
docker info --format 'CgroupDriver={{.CgroupDriver}} CgroupVersion={{.CgroupVersion}}'
docker exec "$limited" cat /proc/self/cgroup >/dev/null
docker stats --no-stream "$limited" >/dev/null
echo "PASS: requested resource settings inspected"
echo "NOTE: this does not establish enforced cgroup limits."

echo "[6/7] Shared Docker volume"
docker volume create "$vol" >/dev/null
docker run --rm -v "$vol:/lesson" alpine:3.22 sh -c 'echo chapter5-volume-ok > /lesson/record.txt' >/dev/null
read_back="$(docker run --rm -v "$vol:/lesson" alpine:3.22 cat /lesson/record.txt)"
if [ "$read_back" != "chapter5-volume-ok" ]; then
  echo "FAIL: volume readback mismatch" >&2
  exit 1
fi
echo "PASS: shared volume reads correctly"

echo "[7/7] Automatic cleanup"
echo "PASS: CH5 automated acceptance completed."
echo "All temporary test containers, the test volume and image tag are cleaned on exit."
