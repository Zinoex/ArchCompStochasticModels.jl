
abstract type TransitionKernel end


abstract type AbstractGaussianKernel end

struct GaussianKernel{M, C} <: AbstractGaussianKernel
    mean::M
    covariance::C
end

struct DiagonalGaussianKernel{M, V} <: AbstractGaussianKernel
    mean::M
    variance::V
end