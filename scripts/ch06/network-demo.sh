#!/usr/bin/env bash
# 仅操作Docker虚拟网络，不修改宿主网卡、iptables、路由或VPN。
set -euo pipefail
NET_A="${CH6_NET_A:-ch6-net-a}"
NET_B="${CH6_NET_B:-ch6-net-b}"
SERVER="${CH6_SERVER:-ch6-web}"
IMAGE="alpine:3.22"
MODE="${1:-help}"
docker_ok() { command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; }
if ! docker_ok; then
  echo "ERROR: Docker unavailable; use the CNB terminal." >&2
  exit 2
fi
ensure_net() {
  local name="$1"
  if docker network inspect "$name" >/dev/null 2>&1; then return 0; fi
  docker network create --driver bridge "$name" >/dev/null
}
case "$MODE" in
  setup)
    if ! ensure_net "$NET_A"; then
      echo "BRIDGE_UNAVAILABLE: custom networks are restricted. Use fallback and the Python concept demo."
      exit 0
    fi
    if ! ensure_net "$NET_B"; then
      echo "BRIDGE_UNAVAILABLE: unable to create second network. Use fallback."
      exit 0
    fi
    if ! docker container inspect "$SERVER" >/dev/null 2>&1; then
      docker run -d --name "$SERVER" --network "$NET_A" "$IMAGE" sh -c 'mkdir -p /www; echo CH6_NETWORK_OK > /www/index.html; busybox httpd -f -p 8080 -h /www' >/dev/null
    elif [ "$(docker inspect -f '{{.State.Running}}' "$SERVER")" != "true" ]; then
      docker start "$SERVER" >/dev/null
    fi
    echo "MODE=BRIDGE"
    docker network ls --filter "name=ch6-"
    docker ps --filter "name=$SERVER"
    ;;
  test)
    if docker network inspect "$NET_A" >/dev/null 2>&1 && docker network inspect "$NET_B" >/dev/null 2>&1 && docker inspect "$SERVER" >/dev/null 2>&1; then
      echo "[Same virtual network] client -> server:"
      response="$(docker run --rm --network "$NET_A" "$IMAGE" wget -T 5 -q -O - "http://$SERVER:8080/" 2>&1)" || { echo "ERROR: same-network web request failed: $response" >&2; exit 3; }
      echo "$response"
      case "$response" in *CH6_NETWORK_OK*) echo "PASS: same-network service discovery and HTTP";; *) echo "FAIL: unexpected web response"; exit 4;; esac
      echo "[Different virtual networks] name resolution check:"
      if docker run --rm --network "$NET_B" "$IMAGE" wget -T 3 -q -O - "http://$SERVER:8080/" >/dev/null 2>&1; then
        echo "WARNING: other-network name unexpectedly reachable; do not claim isolation."
      else
        echo "OBSERVED: service name is not reachable from the second network."
      fi
      echo "NOTE: failure by hostname alone is not proof of IP-level isolation or security policy."
    else
      echo "MODE=FALLBACK: custom bridge was not created; compare built-in Docker network modes."
    fi
    echo "[No network] inspect container interfaces:"
    if docker run --rm --network none "$IMAGE" sh -c 'ls /sys/class/net'; then
      echo "PASS: --network none mode observed."
    else
      echo "WARNING: even Docker --network none is unavailable in this environment."
    fi
    echo "[Default bridge] inspect container interfaces:"
    if docker run --rm --network bridge "$IMAGE" sh -c 'ls /sys/class/net'; then
      echo "PASS: built-in Docker bridge mode observed."
    else
      echo "WARNING: built-in bridge mode is also restricted here."
    fi
    echo "=== Docker networks ==="
    docker network ls
    ;;
  status)
    docker network ls
    docker ps -a --filter "name=$SERVER"
    if docker network inspect "$NET_A" >/dev/null 2>&1; then
      docker network inspect -f 'Network={{.Name}} Driver={{.Driver}}' "$NET_A"
    fi
    if docker container inspect "$SERVER" >/dev/null 2>&1; then
      docker inspect -f 'Container={{.Name}} NetworkMode={{.HostConfig.NetworkMode}}' "$SERVER"
      docker inspect -f '{{range .NetworkSettings.Networks}}NetworkID={{.NetworkID}} ContainerIP={{.IPAddress}}{{end}}' "$SERVER"
    fi
    ;;
  cleanup)
    docker rm -f "$SERVER" >/dev/null 2>&1 || true
    docker network rm "$NET_B" >/dev/null 2>&1 || true
    docker network rm "$NET_A" >/dev/null 2>&1 || true
    echo "PASS: CH6 network demonstration resources cleaned."
    ;;
  *)
    echo "Usage: bash scripts/ch06/network-demo.sh {setup|status|test|cleanup}"
    exit 1
    ;;
esac
