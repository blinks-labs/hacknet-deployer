#!/bin/bash
# subscribe script (parameterized, structured logging)

# Usage (env overrides):
#   PROXY_IP=5.6.7.8 TOPIC=mytopic ./subscribe.sh

PROXY_IP=${PROXY_IP:-"136.117.96.13"}
TOPIC=${TOPIC:-mytopic}
CLIENT_ID=${CLIENT_ID:-"hackathon"}
DEBUG_FLAG=${DEBUG_FLAG:-"--debug"}

mkdir -p logs
log_file="logs/subscriber_${PROXY_IP//./-}_${TOPIC}.log"
echo "Writing subscriber log to ${log_file}"

# Capture CLI output line-by-line with receive timestamp for latency parsing later
# Use unbuffer if available (for older systems), otherwise rely on awk's line buffering
if command -v unbuffer >/dev/null 2>&1; then
  unbuffer mump2p ${DEBUG_FLAG} --disable-auth --client-id="${CLIENT_ID}" subscribe --topic="${TOPIC}" --service-url="http://${PROXY_IP}:8080" \
    | awk -v proxy="${PROXY_IP}" -v topic="${TOPIC}" '{
        cmd="date -u +%Y-%m-%dT%H:%M:%S.%3NZ"; cmd | getline now; close(cmd);
        printf("%s | proxy=%s | topic=%s | %s\n", now, proxy, topic, $0);
        fflush();
      }' | tee -a "${log_file}"
else
  mump2p ${DEBUG_FLAG} --disable-auth --client-id="${CLIENT_ID}" subscribe --topic="${TOPIC}" --service-url="http://${PROXY_IP}:8080" \
    | awk -v proxy="${PROXY_IP}" -v topic="${TOPIC}" '{
        cmd="date -u +%Y-%m-%dT%H:%M:%S.%3NZ"; cmd | getline now; close(cmd);
        printf("%s | proxy=%s | topic=%s | %s\n", now, proxy, topic, $0);
        fflush();
      }' | tee -a "${log_file}"
fi
