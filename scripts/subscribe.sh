#!/bin/bash
# subscribe script

PROXY_IP="your-ip-here"
mump2p --disable-auth --client-id="hackathon" subscribe --topic=mytopic --service-url="http://${PROXY_IP}:8080"

# Use the following command to turn on debugging mode for analysis
#mump2p --debug --disable-auth --client-id="hackathon" subscribe --topic=mytopic --service-url="http://${PROXY_IP}:8080"
