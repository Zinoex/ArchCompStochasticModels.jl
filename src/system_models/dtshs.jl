using LazySets, StaticArrays

"""
    DiscreteTimeStochasticHybridSystem

A discrete-time stochastic hybrid system in the style of [1] is a tuple ``H = (\\mathcal{Q}, n, \\mathcal{U}, \\Sigma, T_x, T_q, R)`` where:
- ``\\mathcal{Q} = \\{q_1, q_2, \\ldots, q_m\\}`` is a finite set of discrete modes;
- ``n : \\mathcal{Q} \\to \\mathbb{N}`` is the number of continuous dimensions in each mode.
    The hybrid state space is defined as ``\\mathcal{S} = \\bigcup_{q \\in \\mathcal{Q}} \\{q\\} \\times \\mathbb{R}^{n(q)}``;
- ``\\mathcal{U}`` is a compact Borel space representing the transition control space;
- ``\\Sigma`` is a compact Borel space representing the reset control space;
- ``T_x : \\mathcal{B}(\\mathbb{R}^{n(\\cdot)}) \\times \\mathcal{S} \\times \\mathcal{U} \\to [0, 1]`` is the continuous transition kernel;
- ``T_q : \\mathcal{Q} \\times \\mathcal{S} \\times \\mathcal{U} \\to [0, 1]`` is the discrete transition kernel, and
- ``R : \\mathcal{B}(\\mathbb{R}^{n(\\cdot)}) \\times \\mathcal{S} \\times \\Sigma \\times \\mathcal{Q} \\to [0, 1]`` is the reset transition kernel.

Given a Markov policy ``\\mu : \\mathcal{S} \\to \\mathcal{U} \\times \\Sigma``, 
the system that evolves according to the following at each time step ``k`` with state ``s_k = (q_k, x_k)``:

1. Let ``u_k, \\sigma_k = \\mu(s_k)``;
2. Extract the (potential) mode transition ``q_{k+1} \\sim T_q(\\cdot \\mid s_k, u_k)``;
3. If ``q_{k+1} = q_k``, then extract the continuous state evolution as ``x_{k + 1} \\sim T_x(\\cdot \\mid s_k, u_k)``, and
4. If ``q_{k+1} \\neq q_k``, then extract the continuous state evolution as ``x_{k + 1} \\sim R(\\cdot \\mid s_k, \\sigma_k, q_{k+1})``.

!!! warning
    The transition and reset control space are assumed to be compact but it is not enforced in the type definition.


## Fields


## Example
```julia

```

[1] Abate, A., Prandini, M., Lygeros, J., & Sastry, S. (2008). Probabilistic reachability and safety for controlled discrete time stochastic hybrid systems. Automatica, 44(11), 2724-2734.

"""
struct DiscreteTimeStochasticHybridSystem{M, 
    U <: LazySet,
    TQ <: DiscreteTransitionKernel,
    TX <: ContinuousTransitionKernel,
    S <: OrNothing{<:LazySet},
    TR <: OrNothing{<:ContinuousTransitionKernel}
    } <: AbstractBenchmarkSystem
    parameters::Dict{String, Any}
    cont_dims::SVector{M, Int}
    transition_control_space::U
    discrete_transition_kernel::TQ
    continuous_transition_kernel::TX
    reset_control_space::S
    reset_transition_kernel::TR
end

function DiscreteTimeStochasticHybridSystem(
    parameters::Dict{String, Any},
    cont_dims::SVector{M, Int}, 
    transition_control_space::U,
    discrete_transition_kernel::TQ,
    continuous_transition_kernel::TX
    ) where {M, U <: LazySet, TQ <: DiscreteTransitionKernel, TX <: ContinuousTransitionKernel}
    
    if !all_modes_same_dim(cont_dims)
        throw(ArgumentError("All modes must have the same number of continuous dimensions"))
    end

    return DiscreteTimeStochasticHybridSystem(parameters, cont_dims, transition_control_space, discrete_transition_kernel, continuous_transition_kernel, nothing, nothing)
end

### Accessors
num_discrete_modes(::DiscreteTimeStochasticHybridSystem{M}) where {M} = M
num_continuous_dims(H::DiscreteTimeStochasticHybridSystem, q) = H.cont_dims[q]
transition_control_space(H::DiscreteTimeStochasticHybridSystem) = H.transition_control_space
reset_control_space(H::DiscreteTimeStochasticHybridSystem) = H.reset_control_space
continuous_transition_kernel(H::DiscreteTimeStochasticHybridSystem) = H.continuous_transition_kernel
discrete_transition_kernel(H::DiscreteTimeStochasticHybridSystem) = H.discrete_transition_kernel
reset_transition_kernel(H::DiscreteTimeStochasticHybridSystem) = H.reset_transition_kernel

### Characteristics of the system
all_modes_same_dim(H::DiscreteTimeStochasticHybridSystem) = all_modes_same_dim(H.cont_dims)
all_modes_same_dim(cont_dims::SVector{M, Int}) where {M} = all(cont_dims .== cont_dims[1])