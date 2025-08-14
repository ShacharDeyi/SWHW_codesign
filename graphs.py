import subprocess
import sys
from pathlib import Path

# === PREDEFINED BENCHMARKS LIST ===
BENCHMARKS = [
    "crypto_pyaes",
    "deepcopy",
    "logging",
    "mdp",
    "pathlib",
    "pickle",
    "pickle_dict",
    "pyflate",
    "unpack_sequence",
    "json_dumps",
    "gc_collect",
]

RESULTS_DIR = Path("results")
FLAMEGRAPH_DIR = Path("../FlameGraph")

RESULTS_DIR.mkdir(parents=True, exist_ok=True)

def run_command(command, output_file=None):
    print(f"▶️ Running: {' '.join(command)}")
    if output_file:
        with open(output_file, "w") as out:
            subprocess.run(command, stdout=out, stderr=subprocess.STDOUT, check=True)
    else:
        subprocess.run(command, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT, check=True)

def run_benchmark(bench):
    print(f"\n🚀 Running benchmark: {bench}")

    flamegraph_out = RESULTS_DIR / f"flamegraph_{bench}.svg"
    perf_data = RESULTS_DIR / f"perf_{bench}.data"
    perf_script_out = RESULTS_DIR / f"out_{bench}.folded"
    stat_output = RESULTS_DIR / f"output_{bench}.txt"
    perf_report = RESULTS_DIR / f"perf_report_{bench}.txt"

    try:
        # 1. perf stat
        run_command(
            [
                "perf", "stat",
                "-e", "task-clock,context-switches,page-faults,cache-references,cache-misses,cycles,instructions",
                "--", "python3-dbg", "-m", "pyperformance", "run", "--bench", bench
            ],
            stat_output
        )

        # 2. perf record
        run_command(
            [
                "perf", "record", "-F", "999", "-g", "-o", str(perf_data),
                "--", "python3-dbg", "-m", "pyperformance", "run", "--bench", bench
            ]
        )

        # 2.5. perf report --stdio
        with open(perf_report, "w") as report_out:
            subprocess.run(["perf", "report", "--stdio", "-i", str(perf_data)], stdout=report_out)

        # 3. perf script -> out.folded
        perf_script = subprocess.Popen(["perf", "script", "-i", str(perf_data)], stdout=subprocess.PIPE)
        collapse = subprocess.Popen(
            [str(FLAMEGRAPH_DIR / "stackcollapse-perf.pl")],
            stdin=perf_script.stdout,
            stdout=open(perf_script_out, "w")
        )
        collapse.communicate()

        # 4. flamegraph.pl -> flamegraph_<benchmark>.svg
        with open(flamegraph_out, "w") as svg_out:
            subprocess.run(
                [str(FLAMEGRAPH_DIR / "flamegraph.pl"), str(perf_script_out)],
                stdout=svg_out,
                check=True
            )

        print(f"✅ Done {bench}\n   - Flamegraph: {flamegraph_out}\n   - Stats: {stat_output}")

    except subprocess.CalledProcessError as e:
        print(f"❌ Command failed for {bench}: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        bench_name = sys.argv[1]
        if bench_name not in BENCHMARKS:
            print(f"⚠ Warning: '{bench_name}' is not in the predefined list, running anyway...")
        run_benchmark(bench_name)
    else:
        for bench in BENCHMARKS:
            run_benchmark(bench)
