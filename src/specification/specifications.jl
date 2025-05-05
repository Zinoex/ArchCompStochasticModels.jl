
abstract type BenchmarkSpecification end
abstract type BenchmarkProperty <: BenchmarkSpecification end

struct FiniteTimeReachAvoidSpecification{S, T} <: BenchmarkProperty
    avoid_set::S
    target_set::T
    N::Int
end

struct InfiniteTimeReachAvoidSpecification{S, T} <: BenchmarkProperty
    avoid_set::S
    target_set::T
    convergence_threshold::Float64
end

struct FirstHittingTimeReachAvoidSpecification{S, T} <: BenchmarkProperty
    avoid_set::S
    target_set::T
end

struct FiniteTimeSafetySpecification{S} <: BenchmarkProperty
    safe_set::S
    N::Int
end

struct ExactTimeReachAvoidSpecification{S, T} <: BenchmarkProperty
    avoid_set::S
    target_set::T
    N::Int
end

struct BuchiSpecification{S} <: BenchmarkProperty
    sets::Dict{String, LazySet}
    formula::String
    # TODO: Test validity of the formula
end

@enum SynthesisMode minimize maximize

struct ControllerSynthesisSpecification{S <: BenchmarkSpecification} <: BenchmarkSpecification
    synthesis_mode::SynthesisMode
    underlying_spec::S
end

struct ProbabilityOneInitialConditionSpecification{S <: BenchmarkProperty} <: BenchmarkSpecification
    underlying_prop::S
end

struct ProbabilityGreaterThanInitialConditionSpecification{S <: BenchmarkProperty} <: BenchmarkSpecification
    underlying_prop::S
    threshold::Float64
end