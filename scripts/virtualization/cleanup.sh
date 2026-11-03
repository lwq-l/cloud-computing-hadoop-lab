#!/usr/bin/env bash
# 仅清理本章固定命名的教学容器和卷；不会执行 docker system prune。
set -euo pipefail
if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
  echo "Docker is not available; nothing to clean."
  exit 0
fi
for name in ch5-demo ch5-limited; do
  if docker container inspect "$name" >/dev/null 2>&1; then
    docker rm -f "$name"
  fi
done
if docker volume inspect ch5-data >/dev/null 2>&1; then
  docker volume rm ch5-data
fi
echo "PASS: Chapter 5 demo containers and volume cleaned."
