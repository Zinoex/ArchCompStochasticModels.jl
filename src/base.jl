
struct BenchmarkProblem{S <: AbstractBenchmarkSystem}
    name::String
    system::S
    specification::BenchmarkSpecification
end