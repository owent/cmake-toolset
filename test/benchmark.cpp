// Copyright 2021 atframework

#include <benchmark/benchmark.h>

#include <atomic>

static void BM_SomeFunction(benchmark::State& state) {
  // Test for benchmark_main
  std::atomic<int> a;
  ++a;
}
// Register the function as a benchmark
BENCHMARK(BM_SomeFunction);
// Run the benchmark
BENCHMARK_MAIN();
