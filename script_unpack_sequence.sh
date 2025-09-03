#!/bin/bash

#copy files
git clone https://github.com/brendangregg/FlameGraph.git
cp SWHW_codesign/trash.cpp ./trash.cpp
cp -r SWHW_codesign/benchmarks/bm_unpack_sequence* benchmarks/
cp SWHW_codesign/benchmarks/MANIFEST benchmarks/

# List of benchmarks to run
BENCHES=(
    unpack_sequence
    unpack_sequence_opt1
    unpack_sequence_opt2
    unpack_sequence_opt3_cython
)

# Perf sample rate tuning
echo 100000 > /proc/sys/kernel/perf_event_max_sample_rate

# Compile trash
g++ -O2 -std=c++17 trash.cpp -o trash

#install cython
pip install --upgrade pip setuptools wheel
pip install cython

for NAME in "${BENCHES[@]}"; do
    echo "==============================================="
    echo "[*] Running benchmark: $NAME"
    echo "==============================================="

    RESULTS_DIR="results_${NAME}"

    # Create results directory
    mkdir -p "$RESULTS_DIR"

    echo "[*] Running perf stat..."
    ./trash
    perf stat -r 10 -e task-clock,context-switches,page-faults,cache-references,cache-misses,cycles,instructions \
        python3-dbg -m pyperformance run --bench ${NAME} 2>&1 | tee "${RESULTS_DIR}/stats_${NAME}.txt"
    
    echo "[*] Running perf record..."
    ./trash
    perf record -F 999 -g -- python3-dbg -m pyperformance run --bench ${NAME}
    perf report --stdio > "${RESULTS_DIR}/report_${NAME}.txt"
    perf script | ./FlameGraph/stackcollapse-perf.pl > "${RESULTS_DIR}/out.folded"

    echo "[*] Generating flamegraph..."
    ./FlameGraph/flamegraph.pl "${RESULTS_DIR}/out.folded" > "${RESULTS_DIR}/flamegraph_${NAME}.svg"

    echo "[+] Done with ${NAME}! Results in $RESULTS_DIR"
    echo
done

echo "[✓] All benchmarks finished!"

