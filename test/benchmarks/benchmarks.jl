# Testing the individual benchmarks seem a little weird,
# but it is mostly to ensure that they instantiate properly.


benchmark_test_paths = ["automated_anaesthesia.jl", "building_automation_system.jl", "integrator_chain.jl", "van_der_pol.jl"]

for benchmark_test_path in benchmark_test_paths
    @testset verbose = true "benchmarks/$benchmark_test_path" include(benchmark_test_path)
end