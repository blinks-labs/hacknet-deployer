#!/bin/bash
# subscribe script

PROXY_IP="your-proxy-ip"
mump2p subscribe --topic="mytopic" --service-url="http://${PROXY_IP}:8080"
santiago@gaby:~/optimum/scripts$ 
