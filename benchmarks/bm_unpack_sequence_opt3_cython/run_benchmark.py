import pyperf
from unpacking import do_unpacking_cython

def do_unpacking(loops, to_unpack):
    range_it = range(loops)
    t0 = pyperf.perf_counter()
    do_unpacking_cython(loops, to_unpack)
    return pyperf.perf_counter() - t0


def bench_tuple_unpacking(loops):
    x = tuple(range(10))
    return do_unpacking(loops, x)

def bench_list_unpacking(loops):
    x = list(range(10))
    return do_unpacking(loops, x)


def bench_all(loops):
    return do_unpacking(loops, tuple(range(10))) + do_unpacking(loops, list(range(10)))


def add_cmdline_args(cmd, args):
    if args.benchmark:
        cmd.append(args.benchmark)


if __name__ == "__main__":
    benchmarks = {"tuple": bench_tuple_unpacking,
                  "list": bench_list_unpacking}

    runner = pyperf.Runner(add_cmdline_args=add_cmdline_args)
    runner.metadata['description'] = ("Microbenchmark for "
                                      "Python's sequence unpacking.")

    runner.argparser.add_argument("benchmark", nargs="?", choices=sorted(benchmarks))

    options = runner.parse_args()
    name = 'unpack_sequence'
    if options.benchmark:
        func = benchmarks[options.benchmark]
        name += "_%s" % options.benchmark
    else:
        func = bench_all

    runner.bench_time_func(name, func, inner_loops=400)
