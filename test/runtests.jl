using ArchCompStochasticModels
using Test

@testset verbose = true "ArchCompStochasticModels.jl" begin
    @testset verbose = true "benchmarks" include("benchmarks/benchmarks.jl")
end
