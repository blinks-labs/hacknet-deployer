#!/bin/bash
# subscribe script

PROXY_IP="your-proxy-ip-here"
mump2p --disable-auth --client-id="hackathon" subscribe --topic=mytopic --service-url="http://${PROXY_IP}:8080"
