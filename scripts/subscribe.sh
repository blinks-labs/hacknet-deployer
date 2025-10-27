#!/bin/bash
# subscribe script

PROXY_IP="35.200.53.64"
mump2p --disable-auth --client-id="hackathon" subscribe --topic=mytopic --service-url="http://${PROXY_IP}:8080"
