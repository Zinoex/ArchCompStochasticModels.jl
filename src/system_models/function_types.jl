export AbstractFunction, AbstractAffineFunction, AbstractLinearFunction,
       AbstractSmoothFunction, AbstractCompositeFunction,
       Linear1, Linear2, Affine1, Affine2, Smooth1, Smooth2,
       Discrete1, Parallel2, Parallel3

abstract type AbstractFunction end
abstract type AbstractAffineFunction <: AbstractFunction end
abstract type AbstractLinearFunction <: AbstractFunction end
abstract type AbstractSmoothFunction <: AbstractFunction end
abstract type AbstractDiscreteFunction end
abstract type AbstractCompositeFunction <: AbstractFunction end

struct Linear1{T, MT <: AbstractMatrix} <: AbstractLinearFunction
    A::MT
end
(f::Linear1)(x) = f.A * x

struct Linear2{T, MT1 <: AbstractMatrix, MT2 <: AbstractMatrix} <: AbstractLinearFunction
    A::MT1
    B::MT2
end
(f::Linear2)(x, u) = f.A * x + f.B * u

struct Affine1{T, MT <: AbstractMatrix, VT <: AbstractVector} <: AbstractAffineFunction
    A::MT
    b::VT
end
(f::Affine1)(x) = f.A * x + f.b

struct Affine2{T, MT1 <: AbstractMatrix, MT2 <: AbstractMatrix, VT <: AbstractVector} <: AbstractAffineFunction
    A::MT1
    B::MT2
    b::VT
end
(f::Affine2)(x, u) = f.A * x + f.B * u + f.b

struct Smooth1{F <: Function} <: AbstractSmoothFunction
    func::F
end
(f::Smooth1)(x) = f.func(x)

struct Smooth2{F <: Function} <: AbstractSmoothFunction
    func::F
end
(f::Smooth2)(x, u) = f.func(x, u)

struct Discrete1{F <: AbstractFunction} <: AbstractDiscreteFunction
    func::F
end
(f::Discrete1)(x) = f.func(x)

struct Parallel2{F1 <: AbstractFunction, F2 <: AbstractFunction} <: AbstractCompositeFunction
    func1::F1
    func2::F2
end
(f::Parallel2)(x, u) = f.func1(x) + f.func2(u)

struct Parallel3{F1 <: AbstractFunction, F2 <: AbstractFunction, F3 <: AbstractFunction} <: AbstractCompositeFunction
    func1::F1
    func2::F2
    func3::F3
end
(f::Parallel2)(x, u, q) = f.func1(x) + f.func2(u) + f.func3(q)
