#!/usr/bin/env bash
# 仅操作Docker虚拟网络，不修改宿主网卡、iptables、路由或VPN。
set -euo pipefail
NET_A="${CH6_NET_A:-ch6-net-a}"
NET_B="${CH6_NET_B:-ch6-net-b}"
SERVER="${CH6_SERVER:-ch6-web}"
IMAGE="alpine:3.22"
MODE="${1:-help}"
docker_ok() { command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; }
container_ip() {
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$SERVER" 2>/dev/null || true
}
invalid_ip() {
  case "$1" in
    ""|"invalid IP"|"<nil>"|"0.0.0.0") return 0 ;;
    *) return 1 ;;
  esac
}
run_fallback() {
  echo "MODE=FALLBACK"
  echo "Reason: Docker bridge communication could not be verified."
  echo "Running local HTTP with an application-level access rule."
  python3 scripts/ch06/network-fallback.py
}
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
      echo "BRIDGE_UNAVAILABLE: custom bridge creation failed."
      echo "MODE=FALLBACK"
      exit 0
    fi
    if ! ensure_net "$NET_B"; then
      echo "BRIDGE_UNAVAILABLE: unable to create second bridge."
      echo "MODE=FALLBACK"
      exit 0
    fi
    if ! docker container inspect "$SERVER" >/dev/null 2>&1; then
      if ! docker run -d --name "$SERVER" --network "$NET_A" "$IMAGE" sh -c 'mkdir -p /www; echo CH6_NETWORK_OK > /www/index.html; busybox httpd -f -p 8080 -h /www' >/dev/null; then
        echo "BRIDGE_UNUSABLE: web container could not start on custom bridge."
        echo "MODE=FALLBACK"
        exit 0
      fi
    elif [ "$(docker inspect -f '{{.State.Running}}' "$SERVER")" != "true" ]; then
      if ! docker start "$SERVER" >/dev/null; then
        echo "BRIDGE_UNUSABLE: existing web container could not start."
        echo "MODE=FALLBACK"
        exit 0
      fi
    fi
    ip="$(container_ip)"
    if invalid_ip "$ip"; then
      echo "BRIDGE_UNUSABLE: container IP is '$ip' (network created, but unusable)."
      echo "MODE=FALLBACK"
    else
      echo "MODE=BRIDGE_CANDIDATE (IP present; communication not yet verified)"
      echo "ServerIP=$ip"
    fi
    docker network ls --filter "name=ch6-"
    docker ps --filter "name=$SERVER"
    ;;
  test)
    bridge_pass=0
    if docker network inspect "$NET_A" >/dev/null 2>&1 &&
       docker network inspect "$NET_B" >/dev/null 2>&1 &&
       docker container inspect "$SERVER" >/dev/null 2>&1; then
      ip="$(container_ip)"
      if invalid_ip "$ip"; then
        echo "BRIDGE_UNUSABLE: container IP is '$ip'; skip DNS-dependent HTTP test."
      else
        echo "[Same virtual network] client -> server:"
        if response="$(docker run --rm --network "$NET_A" "$IMAGE" wget -T 5 -q -O - "http://$SERVER:8080/" 2>&1)"; then
          echo "$response"
          case "$response" in
            *CH6_NETWORK_OK*)
              echo "PASS: same-network service discovery and HTTP"
              bridge_pass=1
              ;;
            *)
              echo "BRIDGE_UNUSABLE: HTTP response did not contain CH6_NETWORK_OK."
              ;;
          esac
        else
          echo "BRIDGE_UNUSABLE: same-network HTTP request failed: $response"
        fi
      fi
      if [ "$bridge_pass" -eq 1 ]; then
        echo "MODE=BRIDGE_VERIFIED"
        echo "[Different virtual networks] name resolution:"
        if docker run --rm --network "$NET_B" "$IMAGE" wget -T 3 -q -O - "http://$SERVER:8080/" >/dev/null 2>&1; then
          echo "WARNING: other-network service unexpectedly reachable by name; investigate."
        else
          echo "OBSERVED: service name is not reachable from the second network."
        fi
        echo "NOTE: name lookup failure alone does not prove all IP-level isolation."
      fi
    else
      echo "BRIDGE_UNAVAILABLE: custom networks or server container missing."
    fi
    if [ "$bridge_pass" -eq 0 ]; then
      run_fallback
    fi
    echo "[No-network Docker mode] interface observation:"
    if docker run --rm --network none "$IMAGE" sh -c 'ls /sys/class/net'; then
      echo "PASS: Docker --network none interface observation."
    else
      echo "WARNING: Docker --network none interface observation unavailable."
    fi
    echo "[Default bridge Docker mode] interface observation:"
    if docker run --rm --network bridge "$IMAGE" sh -c 'ls /sys/class/net'; then
      echo "PASS: Docker default bridge interface observation."
    else
      echo "WARNING: Docker default bridge observation unavailable."
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
