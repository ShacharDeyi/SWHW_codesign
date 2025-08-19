#!/bin/bash

# Exit if no argument is given
if [ $# -lt 1 ]; then
    echo "Usage: $0 <name>"
    exit 1
fi

echo 100000 > /proc/sys/kernel/perf_event_max_sample_rate
NAME=$1
RESULTS_DIR="results_${NAME}"
FILE="${RESULTS_DIR}/stats_${NAME}.txt"

# Create results directory
mkdir -p "$RESULTS_DIR"

exec > >(tee -a "$FILE") 2>&1

echo "[*] Running perf stat..."
perf stat -e task-clock,context-switches,page-faults,cache-references,cache-misses,cycles,instructions \
    python3-dbg -m pyperformance run --bench ${NAME} > "$FILE"

echo "[*] Running perf record..."
perf record -F 999 -g -- python3-dbg -m pyperformance run --bench ${NAME} >> "$FILE"
perf report --stdio >> "${RESULTS_DIR}/report_${NAME}.txt"
perf script | ../FlameGraph/stackcollapse-perf.pl > "${RESULTS_DIR}/out.folded"

echo "[*] Generating flamegraph..."
../FlameGraph/flamegraph.pl "${RESULTS_DIR}/out.folded" > "${RESULTS_DIR}/flamegraph_${NAME}.svg"

echo "[+] Done! Logs saved in $FILE"
echo "[+] Flamegraph generated: ${RESULTS_DIR}/flamegraph_${NAME}.svg"
