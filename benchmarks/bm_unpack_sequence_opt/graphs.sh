#!/bin/bash

# Exit if no argument is given
if [ $# -lt 1 ]; then
    echo "Usage: $0 <name>"
    exit 1
fi

echo 100000 > /proc/sys/kernel/perf_event_max_sample_rate
NAME=$1
exec > >(tee -a "stats_${NAME}.txt") 2>&1

echo "[*] Running perf stat..."
perf stat -e task-clock,context-switches,page-faults,cache-references,cache-misses,cycles,instructions \
    python3-dbg run_benchmark.py > stats_${NAME}.txt

echo "[*] Running perf record..."
perf record -F 999 -a -g -- python3-dbg run_benchmark.py >> stats_${NAME}.txt
perf report --stdio >> report_${NAME}.txt
perf script | ../../../../../FlameGraph/stackcollapse-perf.pl > out.folded

echo "[*] Generating flamegraph..."
../../../../../FlameGraph/flamegraph.pl out.folded > flamegraph_${NAME}.svg

echo "[+] Done! Logs saved in stats_${NAME}.txt"
echo "[+] Flamegraph generated: flamegraph_${NAME}.svg"
