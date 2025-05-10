using LazySets, StaticArrays

"""
    DiscreteTimeStochasticSystem

A discrete-time stochastic system is a tuple ``H = (\\mathcal{X}, \\mathcal{U}, T_x)`` where:
- ``\\mathcal{X} \\subseteq \\mathbb{R}^n`` is the state space;
- ``\\mathcal{U}`` is a compact Borel space representing the control space, and
- ``T_x : \\mathcal{B}(\\mathbb{R}^{n(\\cdot)}) \\times \\mathcal{X} \\times \\mathcal{U} \\to [0, 1]`` is the continuous transition kernel.

Given a Markov policy ``\\mu : \\mathcal{X} \\to \\mathcal{U}``, the system that evolves according to the following
at each time step ``k``:

1. Let ``u_k = \\mu(x_k)``, and
2. Extract the continuous state evolution as ``x_{k + 1} \\sim T_x(\\cdot \\mid x_k, u_k)``.

!!! warning
    The control space is assumed to be compact but it is not enforced in the type definition.


## Fields


## Example
```julia

```

"""
struct DiscreteTimeStochasticSystem{
    X <: LazySet,
    U <: LazySet,
    TX <: ContinuousTransitionKernel
    } <: AbstractBenchmarkSystem
    parameters::Dict{String, Any}
    state_space::X
    control_space::U
    transition_kernel::TX
end

### Accessors
num_continuous_dims(H::DiscreteTimeStochasticSystem) = LazySets.dim(H.state_space)
control_space(H::DiscreteTimeStochasticSystem) = H.control_space
transition_kernel(H::DiscreteTimeStochasticSystem) = H.transition_kernel



"""
    DiscreteTimeStochasticDisturbanceSystem

A discrete-time stochastic system is a tuple ``H = (\\mathcal{X}, \\mathcal{U}, \\mathcal{W}, T_x)`` where:
- ``\\mathcal{X} \\subseteq \\mathbb{R}^n`` is the state space;
- ``\\mathcal{U}`` is a compact Borel space representing the control space;
- ``\\mathcal{W}`` is a compact Borel space representing the disturbance space; and
- ``T_x : \\mathcal{B}(\\mathbb{R}^{n(\\cdot)}) \\times \\mathcal{X} \\times \\mathcal{U} \\times \\mathcal{W} \\to [0, 1]`` is the continuous transition kernel.

Given a Markov policy ``\\mu : \\mathcal{X} \\to \\mathcal{U}`` and a disturbance adversary ``\\nu : \\mathcal{X} \\times \\mathcal{U} \\to \\mathcal{W},
the system that evolves according to the following at each time step ``k``:

1. Let ``u_k = \\mu(x_k)`` and ``w_k = \\nu(x_k, u_k)``, and
2. Extract the continuous state evolution as ``x_{k + 1} \\sim T_x(\\cdot \\mid x_k, u_k, w_k)``.

!!! warning
    The control and disturbance spaces are assumed to be compact but it is not enforced in the type definition.

!!! note
    The disturbance adversary is not given and the result should be robust to any disturbance adversary.

## Fields


## Example
```julia

```

"""
struct DiscreteTimeStochasticDisturbanceSystem{
    X <: LazySet,
    U <: LazySet,
    W <: LazySet,
    TX <: ContinuousTransitionKernel
    } <: AbstractBenchmarkSystem
    parameters::Dict{String, Any}
    state_space::X
    control_space::U
    disturbance_space::W
    transition_kernel::TX
end

### Accessors
num_continuous_dims(H::DiscreteTimeStochasticDisturbanceSystem) = LazySets.dim(H.state_space)
control_space(H::DiscreteTimeStochasticDisturbanceSystem) = H.control_space
disturbance_space(H::DiscreteTimeStochasticDisturbanceSystem) = H.disturbance_space
transition_kernel(H::DiscreteTimeStochasticDisturbanceSystem) = H.transition_kernel