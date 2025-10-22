import yaml
import sys
import os
import argparse
import glob
import json

IP_BASE="172.28.0."

def generate_docker_compose(num_p2pnodes, image, cluster_id):
    # Base structure for docker-compose
    compose_config = {
        'version': '3.8',
        'services': {},
        'networks': {'optimum-network': {'driver': 'bridge', 'ipam': { 'config': [ {'subnet': f'{IP_BASE}0/24'} ]}}}
    }

    # Add flexnode services
    for i in range(num_p2pnodes):
       service_name = f'p2pnode-{i+1}'
       
       compose_config['services'][service_name] = { 
           'image': f'{image}',
           'networks': {'optimum-network': {"ipv4_address": f"{IP_BASE}{i+10}" }}, 
           'restart': 'no',
           'ports': [ f"{33212+i}:33212", f"{7070+i}:7070", f"{6060+i}:6060", f"{9090+i}:9090"],
           'environment': [
               f"CLUSTER_ID={cluster_id}",
               "LOG_LEVEL=debug",
               "NODE_MODE=optimum",  # options: "gossipsub", "optimum"
               "SIDECAR_PORT=33212", # default sidecar port: 33212; grpc bidirectional streaming for the proxy
               "API_PORT=9090",      # default port for API is 9090
               "IDENTITY_DIR=/identity",
               "GOSSIPSUB_PORT=6060", # default port for gossipsub is 6060
               "GOSSIPSUB_MAX_MSG_SIZE=1048576", # 1MB
               "GOSSIPSUB_MESH_TARGET=6", # number of peers to connect to default is 6
               "GOSSIPSUB_MESH_MIN=3", # minimum number of peers to connect to default is 3
               "GOSSIPSUB_MESH_MAX=12", # maximum number of peers to connect to default is 12
               "OPTIMUM_PORT=7070", # default port for Optimum is 7070
               "OPTIMUM_MAX_MSG_SIZE=1048576", # 1MB
               "OPTIMUM_MESH_TARGET=6", # number of peers to connect to
               "OPTIMUM_MESH_MIN=3", # minimum number of peers to connect to
               "OPTIMUM_MESH_MAX=12", # maximum number of peers to connect to
               "OPTIMUM_SHARD_FACTOR=4", # number of shards to create default is 4
               "OPTIMUM_SHARD_MULT=1.5", # multiplier for shard size default is 1.5
               "OPTIMUM_THRESHOLD=0.75", # forward shred threshold default is 0.75
           ]
       }

       if i == 0:
           compose_config['services'][service_name]['volumes'] = [ './optimump2p/data/identity:/identity' ]
       else:
           compose_config['services'][service_name]['environment'].append(f"BOOTSTRAP_PEERS=/ip4/{IP_BASE}10/tcp/7070/p2p/""${BOOTSTRAP_PEER_ID}") 

    return compose_config

def main():
    parser = argparse.ArgumentParser(
        description='Generate docker-compose.yml file for p2pnodenodes',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python generate_docker-compose_p2pnode.py --ips ips.txt --num-flexnodes 3 
  python generate_docker-compose_flexnode.py --help
        """
    )
    parser.add_argument('--num-p2pnodes', type=int, required=True, help='Number of p2pnodes')
    parser.add_argument('--cluster-id', default='cluster-id', type=str, required=False, help='Cluster id')
    parser.add_argument('--image', type=str, required=True, help='docker image name to use')
    args = parser.parse_args()
    
    # Validate arguments
    if args.num_p2pnodes < 1:
        print("Error: Number of flexnodes must be positive")
        sys.exit(1)
    
    # Generate docker-compose configuration
    docker_compose = generate_docker_compose(args.num_p2pnodes, args.image, args.cluster_id)

    # Write docker-compose.yml in current directory
    docker_compose_path = './docker-compose.yml'
    with open(docker_compose_path, 'w') as f:
        yaml.dump(docker_compose, f, default_flow_style=False, sort_keys=False)

    for service_name in docker_compose['services'].keys():
        print(f"  - {service_name}")
    print(f"Created docker-compose.yaml created in  {docker_compose_path} file with {args.num_p2pnodes} p2pnodes")

if __name__ == "__main__":
    main()
