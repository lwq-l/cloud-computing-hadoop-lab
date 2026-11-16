#!/usr/bin/env bash
# 仅清理本章指定的容器、Docker虚拟网络和数据卷。
set -euo pipefail
bash "$(dirname "$0")/network-demo.sh" cleanup
VOL="${CH6_VOLUME:-ch6-data}"
if docker volume inspect "$VOL" >/dev/null 2>&1; then
  docker volume rm "$VOL"
fi
echo "PASS: CH6 cleanup finished (other chapters untouched)."
