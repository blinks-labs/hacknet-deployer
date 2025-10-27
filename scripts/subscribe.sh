#!/bin/bash
# subscribe script

PROXY_IP="34.82.149.13"
mump2p --disable-auth --client-id="hackathon" subscribe --topic=mytopic --service-url="http://${PROXY_IP}:8080"
