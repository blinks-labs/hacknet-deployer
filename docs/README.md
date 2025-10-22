# Cosmoverse Hackathon - Optimum P2P Network Guide

Welcome to the Online Cosmoverse Hackathon! This guide will help you set up and interact with OptimumP2P nodes locally using Docker.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local P2PNode Deployment with Docker](#local-p2pnode-deployment-with-docker)
3. [Communicating with P2PNodes via gRPC](#communicating-with-p2pnodes-via-grpc)
4. [Testing and Experimentation](#testing-and-experimentation)

## Prerequisites

Before proceeding, ensure your development environment meets the following requirements:

### System Requirements
- **Operating System**: Linux or macOS (must support shell scripting and make utility)

### Core Tools
- **Docker**: For containerized deployment and execution
- **Git**: For repository access and branch management
- **Python 3**: For running configuration scripts
- **Go** (optional): Only if you need to generate P2P keys manually

### Required Repositories
- **gRPC client**: https://github.com/getoptimum/optimum-dev-setup-guide

### Optional Repositories
- **mumP2P CLI**: https://github.com/getoptimum/mump2p-cli

## Local P2PNode Deployment with Docker

This section covers how to deploy OptimumP2P nodes locally using Docker containers with the pre-built Optimum P2PNode image.

### Using Pre-built Docker Image

Instead of building the Docker image from source, you can use the official pre-built image from Docker Hub:

**Docker Image**: `getoptimum/p2pnode:latest`

### Step 1: Clone Dev Setup Guide Repository

```shell
git clone https://github.com/getoptimum/optimum-dev-setup-guide
cd optimum-dev-setup-guide
```

### Step 2: Generate Docker Compose Configuration

Create a `docker-compose.yml` file for your desired number of P2P nodes. For example, to create 10 P2P nodes (you can change the number of P2P Nodes):

```shell
python3 scripts/generate_docker-compose_optimump2p.py --num-p2pnodes 10 --image getoptimum/p2pnode:latest
```

**Expected output:**
```
  - p2pnode-1
  - p2pnode-2
  - p2pnode-3
  - p2pnode-4
  - p2pnode-5
  - p2pnode-6
  - p2pnode-7
  - p2pnode-8
  - p2pnode-9
  - p2pnode-10
  Created a docker-compose.yml file with 10
```

### Step 3: Generate P2P Identity Key

You need to create a P2P identity key for the bootstrap node.

```shell
make -C ../optimum-dev-setup-guide generate-identity
```

**Example output:**
```
make: Entering directory '/home/user/optimum/optimum-dev-setup-guide'
Generating new P2P identity...
Peer ID: 12D3KooWH4v2ZyiehGSQ68qdX7ScpjiWhaSMiQE6HgnvrwSEJMqu
make: Leaving directory '/home/user/optimum/optimum-dev-setup-guide'
```

### Step 4: Verify the Key

Check that the key file was created:

```shell
cat /home/user/optimum/optimum-dev-setup-guide/identity/p2p.key
```

**Example output:**
```json
{"Key":"CAESQNip0wtV4LpSlL3a3wTIyo9bKfzt0VYdsmfFeeWJ4fAx7eUx1zxyeGhbfAB9DAA4FYzA4FEXTySZpba5KA2OHzM=","ID":"12D3KooWRq1VcVYyKTGRGuSzpMT792mBecAPSDKhGwKcFdCd8Pbp"}
```

### Step 5: Deploy the Docker Containers

Deploy the containers using the Peer ID from the key as the `BOOTSTRAP_PEER_ID` environment variable:

```shell
BOOTSTRAP_PEER_ID=12D3KooWRq1VcVYyKTGRGuSzpMT792mBecAPSDKhGwKcFdCd8Pbp docker compose -f docker-compose.yml up -d
```

BOOTSTRAP_PEER_ID=12D3KooWH4v2ZyiehGSQ68qdX7ScpjiWhaSMiQE6HgnvrwSEJMqu docker compose -f docker-compose.yml up -d

**Expected output for 10 nodes:**
```
[+] Running 10/10
 ✔ Container hacknet-deployer-p2pnode-4-1   Started                                                                         1.1s 
 ✔ Container hacknet-deployer-p2pnode-7-1   Started                                                                         0.5s 
 ✔ Container hacknet-deployer-p2pnode-6-1   Started                                                                         0.7s 
 ✔ Container hacknet-deployer-p2pnode-1-1   Started                                                                         0.9s 
 ✔ Container hacknet-deployer-p2pnode-2-1   Started                                                                         1.1s 
 ✔ Container hacknet-deployer-p2pnode-3-1   Started                                                                         0.7s 
 ✔ Container hacknet-deployer-p2pnode-8-1   Started                                                                         1.0s 
 ✔ Container hacknet-deployer-p2pnode-9-1   Started                                                                         0.9s 
 ✔ Container hacknet-deployer-p2pnode-5-1   Started                                                                         0.8s 
 ✔ Container hacknet-deployer-p2pnode-10-1  Started                                                                         1.2s 
```

### Step 6: Verify Running Containers

Check that all containers are running:

```shell
docker ps -a
```

### Step 7: Check Docker Logs

Wait a minute or two for the nodes to initialize, then check the logs:

```shell
docker logs <container_id_or_name>
```

For example:
```shell
docker logs p2pnode-1
```

### Port Mappings

Each P2P node container exposes two main ports:

- **HTTP API Port (9090 inside container)**: Mapped to host ports starting at 9090
  - Container 1: `9090`
  - Container 2: `9091`
  - Container 3: `9092`
  - And so on...

- **gRPC Port (33212 inside container)**: Mapped to host ports starting at 33212
  - Container 1: `33212`
  - Container 2: `33213`
  - Container 3: `33214`
  - And so on...

### Testing the Deployment with HTTP API

You can test the deployment using the HTTP API endpoints:

**First node (port 9090):**
```shell
curl localhost:9090/api/v1/p2p-snapshot | jq
curl localhost:9090/api/v1/health | jq
curl localhost:9090/api/v1/node-state | jq
```

**Second node (port 9091):**
```shell
curl localhost:9091/api/v1/p2p-snapshot | jq
curl localhost:9091/api/v1/health | jq
curl localhost:9091/api/v1/node-state | jq
```

**Third node (port 9092):**
```shell
curl localhost:9092/api/v1/p2p-snapshot | jq
curl localhost:9092/api/v1/health | jq
curl localhost:9092/api/v1/node-state | jq
```

## Communicating with P2PNodes via gRPC

Now that you have P2P nodes running locally, you can interact with them using the gRPC client.

### Step 1: Clone the Dev Setup Guide Repository

```shell
git clone https://github.com/getoptimum/optimum-dev-setup-guide
cd optimum-dev-setup-guide
make build
```

### Step 2: Install the gRPC Client

Follow the installation instructions in the repository to build the gRPC client:

```shell
# Navigate to the gRPC client directory
cd grpc_p2p_client

# Build the client (assuming Go is installed)
go build -o p2p-client .
```

Alternatively, if there's a pre-built binary or different build instructions in the repository, follow those.

### Step 3: Basic Subscribe Operation

To subscribe to a topic and listen for messages, use the subscribe mode.

**Subscribe on the first node (port 33212):**
```shell
./grpc_p2p_client/p2p-client -mode=subscribe -topic="testtopic" --addr="localhost:33212"
```

This will start listening for messages on the topic `testtopic` from the first P2P node.

### Step 4: Basic Publish Operation

To publish messages to a topic, use the publish mode. Open a new terminal and run:

**Publish a single message on the second node (port 33213):**
```shell
./grpc_p2p_client/p2p-client -mode=publish -topic="testtopic" -msg="Hello from Cosmoverse!" --addr="localhost:33213"
```

**Publish multiple messages in a loop:**
```shell
for i in `seq 1 10`; do
  sleep 1
  ./grpc_p2p_client/p2p-client -mode=publish -topic="testtopic" -msg="Message number $i" --addr="localhost:33215"
done
```

This example publishes messages to the fourth node (port 33215), which will propagate through the P2P network to all subscribers.

### Step 5: Advanced Testing Scenarios

**Multi-node Subscribe Test:**

Open multiple terminals and subscribe from different nodes:

Terminal 1:
```shell
./grpc_p2p_client/p2p-client -mode=subscribe -topic="testtopic" --addr="localhost:33212"
```

Terminal 2:
```shell
./grpc_p2p_client/p2p-client -mode=subscribe -topic="testtopic" --addr="localhost:33214"
```

Terminal 3:
```shell
./grpc_p2p_client/p2p-client -mode=subscribe -topic="testtopic" --addr="localhost:33216"
```

Then publish from a fourth terminal:
```shell
./grpc_p2p_client/p2p-client -mode=publish -topic="testtopic" -msg="Broadcast message!" --addr="localhost:33218"
```

You should see the message received by all subscribing terminals.

## Testing and Experimentation

### Experiment Ideas

Now that you have a local P2P network running, here are some experiments you can try:

#### 1. Latency Measurements

Measure the latency between publishing and receiving messages across different nodes:

- Publish messages with timestamps
- Subscribe from multiple nodes
- Calculate the time difference between send and receive
- Compare latency across different node pairs

#### 2. Message Size Impact

Test how message size affects propagation:

```shell
# Small messages
./grpc_p2p_client/p2p-client -mode=publish -topic="testtopic" -msg="small" --addr="localhost:33212"

# Large messages (use base64 encoded data for larger payloads)
./grpc_p2p_client/p2p-client -mode=publish -topic="testtopic" -msg="<large-base64-string>" --addr="localhost:33212"
```

#### 3. Network Topology Analysis

Examine how nodes are connected:

```shell
# Check the P2P snapshot from each node
for port in {9090..9099}; do
  echo "Node on port $port:"
  curl -s localhost:$port/api/v1/p2p-snapshot | jq
  echo "---"
done
```

#### 4. Multi-Topic Communication

Test communication across different topics:

```shell
# Terminal 1: Subscribe to topic A
./grpc_p2p_client/p2p-client -mode=subscribe -topic="topicA" --addr="localhost:33212"

# Terminal 2: Subscribe to topic B
./grpc_p2p_client/p2p-client -mode=subscribe -topic="topicB" --addr="localhost:33213"

# Terminal 3: Publish to both topics
./grpc_p2p_client/p2p-client -mode=publish -topic="topicA" -msg="Message for A" --addr="localhost:33214"
./grpc_p2p_client/p2p-client -mode=publish -topic="topicB" -msg="Message for B" --addr="localhost:33214"
```

#### 5. Data Analysis and Visualization

Collect data from your experiments and analyze:

- Message delivery times
- Network throughput
- Node connectivity graphs
- Message propagation patterns

You can parse the output logs and create visualizations to better understand the network behavior.

### Example Output Format

When receiving messages, you'll see output similar to:

```
Recv:  [1]  receiver_addr:localhost:33212  [recv_time, size]:[1757614175397077962, 4073]  sender_addr:localhost:33215  [send_time, size]:[1757614175023232000, 4000]  topic:testtopic  hash:04b18eb4  protocol:gRPC
```

This includes:
- Message number
- Receiver address and port
- Receive timestamp and message size
- Sender address and port
- Send timestamp and original message size
- Topic name
- Message hash
- Protocol used

## Stopping the Environment

To stop all running P2P nodes:

```shell
docker compose -f docker-compose.yml down
```

To stop and remove all containers, networks, and volumes:

```shell
docker compose -f docker-compose.yml down -v
```
