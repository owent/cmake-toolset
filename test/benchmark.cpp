#include <atomic>

#include <benchmark/benchmark.h>

static void BM_SomeFunction(benchmark::State& state) {
  std::atomic<int> a;
  ++a;
}
// Register the function as a benchmark
BENCHMARK(BM_SomeFunction);
// Run the benchmark
BENCHMARK_MAIN();
