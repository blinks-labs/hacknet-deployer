#!/usr/bin/env node
// Scans results/*/*.csv and copies into web/public/data/<run>.
// Emits web/public/data/manifest.json for the Next.js app.
const fs = require('fs');
const path = require('path');

const RESULTS_DIR = path.join(process.cwd(), 'results');
const WEB_DATA_DIR = path.join(process.cwd(), 'web', 'public', 'data');

function ensureDir(p) {
  fs.mkdirSync(p, { recursive: true });
}

function listCsvFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  const runs = fs.readdirSync(dir).filter((d) => fs.statSync(path.join(dir, d)).isDirectory());
  const out = [];
  for (const run of runs) {
    const runDir = path.join(dir, run);
    const files = fs.readdirSync(runDir).filter((f) => f.endsWith('.csv'));
    for (const f of files) {
      out.push({ run, abs: path.join(runDir, f), name: f });
    }
  }
  return out;
}

function main() {
  const csvs = listCsvFiles(RESULTS_DIR);
  ensureDir(WEB_DATA_DIR);
  const runs = [];
  for (const { run, abs, name } of csvs) {
    const destDir = path.join(WEB_DATA_DIR, run);
    ensureDir(destDir);
    const dest = path.join(destDir, name);
    fs.copyFileSync(abs, dest);
    const label = `${run} / ${name}`;
    const key = `${run}-${name}`;
    const pathForWeb = `/data/${run}/${name}`;
    runs.push({ key, label, path: pathForWeb });
  }
  runs.sort((a, b) => a.label.localeCompare(b.label));
  const manifest = { generatedAt: new Date().toISOString(), runs };
  ensureDir(path.join(WEB_DATA_DIR));
  fs.writeFileSync(path.join(WEB_DATA_DIR, 'manifest.json'), JSON.stringify(manifest, null, 2));
  console.log(`Wrote ${runs.length} entries to web/public/data/manifest.json`);
}

main();


