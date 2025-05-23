
abstract type BenchmarkSpecification end
abstract type BenchmarkProperty <: BenchmarkSpecification end

struct InfiniteTimeReachabilitySpecification{T} <: BenchmarkProperty
    target_set::T
    convergence_threshold::Float64
end

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

struct ExactTimeReachAvoidSpecification{S, T} <: BenchmarkProperty
    avoid_set::S
    target_set::T
    N::Int
end

struct FirstHittingTimeReachAvoidSpecification{S, T} <: BenchmarkProperty
    avoid_set::S
    target_set::T
end

struct FiniteTimeSafetySpecification{S} <: BenchmarkProperty
    safe_set::S
    N::Int
end

struct BuchiSpecification <: BenchmarkProperty
    sets::Dict{String, <:LazySet}
    formula::String
    # TODO: Test validity of the formula
end

@enum SynthesisMode minimize maximize

struct ControllerSynthesisSpecification{S <: BenchmarkProperty} <: BenchmarkSpecification
    synthesis_mode::SynthesisMode
    underlying_prop::S
end

struct ProbabilityOneInitialConditionSpecification{S <: BenchmarkSpecification} <: BenchmarkSpecification
    underlying_spec::S
end

struct ProbabilityGreaterThanInitialConditionSpecification{S <: BenchmarkSpecification} <: BenchmarkSpecification
    underlying_spec::S
    threshold::Float64
end