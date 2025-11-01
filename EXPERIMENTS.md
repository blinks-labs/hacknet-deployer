# Hackathon Experiments Guide

## Overview

Two subcategories to test mump2p vs GossipSub breakpoints:

**Subcategory 1**: Analyze latency under different parameter settings (mesh degree, shard factors, thresholds)

**Subcategory 2**: Measure latency with varying message sizes, publish rates, and geo locations

## Quick Start

### 1. Deploy Initial Network

```bash
# Update config_p2p/config_p2p.yml with bootstrap_peers from your cluster
make deploy
```

### 2. Run Subcategory 2 Sweep

Tests message sizes, rates, and geo locations:

```bash
SUB_PROXY="<subscriber-proxy-ip>" \
PUB_PROXY="<publisher-proxy-ip>" \
TOPIC=mytopic \
NUM_MESSAGES=200 \
SIZES="256,1024,4096,16384,65536" \
RATES="0,5,10,20" \
./scripts/run_sweep.sh
```

**Typical proxy IPs** (from nodes.ini):
- London, Frankfurt: high-bandwidth, low-latency
- Tokyo, Sao Paulo: intercontinental

### 3. Run Subcategory 1 Parameter Tests

Vary mesh/shard/threshold settings:

```bash
# Test 1: Lower mesh degree (4)
./scripts/set_config.sh mesh_degree_target 4
make upload_config && make deploy

# Run same sweep as above
SUB_PROXY="..." PUB_PROXY="..." ./scripts/run_sweep.sh

# Test 2: Higher shard factor (8)
./scripts/set_config.sh mesh_degree_target 8
./scripts/set_config.sh rlnc_shard_factor 8
make upload_config && make deploy

# Run sweep again
SUB_PROXY="..." PUB_PROXY="..." ./scripts/run_sweep.sh

# Test 3: Different threshold (0.9)
./scripts/set_config.sh forward_shard_threshold 0.9
make upload_config && make deploy

# Run sweep again
```

### 4. Compare mump2p vs GossipSub

```bash
# Baseline: Optimum (mump2p)
./scripts/set_config.sh node_mode optimum
make upload_config && make deploy
SUB_PROXY="..." PUB_PROXY="..." ./scripts/run_sweep.sh

# Comparison: GossipSub
./scripts/set_config.sh node_mode gossipsub
make upload_config && make deploy
SUB_PROXY="..." PUB_PROXY="..." ./scripts/run_sweep.sh
```

### 5. Visualize Results

```bash
# Build visualization dataset
node scripts/build_results_manifest.js

# Start Next.js app
cd web && npm install && npm run dev
# Open http://localhost:3000
```

Compare:
- **Latency percentiles** (p50, p90, p99, max) across scenarios
- **Delivery success rate** (messages received / published)
- **Timeline patterns** (stable vs spikey)

## Key Breakpoint Tests

### Message Size Stress

```bash
SIZES="1024,10240,102400,1048576,10485760"  # 1KB to 10MB
RATES="0"  # Maximum rate
./scripts/run_sweep.sh
```

Look for:
- First size where GossipSub drops significantly vs mump2p
- Max size where both maintain <99% delivery
- Latency spikes as size increases

### Publish Rate Stress

```bash
SIZES="1024"  # Fixed 1KB
RATES="0,50,100,200,500"  # 0=unlimited, then capping
./scripts/run_sweep.sh
```

Look for:
- First rate where GossipSub fails vs mump2p
- Sustained rate without drops

### Geo Distance

Use different proxy pairs:

```bash
# Close: London <-> Frankfurt (EU)
# Medium: London <-> Tokyo (EU-ASIA)
# Far: Sao Paulo <-> Tokyo (SA-ASIA)
```

## Expected Findings

**mump2p advantages**:
- Better handling of large messages (>100KB)
- More consistent latency at high rates
- Better resilience under mesh churn

**GossipSub advantages**:
- Lower overhead for small messages (<1KB)
- Faster gossip convergence initially

## Results Structure

```
results/
  <timestamp>/
    latency_sz256_r0.csv       # 256B, unlimited rate
    latency_sz1024_r5.csv      # 1KB, 5 msg/s
    ...

web/public/data/
  <timestamp>/
    latency_sz256_r0.csv       # copied from results
  manifest.json                # index for web app
```

## Troubleshooting

**No messages received?**
- Check proxy IPs are correct
- Verify `make deploy` finished successfully
- Check docker logs on nodes: `docker logs p2pnode`

**Parsing errors?**
- Ensure subscriber ran with `--debug` flag
- Check log timestamps are ISO8601

**App not showing data?**
- Re-run `node scripts/build_results_manifest.js` after new sweeps
- Check browser console for fetch errors

