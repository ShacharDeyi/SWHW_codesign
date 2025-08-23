#!/bin/bash

# List of benchmarks to run
BENCHES=(
    unpack_sequence
    unpack_sequence_opt1
    unpack_sequence_opt2
    unpack_sequence_opt3_cython
    json_dumps
    json_dumps_opt1
    json_dumps_opt2_ujson
    json_dumps_opt3_orjson
)

# Perf sample rate tuning
echo 100000 > /proc/sys/kernel/perf_event_max_sample_rate

for NAME in "${BENCHES[@]}"; do
    echo "==============================================="
    echo "[*] Running benchmark: $NAME"
    echo "==============================================="

    RESULTS_DIR="results_${NAME}"
    FILE="${RESULTS_DIR}/stats_${NAME}.txt"

    # Create results directory
    mkdir -p "$RESULTS_DIR"

    # Redirect output to both console & file
    exec > >(tee -a "$FILE") 2>&1

    echo "[*] Running perf stat..."
    ./trash
    perf stat -r 10 -e task-clock,context-switches,page-faults,cache-references,cache-misses,cycles,instructions \
        python3-dbg -m pyperformance run --bench ${NAME} > "$FILE"

    echo "[*] Running perf record..."
    ./trash
    perf record -F 999 -g -- python3-dbg -m pyperformance run --bench ${NAME} >> "$FILE"
    perf report --stdio >> "${RESULTS_DIR}/report_${NAME}.txt"
    perf script | ../FlameGraph/stackcollapse-perf.pl > "${RESULTS_DIR}/out.folded"

    echo "[*] Generating flamegraph..."
    ../FlameGraph/flamegraph.pl "${RESULTS_DIR}/out.folded" > "${RESULTS_DIR}/flamegraph_${NAME}.svg"

    echo "[+] Done with ${NAME}! Results in $RESULTS_DIR"
    echo
done

echo "[✓] All benchmarks finished!"
