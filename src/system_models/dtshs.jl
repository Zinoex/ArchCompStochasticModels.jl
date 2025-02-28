using LazySets, StaticArrays

"""
    DiscreteTimeSwitchedHybridSystem{N, P, F, G, H, T, S}

A discrete-time switched hybrid system is a tuple ``H = (\\mathcal{Q}, n, \\mathcal{U}, \\Sigma, T_x, T_q, R)`` where:
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
3. If ``q_{k+1} = q_k``, then extract the continuous state evolution as ``x_{k + 1} \\sim T_x(\\cdot \\mid s_k, u_k)``;
4. If ``q_{k+1} \\neq q_k``, then extract the continuous state evolution as ``x_{k + 1} \\sim R(\\cdot \\mid s_k, \\sigma_k, q_{k+1})``;

!!! warning
    The transition and reset control space are assumed to be compact but it is not enforced in the type definition.

"""
struct DiscreteTimeSwitchedHybridSystem{M, U <: LazySet, S <: LazySet, TX, TQ, TR} <: AbstractBenchmarkSystem
    cont_dims::SVector{M, Int}
    transition_control_space::U
    reset_control_space::S
    continuous_transition_kernel::TX
    discrete_transition_kernel::TQ
    reset_transition_kernel::TR
    parameters::Dict{String, Any}
end

### Accessors
num_discrete_modes(::DiscreteTimeSwitchedHybridSystem{M}) where {M} = M
num_continuous_dims(H::DiscreteTimeSwitchedHybridSystem, q) = H.cont_dims[q]
transition_control_space(H::DiscreteTimeSwitchedHybridSystem) = H.transition_control_space
reset_control_space(H::DiscreteTimeSwitchedHybridSystem) = H.reset_control_space
continuous_transition_kernel(H::DiscreteTimeSwitchedHybridSystem) = H.continuous_transition_kernel
discrete_transition_kernel(H::DiscreteTimeSwitchedHybridSystem) = H.discrete_transition_kernel
reset_transition_kernel(H::DiscreteTimeSwitchedHybridSystem) = H.reset_transition_kernel

### Characteristics of the system
same_dim_all_modes(H::DiscreteTimeSwitchedHybridSystem) = all(H.cont_dims .== H.cont_dims[1])
