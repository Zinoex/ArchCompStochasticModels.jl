
abstract type ContinuousTransitionKernel end

abstract type AbstractGaussianKernel <: ContinuousTransitionKernel end

struct GaussianKernel{M, C} <: AbstractGaussianKernel
    mean::M
    covariance::C
end

struct DiagonalGaussianKernel{M, V} <: AbstractGaussianKernel
    mean::M
    variance::V
end

struct RectangularUniformKernel{C, S} <: ContinuousTransitionKernel
    center::C
    support::S
end

struct PiecewiseContinuousKernel{T <: Tuple{<:LazySet, ContinuousTransitionKernel}} <: ContinuousTransitionKernel
    regions::Vector{T}
end