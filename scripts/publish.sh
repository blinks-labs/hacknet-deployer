#!/bin/bash

# publish script

PROXY_IP="your-ip-here"
for i in `seq 1 20`; do 
    string=$(openssl rand -base64 2000 | head -c 2000);  
    mump2p --disable-auth --client-id="hackathon" publish --message="${string}" --topic=mytopic --service-url="http://${PROXY_IP}:8080" --debug
done
