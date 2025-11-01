"use client";

import { useEffect, useMemo, useState } from "react";
import Papa from "papaparse";
import { LineChart, Line, XAxis, YAxis, Tooltip, Legend, CartesianGrid, ResponsiveContainer } from "recharts";

const COLORS = ["#0070f3", "#f59e0b", "#10b981", "#ef4444", "#8b5cf6", "#ec4899", "#06b6d4", "#14b8a6"];

function computePercentiles(values) {
  if (!values.length) return { p50: NaN, p90: NaN, p99: NaN, max: NaN };
  const sorted = [...values].sort((a, b) => a - b);
  const sel = (p) => sorted[Math.max(0, Math.min(sorted.length - 1, Math.round((p / 100) * (sorted.length - 1))))];
  return { p50: sel(50), p90: sel(90), p99: sel(99), max: sorted[sorted.length - 1] };
}

export default function Page() {
  const [manifest, setManifest] = useState(null);
  const [selectedKeys, setSelectedKeys] = useState([]);
  const [loadedData, setLoadedData] = useState({});

  useEffect(() => {
    fetch("/data/manifest.json").then((r) => r.json()).then(setManifest).catch(() => setManifest({ runs: [] }));
  }, []);

  useEffect(() => {
    if (!manifest || !manifest.runs || manifest.runs.length === 0) return;
    const first = manifest.runs[0]?.key;
    if (first && selectedKeys.length === 0) setSelectedKeys([first]);
  }, [manifest, selectedKeys.length]);

  useEffect(() => {
    if (!manifest || selectedKeys.length === 0) return;
    selectedKeys.forEach((key) => {
      if (loadedData[key]) return; // Already loaded
      const item = manifest.runs.find((r) => r.key === key);
      if (!item) return;
      fetch(item.path)
        .then((r) => r.text())
        .then((csv) => {
          const result = Papa.parse(csv, { header: true, dynamicTyping: true });
          const data = (result.data || []).filter((d) => d && d.latency_ms != null && !Number.isNaN(Number(d.latency_ms)));
          setLoadedData((prev) => ({ ...prev, [key]: data }));
        });
    });
  }, [selectedKeys, manifest, loadedData]);

  const timeline = useMemo(() => {
    const datasets = selectedKeys.map((key) => {
      const data = loadedData[key] || [];
      return data.map((r, i) => ({ idx: i + 1, latency_ms: Number(r.latency_ms) || 0 }));
    });
    const maxLen = Math.max(...datasets.map((d) => d.length), 0);
    const combined = [];
    for (let i = 0; i < maxLen; i++) {
      const point = { idx: i + 1 };
      selectedKeys.forEach((key, j) => {
        const item = manifest?.runs.find((r) => r.key === key);
        const label = item?.label || key;
        if (datasets[j] && datasets[j][i]) {
          point[label] = datasets[j][i].latency_ms;
        }
      });
      combined.push(point);
    }
    return combined;
  }, [selectedKeys, loadedData, manifest]);

  const allStats = useMemo(() => {
    return selectedKeys.map((key) => {
      const data = loadedData[key] || [];
      const latMs = data.map((r) => Number(r.latency_ms)).filter((v) => Number.isFinite(v));
      const item = manifest?.runs.find((r) => r.key === key);
      const label = item?.label || key;
      return { key, label, stats: computePercentiles(latMs), count: latMs.length };
    });
  }, [selectedKeys, loadedData, manifest]);

  const toggleDataset = (key) => {
    setSelectedKeys((prev) => (prev.includes(key) ? prev.filter((k) => k !== key) : [...prev, key]));
  };

  return (
    <div style={{ margin: 0, padding: 0, height: "100vh", display: "flex", flexDirection: "column" }}>
      <div style={{ padding: "12px 16px", background: "#f8fafc", borderBottom: "1px solid #e2e8f0" }}>
        <h1 style={{ margin: 0, fontSize: 20, fontWeight: 600 }}>Hacknet Latency Visualization</h1>
      </div>
      
      <div style={{ flex: 1, display: "flex", overflow: "hidden" }}>
        {/* Left sidebar */}
        <div style={{ width: 300, background: "#f9fafb", borderRight: "1px solid #e5e7eb", overflow: "auto", padding: 12 }}>
          <div style={{ marginBottom: 12, fontWeight: 600, fontSize: 14 }}>Select Datasets:</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 4 }}>
            {(manifest?.runs || []).map((r, idx) => (
              <label
                key={r.key}
                style={{
                  display: "flex",
                  alignItems: "flex-start",
                  padding: 8,
                  background: selectedKeys.includes(r.key) ? "#0070f3" : "white",
                  color: selectedKeys.includes(r.key) ? "white" : "#1f2937",
                  border: `1px solid ${selectedKeys.includes(r.key) ? "#0070f3" : "#d1d5db"}`,
                  borderRadius: 4,
                  cursor: "pointer",
                  fontSize: 13,
                  transition: "all 0.2s",
                }}
              >
                <input
                  type="checkbox"
                  checked={selectedKeys.includes(r.key)}
                  onChange={() => toggleDataset(r.key)}
                  style={{ marginRight: 8, marginTop: 2, flexShrink: 0 }}
                />
                <span style={{ wordBreak: "break-word", lineHeight: 1.4 }}>{r.label}</span>
              </label>
            ))}
          </div>
        </div>

        {/* Right content area */}
        <div style={{ flex: 1, display: "flex", flexDirection: "column", overflow: "hidden" }}>
          {/* Stats bar */}
          {allStats.length > 0 && (
            <div style={{ padding: 8, background: "#fafafa", borderBottom: "1px solid #eee", overflowX: "auto" }}>
              <div style={{ display: "flex", gap: 16, flexWrap: "wrap" }}>
                {allStats.map(({ key, label, stats, count }) => (
                  <div key={key} style={{ fontSize: 12, lineHeight: 1.5 }}>
                    <span style={{ fontWeight: 600 }}>{label.split("/")[0]}</span>: p50={stats.p50?.toFixed?.(2) ?? "-"} p90={stats.p90?.toFixed?.(2) ?? "-"} p99={stats.p99?.toFixed?.(2) ?? "-"} max={stats.max?.toFixed?.(2) ?? "-"} (n={count})
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Chart area */}
          <div style={{ flex: 1, padding: 16, background: "#ffffff", display: "flex", flexDirection: "column" }}>
            <div style={{ flex: 1, width: "100%", minHeight: 0 }}>
              <ResponsiveContainer>
                <LineChart data={timeline} margin={{ top: 10, right: 20, bottom: 40, left: 60 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis dataKey="idx" tick={{ fontSize: 12 }} label={{ value: "Message #", position: "insideBottom", offset: -5 }} />
                  <YAxis tick={{ fontSize: 12 }} label={{ value: "Latency (ms)", angle: -90, position: "insideLeft" }} />
                  <Tooltip />
                  <Legend wrapperStyle={{ paddingTop: 20 }} />
                  {selectedKeys.map((key, idx) => {
                    const item = manifest?.runs.find((r) => r.key === key);
                    const label = item?.label || key;
                    return (
                      <Line
                        key={key}
                        type="monotone"
                        dataKey={label}
                        stroke={COLORS[idx % COLORS.length]}
                        dot={false}
                        strokeWidth={2}
                        name={label}
                      />
                    );
                  })}
                </LineChart>
              </ResponsiveContainer>
            </div>
            <p style={{ color: "#666", fontSize: 12, marginTop: 8, marginBottom: 0 }}>Tip: Click datasets in sidebar to add/remove from the chart.</p>
          </div>
        </div>
      </div>
    </div>
  );
}


