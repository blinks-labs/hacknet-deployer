#!/usr/bin/env python3
import argparse
import csv
import os
import re
from datetime import datetime, timezone


RECV_PREFIX_RE = re.compile(r"^(?P<recv_iso>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z) \| proxy=(?P<proxy>[^ ]+) \| topic=(?P<topic>[^ ]+) \| ")
HEADER_JSON_RE = re.compile(r"\{\"id\":\"(?P<msg_id>[^\"]+)\",\\?\"ts\\?\":\"(?P<publish_iso>[^\"]+)\"\}\::")
# Also match mump2p debug format with nanosecond timestamps
DEBUG_RECV_RE = re.compile(r"Recv:\s+\[(?P<seq>\d+)\].*\[recv_time,\s*size\]:\[(?P<recv_ns>\d+),\s*\d+\]\s*sender_addr:(?P<sender>[^\s]+)\s*\[send_time,\s*size\]:\[(?P<send_ns>\d+),\s*\d+\]\s*topic:(?P<topic>\S+)\s*hash:(?P<hash>\S+)")


def parse_iso8601_z(iso_str: str) -> datetime:
    # Supports millisecond precision like 2025-01-01T00:00:00.123Z
    if iso_str.endswith("Z") and "." in iso_str:
        return datetime.strptime(iso_str, "%Y-%m-%dT%H:%M:%S.%fZ").replace(tzinfo=timezone.utc)
    if iso_str.endswith("Z"):
        return datetime.strptime(iso_str, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
    # Fallback
    return datetime.fromisoformat(iso_str.replace("Z", "+00:00"))


def process_log(input_path: str, output_csv: str) -> None:
    rows = []
    with open(input_path, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.rstrip("\n")
            
            # Try mump2p debug format first (nanosecond timestamps)
            m_debug = DEBUG_RECV_RE.search(line)
            if m_debug:
                recv_ns = int(m_debug.group("recv_ns"))
                send_ns = int(m_debug.group("send_ns"))
                latency_ms = (recv_ns - send_ns) / 1_000_000.0
                rows.append({
                    "id": f"msg_{m_debug.group('seq')}",
                    "publish_ts": str(send_ns),
                    "receive_ts": str(recv_ns),
                    "latency_ms": f"{latency_ms:.3f}",
                    "proxy": m_debug.group("sender"),
                    "topic": m_debug.group("topic"),
                    "line_len": len(line),
                })
                continue
            
            # Try our custom format (ISO timestamps + JSON header)
            m1 = RECV_PREFIX_RE.match(line)
            if not m1:
                continue
            recv_iso = m1.group("recv_iso")
            proxy = m1.group("proxy")
            topic = m1.group("topic")
            rest = line[m1.end():]
            m2 = HEADER_JSON_RE.search(rest)
            if not m2:
                continue
            msg_id = m2.group("msg_id")
            publish_iso = m2.group("publish_iso")
            try:
                recv_ts = parse_iso8601_z(recv_iso)
                pub_ts = parse_iso8601_z(publish_iso)
                latency_ms = (recv_ts - pub_ts).total_seconds() * 1000.0
            except Exception:
                continue
            rows.append({
                "id": msg_id,
                "publish_ts": publish_iso,
                "receive_ts": recv_iso,
                "latency_ms": f"{latency_ms:.3f}",
                "proxy": proxy,
                "topic": topic,
                "line_len": len(line),
            })

    os.makedirs(os.path.dirname(output_csv) or ".", exist_ok=True)
    with open(output_csv, "w", newline="", encoding="utf-8") as out:
        writer = csv.DictWriter(out, fieldnames=[
            "id", "publish_ts", "receive_ts", "latency_ms", "proxy", "topic", "line_len"
        ])
        writer.writeheader()
        for r in rows:
            writer.writerow(r)

    # Print basic percentiles for quick view
    if rows:
        latencies = sorted(float(r["latency_ms"]) for r in rows)
        def p(pct: float) -> float:
            if not latencies:
                return float("nan")
            k = max(0, min(len(latencies)-1, int(round((pct/100.0)*(len(latencies)-1)))))
            return latencies[k]
        print(f"count={len(latencies)} p50={p(50):.2f}ms p90={p(90):.2f}ms p99={p(99):.2f}ms max={latencies[-1]:.2f}ms")
    else:
        print("No messages parsed from log.")


def main():
    ap = argparse.ArgumentParser(description="Parse mump2p subscriber logs to latency CSV")
    ap.add_argument("input_log", help="Path to logs/subscriber_*.log")
    ap.add_argument("output_csv", nargs="?", help="Output CSV path", default="results/latency.csv")
    args = ap.parse_args()
    process_log(args.input_log, args.output_csv)


if __name__ == "__main__":
    main()


