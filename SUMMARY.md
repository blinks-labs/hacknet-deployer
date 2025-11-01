# Hackathon Deliverables Summary

## Problem Statement

Push the mump2p network to its limits and document conditions where mump2p keeps working while GossipSub fails.

**Subcategory 1**: Analyze latency under different parameter settings (mesh degree, shard factors, thresholds)

**Subcategory 2**: Measure latency with varying message sizes, publish rates, and geo locations

## What We Built

### 1. Automated Experiment Runner

**Scripts**:
- `scripts/publish.sh` - Latency-instrumented publisher (embeds timestamps + UUIDs)
- `scripts/subscribe.sh` - Timestamped subscriber with structured logging  
- `scripts/run_sweep.sh` - Automated sweeps across message sizes, rates, geo pairs
- `scripts/parse_latency.py` - Log parser → CSV with percentiles (p50/p90/p99/max)
- `scripts/set_config.sh` - Modify protocol params (mesh degree, shard factors, etc)
- `scripts/build_results_manifest.js` - Prepare datasets for visualization

**Features**:
- Parametric control over message size, publish rate, geo location
- End-to-end latency measurement (publish timestamp → receive timestamp)
- Structured CSV output for analysis
- Supports both mump2p (Optimum) and GossipSub modes

### 2. Next.js Visualization App

**Location**: `web/`

**Features**:
- Interactive dropdown to select experimental runs
- Latency timeline chart (time-series of message latency)
- Percentile stats display (p50, p90, p99, max)
- Real-time data loading from CSV files
- Responsive Recharts-based visualization

**Access**:
```bash
cd web && npm install && npm run dev
# http://localhost:3000
```

### 3. Documentation

**Files**:
- `README.md` - Updated with experiment automation section
- `EXPERIMENTS.md` - Detailed breakpoint testing guide
- `SETUP_COMPLETE.md` - Quick start checklist
- `SUMMARY.md` - This file

## How to Use

### Quick Start

1. **Deploy network**:
```bash
make deploy
```

2. **Run a sweep**:
```bash
SUB_PROXY="136.117.96.13" \
PUB_PROXY="35.185.219.82" \
TOPIC=mytopic \
NUM_MESSAGES=200 \
SIZES="256,1024,4096,16384,65536" \
RATES="0,5,10,20" \
./scripts/run_sweep.sh
```

3. **Visualize**:
```bash
node scripts/build_results_manifest.js
cd web && npm run dev
```

4. **Test breakpoints**:
```bash
# Switch to GossipSub
./scripts/set_config.sh node_mode gossipsub
make upload_config && make deploy

# Re-run same sweep, compare results
```

### Key Breakpoint Tests

**Message Size Stress**:
```bash
SIZES="1024,10240,102400,1048576,10485760"
```

**Publish Rate Stress**:
```bash
RATES="0,50,100,200,500"
```

**Geo Distance**:
- Close: London ↔ Frankfurt
- Medium: London ↔ Tokyo  
- Far: Sao Paulo ↔ Tokyo

**Protocol Params**:
```bash
./scripts/set_config.sh mesh_degree_target 4   # vs 12
./scripts/set_config.sh rlnc_shard_factor 2    # vs 8
./scripts/set_config.sh forward_shard_threshold 0.5  # vs 0.9
```

## Expected Results

**CSV Output** (`results/<timestamp>/`):
- `latency_sz256_r0.csv` - 256B, unlimited rate
- `latency_sz1024_r5.csv` - 1KB, 5 msg/s
- etc.

**Metrics per run**:
- Delivery success rate (received / published)
- Latency percentiles (p50, p90, p99, max)
- Timeline pattern (stable vs spikey)

**Comparison opportunities**:
- mump2p vs GossipSub on large messages
- mump2p vs GossipSub at high rates
- Effect of geo distance
- Impact of mesh degree, shard factors, thresholds

## Next Steps for Analysis

1. **Baseline**: Run `node_mode=optimum` sweeps across all scenarios
2. **Control**: Run `node_mode=gossipsub` sweeps, same scenarios
3. **Compare**: Use web app to load both datasets side-by-side
4. **Document**: Identify breakpoint conditions (max size, max rate where GossipSub fails but mump2p succeeds)
5. **Visualize**: Capture charts showing latency differences
6. **Report**: Present findings with evidence from CSV data

## Files Reference

**Experiment configs**:
- `config_p2p/config_p2p.yml` - P2P protocol settings
- `nodes.ini` - Cluster node definitions

**Output locations**:
- `results/<timestamp>/` - CSV files
- `logs/<timestamp>/` - Raw subscriber logs
- `web/public/data/` - Visualization dataset

**Key scripts**:
- `scripts/run_sweep.sh` - Main runner
- `scripts/set_config.sh` - Param adjuster
- `scripts/build_results_manifest.js` - Dataset builder

## Status

✅ All tools implemented and tested  
✅ Documentation complete  
✅ Sample data generated for verification  
✅ Next.js app builds and runs  
✅ Ready to run experiments

## Contact

For issues or questions, check:
- `EXPERIMENTS.md` for detailed testing procedures
- `README.md` for basic usage
- `SETUP_COMPLETE.md` for troubleshooting

