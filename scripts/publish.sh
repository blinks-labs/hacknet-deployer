#!/bin/bash

# publish script (parameterized)

# Usage (env overrides):
#   PROXY_IP=1.2.3.4 NUM_MESSAGES=100 MESSAGE_SIZE_BYTES=1024 PUBLISH_RATE_PER_SEC=10 TOPIC=mytopic ./publish.sh

PROXY_IP=${PROXY_IP:-"35.185.219.82"}
NUM_MESSAGES=${NUM_MESSAGES:-20}
MESSAGE_SIZE_BYTES=${MESSAGE_SIZE_BYTES:-2000}
PUBLISH_RATE_PER_SEC=${PUBLISH_RATE_PER_SEC:-0} # 0 => as fast as possible
TOPIC=${TOPIC:-mytopic}
CLIENT_ID=${CLIENT_ID:-"hackathon"}
DEBUG_FLAG=${DEBUG_FLAG:-"--debug"}

interval_sec=0
if [ "$PUBLISH_RATE_PER_SEC" -gt 0 ] 2>/dev/null; then
  # interval as a float seconds string for sleep
  interval_sec=$(python3 - <<EOF
rate=${PUBLISH_RATE_PER_SEC}
print(f"{1.0/float(rate):.6f}")
EOF
)
fi

for i in `seq 1 ${NUM_MESSAGES}`; do 
    # Create payload with ISO8601 publish timestamp and UUID for latency measurement
    ts=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)
    uuid=$(uuidgen 2>/dev/null || openssl rand -hex 16)
    # Random filler bytes to reach desired size (best-effort; header length varies slightly)
    header="{\"id\":\"${uuid}\",\"ts\":\"${ts}\"}::"
    header_len=${#header}
    filler_len=$(( MESSAGE_SIZE_BYTES - header_len ))
    if [ $filler_len -lt 0 ]; then filler_len=0; fi
    filler=$(openssl rand -base64 $(( (filler_len*4/3)+3 )) | tr -d '\n' | head -c ${filler_len})
    payload="${header}${filler}"
    mump2p --disable-auth --client-id="${CLIENT_ID}" publish --message="${payload}" --topic="${TOPIC}" --service-url="http://${PROXY_IP}:8080" ${DEBUG_FLAG}
    if [ "$PUBLISH_RATE_PER_SEC" -gt 0 ] 2>/dev/null; then
      sleep ${interval_sec}
    fi
done
