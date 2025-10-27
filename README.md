# README

### Requirements

You will need to be able to:

- Run Makefiles
- Run Ansible playbooks (Ansible required)
- Mump2p-CLI: you will need to download from [here](https://github.com/getoptimum/mump2p-cli)

### Getting Started

First, let's go over your cluster. A sample cluster contains 12 servers with different geolocations:

```
  europe-west2: 2 # London
  europe-west3: 2 # Frakfurt
  northamerica-northeast1: 1 # Montreal
  us-east4: 2 # Norther Virginia
  us-west1: 2 # Oregon
  southamerica-east1: 1 # Sao Paulo
  asia-northeast1: 1 # Tokyo
  australia-southeast1: 1 # Singapore
```

You will given get a list of IPs, your cluster, that needs to be populated in your `nodes.ini` file. The chosen convention is that your top 4 IPs are your Proxies IP servers and the bottom 8 IPs are you P2PNodes with the last P2PNode being your bootstrap node.

### Make Commands

During your experiments, you will run 3 different `make` commands:

A) `make upload_config`: which uploads your modified p2p config to your cluster

B) `make deploy`: which deploys Optimum Proxies and Optimum P2PNodes to your cluster

C) `make stop_and_remove_containers`: which will stop all running containers in your cluster

The other `make` commands such as `make deploy_proxy` or `make deploy_p2p` are used in the Ansible Playbooks, and are not commands you should invoke directly. You can always try `make help` to see the different commands

### Scripts

Note: The installation of mump2p-cli is required for this step

You will run two scripts: `scripts/subscribe.sh` and `scripts/publish.sh` . Both scripts will take as input a Proxy IP

```
PROXY_IP="your-proxy-ip"
```

During your experiments, it is important to choose different Proxy IPs, not the same in both scripts. These are sample scripts, you can modify them and increase the publish rate, add sleep, increase message size, change Proxy locations, etc.  

Run subscribe in one terminal:
```
./subscribe
```

and publish in another terminal:

```
./publish
```

### P2P Configurations

Your can check (and update) the configuration of your P2P nodes network. Your configuration file is under `config_p2p/config_p2p.yml`. It contains information such as:
```
sidecar:
  node_mode: "optimum" # Options: "gossipsub", "optimum"
  listen_port: 33212 # grpc port for sidecar
  identity_dir: "/identity" # where p2p key located

# P2P node API configuration (used for health check)
api:
  http_port: 9090

# Optimum protocol configuration
optimum:
  listen_port: 7070
  max_message_size_bytes: 1048576  # 1MB
  random_message_size_bytes: 512
  rlnc_shard_factor: 4
  publisher_shard_multiplier: 1.5
  forward_shard_threshold: 0.75
  mesh_degree_target: 8
  mesh_degree_min: 4
  mesh_degree_max: 12
  bootstrap_peers:
    - "<your_peer_id_here>"
```

Here you can switch between `optimum` and `gossipsub` algorithms. You can also play with different parameters such as `mesh_degree_target`. To understand what these parameters are, you can check the following [documentation](https://github.com/getoptimum/optimum-dev-setup-guide/blob/main/docs/guide.md#p2p-node-variables) 

You will also need to populate this configuration file with your `bootstrap_peers` information, you will need the bootstrap IP (which is by convention the last IP in the `nodes.ini` file. 

Run `curl <bootstrap_ip>:9090/api/v1/node-state | jq` . Running this command will return something like:
```
{
  "pub_key": "12D3KooWNqxhrQXgDKhfWnJi3kCNS9XgkPdnSGvAV3QY4eZJ4oCF",
  "peers": [],
  "addresses": [
    "/ip4/10.162.0.63/tcp/7070"
  ],
  "topics": []
}
```

You can build your config file as:
```
sidecar:
  node_mode: "optimum" # Options: "gossipsub", "optimum"
  listen_port: 33212 # grpc port for sidecar
  identity_dir: "/identity" # where p2p key located

# P2P node API configuration (used for health check)
api:
  http_port: 9090

# Optimum protocol configuration
optimum:
  listen_port: 7070
  max_message_size_bytes: 1048576  # 1MB
  random_message_size_bytes: 512
  rlnc_shard_factor: 4
  publisher_shard_multiplier: 1.5
  forward_shard_threshold: 0.75
  mesh_degree_target: 8
  mesh_degree_min: 4
  mesh_degree_max: 12
  bootstrap_peers:
    - "/ip4/<bootstrap_ip>/tcp/7070/p2p/12D3KooWNqxhrQXgDKhfWnJi3kCNS9XgkPdnSGvAV3QY4eZJ4oCF"
```

### Experiments

Before you start the experiments, make sure you can test the basic publish and subscribe scripts:

- Update your `config_p2p.yml` file with your `bootstrap_peers` information
- Make your first deployment with `make deploy`
- Run your scripts:  `subscribe.sh` in one terminal session and `publish.sh` in another terminal session. First Subscribe, then Publish. Check you and see some data
- If you see some output, you are ready to start playing with the P2P configuration file:
  - Stop Docker containers with `make stop_and_remove_containers`
  - Upload your new configuration file with `make upload_config` 
  - Deploy again `make deploy`

