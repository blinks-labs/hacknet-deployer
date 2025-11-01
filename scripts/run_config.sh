#!/bin/bash

# Run a sweep with a specific configuration
# Usage:
#   ./scripts/run_config.sh

SUB_PROXY=${SUB_PROXY:-"136.117.96.13"} \
PUB_PROXY=${PUB_PROXY:-"35.185.219.82"} \
TOPIC=mytopic \
NUM_MESSAGES=200 \
SIZES="256,1024,4096,16384,65536" \
RATES="0,5,10,20" \
./scripts/run_sweep.sh