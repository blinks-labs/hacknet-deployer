# ✅ Setup Complete

## What's Ready

✅ **Parameterized publish/subscribe scripts** with latency measurement  
✅ **Automated sweep runner** for message sizes, rates, and geo locations  
✅ **Protocol parameter adjuster** (mesh/shard/threshold)  
✅ **Latency parser** (log → CSV with percentiles)  
✅ **Next.js visualization app** with charts  
✅ **Results manifest builder** for data management  
✅ **Experiment guide** (EXPERIMENTS.md)

## Next Steps

### 1. Run Your First Experiment

Deploy and test a simple sweep:

```bash
# Deploy cluster
make deploy

# Wait for nodes to be ready, then run sweep
SUB_PROXY="136.117.96.13" \
PUB_PROXY="35.185.219.82" \
TOPIC=mytopic \
NUM_MESSAGES=50 \
SIZES="256,1024" \
RATES="0,5" \
./scripts/run_sweep.sh
```

### 2. Visualize Results

```bash
# Build dataset
node scripts/build_results_manifest.js

# Start app
cd web && npm run dev
# Open http://localhost:3000
```

### 3. Test Breakpoints

Follow `EXPERIMENTS.md` for:
- Message size stress tests (1KB → 10MB)
- Publish rate stress (0 → 500 msg/s)
- Geo distance (same-region vs intercontinental)
- Protocol param variations (mesh degree 4 vs 12, etc)
- mump2p vs GossipSub comparison

## Files to Know

**Scripts** (`scripts/`):
- `run_sweep.sh` - Main experiment runner
- `publish.sh` / `subscribe.sh` - Latency-instrumented clients
- `parse_latency.py` - Log to CSV converter
- `set_config.sh` - Adjust protocol params
- `build_results_manifest.js` - Prepare data for web app

**Config**:
- `config_p2p/config_p2p.yml` - P2P network settings
- `nodes.ini` - Cluster nodes

**Outputs**:
- `results/<timestamp>/` - CSV files per run
- `logs/<timestamp>/` - Raw subscriber logs

**Visualization**:
- `web/app/page.js` - Chart page
- `web/public/data/manifest.json` - Dataset index

## Quick Reference

**Test different message sizes**:
```bash
SIZES="256,1024,4096,65536" ./scripts/run_sweep.sh
```

**Test different publish rates**:
```bash
RATES="0,10,50,100" ./scripts/run_sweep.sh
```

**Change protocol param**:
```bash
./scripts/set_config.sh mesh_degree_target 12
make upload_config && make deploy
```

**Switch to GossipSub**:
```bash
./scripts/set_config.sh node_mode gossipsub
make upload_config && make deploy
```

## Tips

1. **Start small**: Test with 50 messages before running 1000+
2. **Watch logs**: Subscriber shows real-time output during sweeps
3. **Compare datasets**: Side-by-side in web app by toggling dropdown
4. **Look for breakpoints**: Where GossipSub drops but mump2p survives
5. **Document findings**: Take notes on which scenarios reveal differences

## Support

- Full guide: `EXPERIMENTS.md`
- README: Latency automation section
- Node issues: Check `docker logs p2pnode` on remote nodes

Good luck! 🚀

