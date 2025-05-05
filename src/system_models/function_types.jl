export AbstractFunction, AbstractAffineFunction, AbstractLinearFunction,
       AbstractSmoothFunction, AbstractCompositeFunction,
       Linear1, Linear2, Affine1, Affine2, Smooth1, Smooth2,
       Discrete1, Parallel2, Parallel3

abstract type AbstractFunction end
abstract type AbstractAffineFunction <: AbstractFunction end
abstract type AbstractLinearFunction <: AbstractFunction end
abstract type AbstractSmoothFunction <: AbstractFunction end
abstract type AbstractDiscreteFunction <: AbstractFunction end
abstract type AbstractCompositeFunction <: AbstractFunction end

struct Linear1{M <: AbstractMatrix} <: AbstractLinearFunction
    A::M
end
(f::Linear1)(x) = f.A * x

struct Linear2{M1 <: AbstractMatrix, M2 <: AbstractMatrix} <: AbstractLinearFunction
    A::M1
    B::M2
end
(f::Linear2)(x, u) = f.A * x + f.B * u

struct Affine1{M <: AbstractMatrix, V <: AbstractVector} <: AbstractAffineFunction
    A::M
    b::V
end
(f::Affine1)(x) = f.A * x + f.b

struct Affine2{M1 <: AbstractMatrix, M2 <: AbstractMatrix, V <: AbstractVector} <: AbstractAffineFunction
    A::M1
    B::M2
    c::V
end
(f::Affine2)(x, u) = f.A * x + f.B * u + f.c

struct Smooth1{F <: Function} <: AbstractSmoothFunction
    func::F
end
(f::Smooth1)(x) = f.func(x)

struct Smooth2{F <: Function} <: AbstractSmoothFunction
    func::F
end
(f::Smooth2)(x, u) = f.func(x, u)

struct Discrete1{F <: Function} <: AbstractDiscreteFunction
    func::F
end
(f::Discrete1)(q) = f.func(q)

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
