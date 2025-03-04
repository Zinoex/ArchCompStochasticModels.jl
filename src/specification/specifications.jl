
abstract type BenchmarkSpecification end
abstract type BenchmarkProperty <: BenchmarkSpecification end

struct FiniteTimeReachAvoidSpecification{S, T} <: BenchmarkProperty
    avoid_set::S
    target_set::T
    N::Int
end

struct FirstHittingTimeReachAvoidSpecification{S, T} <: BenchmarkProperty
    avoid_set::S
    target_set::T
end

@enum SynthesisMode minimize maximize

struct ControllerSynthesisSpecification{S <: BenchmarkProperty} <: BenchmarkSpecification
    synthesis_mode::SynthesisMode
    underlying_spec::S
end