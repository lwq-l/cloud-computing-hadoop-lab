#!/usr/bin/env bash
# 第六章教师端核查：临时资源采用唯一名称；退出时清理。
# 仅确认容器网络和数据卷能否正常操作，不保证 CNB 必然支持自定义 bridge。
set -euo pipefail
cd "$(dirname "$0")/../.."
suffix="check-$(date +%s)-$$"
export CH6_NET_A="ch6-net-a-$suffix"
export CH6_NET_B="ch6-net-b-$suffix"
export CH6_SERVER="ch6-web-$suffix"
export CH6_VOLUME="ch6-data-$suffix"

cleanup() { bash scripts/ch06/cleanup.sh >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo "[1/7] Prerequisites"
bash scripts/ch06/check-env.sh
echo "[2/7] Pull light image"
docker pull alpine:3.22 >/dev/null
echo "PASS: Alpine image available"

echo "[3/7] Network exercise (fallback is supported)"
bash scripts/ch06/network-demo.sh setup
bash scripts/ch06/network-demo.sh status
bash scripts/ch06/network-demo.sh test
echo "NOTE: if custom bridge is unavailable, this only validates the fallback."

echo "[4/7] Logical network example"
python3 scripts/ch06/network-sim.py | grep -F "PASS: CH6 network concept demo finished."
echo "[5/7] Sparse file and copy-on-write analogy"
python3 scripts/ch06/storage-demo.py | grep -F "PASS: CH6 storage principles demo finished."
echo "[6/7] Cloud storage categories"
python3 scripts/ch06/cloud-storage-demo.py | grep -F "PASS: CH6 cloud storage types demo finished."

echo "[7/7] Docker volume"
docker volume create "$CH6_VOLUME" >/dev/null
docker run --rm -v "$CH6_VOLUME:/data" alpine:3.22 sh -c 'echo ch6-volume-ok > /data/shared.txt' >/dev/null
output="$(docker run --rm -v "$CH6_VOLUME:/data" alpine:3.22 cat /data/shared.txt)"
test "$output" = "ch6-volume-ok"
echo "PASS: CH6 Docker volume readback"
echo "PASS: CH6 teacher acceptance script completed."
echo "NOTE: cleanup of this script's temporary resources runs automatically."
