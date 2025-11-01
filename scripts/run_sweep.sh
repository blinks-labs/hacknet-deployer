#!/bin/bash

# Sweep message sizes, publish rates, and proxies. One-shot subscriber per run.
# Usage:
#   SUB_PROXY=SUB_IP PUB_PROXY=PUB_IP TOPIC=mytopic ./scripts/run_sweep.sh

set -euo pipefail

SUB_PROXY=${SUB_PROXY:-"136.117.96.13"}
PUB_PROXY=${PUB_PROXY:-"35.185.219.82"}
TOPIC=${TOPIC:-mytopic}
CLIENT_ID=${CLIENT_ID:-"hackathon"}
NUM_MESSAGES=${NUM_MESSAGES:-100}

# Comma-separated lists
SIZES=${SIZES:-"256,1024,4096,16384,65536"}                 # bytes
RATES=${RATES:-"0,5,10,20"}                                  # msgs/sec (0 = max)

# Extract node_mode from config
NODE_MODE=$(grep -A1 "^sidecar:" config_p2p/config_p2p.yml | grep "node_mode:" | awk '{print $2}' | tr -d '"')
if [ -z "${NODE_MODE}" ]; then NODE_MODE="unknown"; fi

RUN_TAG=$(date -u +%Y%m%dT%H%M%SZ)_${NODE_MODE}
RESULTS_DIR="results/${RUN_TAG}"
LOGS_DIR="logs/${RUN_TAG}"
mkdir -p "${RESULTS_DIR}" "${LOGS_DIR}"

echo "Node mode: ${NODE_MODE}"

IFS=',' read -r -a size_arr <<< "${SIZES}"
IFS=',' read -r -a rate_arr <<< "${RATES}"

for sz in "${size_arr[@]}"; do
  for rate in "${rate_arr[@]}"; do
    echo "=== Run: size=${sz}B rate=${rate}/s ==="
    sub_log="${LOGS_DIR}/subscriber_${SUB_PROXY//./-}_${TOPIC}_sz${sz}_r${rate}.log"

    # Start subscriber in background
    PROXY_IP="${SUB_PROXY}" TOPIC="${TOPIC}" CLIENT_ID="${CLIENT_ID}" DEBUG_FLAG="--debug" \
      ./scripts/subscribe.sh | tee -a "${sub_log}" &
    sub_pid=$!
    
    # Give it a moment to connect
    sleep 2

    # Publish
    PROXY_IP="${PUB_PROXY}" TOPIC="${TOPIC}" CLIENT_ID="${CLIENT_ID}" \
      NUM_MESSAGES="${NUM_MESSAGES}" MESSAGE_SIZE_BYTES="${sz}" PUBLISH_RATE_PER_SEC="${rate}" \
      ./scripts/publish.sh

    # Allow final messages to drain
    sleep 3
    # Stop subscriber
    kill ${sub_pid} 2>/dev/null || true
    sleep 1
    kill -9 ${sub_pid} 2>/dev/null || true
    
    # Clean up any leftover processes from the subscription
    pkill -f "mump2p.*subscribe.*${TOPIC}" 2>/dev/null || true

    # Parse latency
    out_csv="${RESULTS_DIR}/latency_sz${sz}_r${rate}.csv"
    if ./scripts/parse_latency.py "${sub_log}" "${out_csv}" 2>&1; then
      echo "✓ Parsed ${out_csv}"
    else
      echo "✗ Failed to parse ${sub_log}"
    fi
  done
done

echo "Sweep complete. Results in ${RESULTS_DIR}"


