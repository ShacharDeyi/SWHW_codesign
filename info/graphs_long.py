import subprocess
import os
import sys
from pathlib import Path

if len(sys.argv) < 2:
    print("Usage: python run_benchmark_flamegraph.py <benchmark_name>")
    sys.exit(1)

# === CONFIGURATION ===
BENCHMARK = sys.argv[1]
RESULTS_DIR = Path("results")
FLAMEGRAPH_DIR = Path("../../FlameGraph")
FLAMEGRAPH_OUT = RESULTS_DIR / f"flamegraph_{BENCHMARK}.svg"
PERF_DATA = RESULTS_DIR / "perf.data"
PERF_SCRIPT_OUT = RESULTS_DIR / "out.folded"
STAT_OUTPUT = RESULTS_DIR / f"output_{BENCHMARK}.txt"
PERF_REPORT = RESULTS_DIR / f"./perf_report_{BENCHMARK}.txt"

# === SETUP ===
RESULTS_DIR.mkdir(parents=True, exist_ok=True)

def run_command(command, output_file=None):
    print(f"▶️ Running: {' '.join(command)}")
    if output_file:
        with open(output_file, "w") as out:
            subprocess.run(command, stdout=out, stderr=subprocess.STDOUT, check=True)
    else:
        subprocess.run(command, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT, check=True)

try:
    # 1. perf stat (cache misses, references)
    run_command(
        ["perf", "stat", "-e", "cache-misses,cache-references,cycles,instructions", "--", "python3-dbg", "-m", "pyperformance", "run", "--bench", BENCHMARK],
        STAT_OUTPUT
    )

    # 2. perf record
    run_command(
        ["perf", "record", "-F", "999", "-g", "--call-graph", "dwarf", "-o", str(PERF_DATA), "--",
        "python3-dbg", "-m", "pyperformance", "run", "--bench", BENCHMARK]
    )


    # 2.5. perf report --stdio
    with open(PERF_REPORT, "w") as report_out:
        subprocess.run(["perf", "report", "--stdio", "-i", str(PERF_DATA)], stdout=report_out)
        
    # 3. perf script -> out.folded
    perf_script = subprocess.Popen(["perf", "script", "-i", str(PERF_DATA)], stdout=subprocess.PIPE)
    collapse = subprocess.Popen(
        [str(FLAMEGRAPH_DIR / "stackcollapse-perf.pl")],
        stdin=perf_script.stdout,
        stdout=open(PERF_SCRIPT_OUT, "w")
    )
    collapse.communicate()

    # 4. flamegraph.pl -> flamegraph_<benchmark>.svg
    with open(FLAMEGRAPH_OUT, "w") as svg_out:
        subprocess.run(
            [str(FLAMEGRAPH_DIR / "flamegraph.pl"), str(PERF_SCRIPT_OUT)],
            stdout=svg_out,
            check=True
        )

    print(f"\n✅ Done!\n- Flamegraph: {FLAMEGRAPH_OUT}\n- Stats: {STAT_OUTPUT}")

except subprocess.CalledProcessError as e:
    print(f"❌ Command failed: {e}")
