"""
Integrator-Chain Benchmark

## Mathematical Model
For a system of ``n`` integrators, the state-space model is given by
```math
    x_i[k + 1] = x_i[k] + \\sum_{j = i + 1}^n \\frac{\\tau^{j - i}}{(j - i)!} x_j[k] + \\frac{\\tau^{n - i + 1}}{(n - i + 1)!} u[k] + w_i[k]
```
where ``\\tau`` is the sampling time and ``w_i[k] \\sim \\mathcal{N}(0, 0.01)`` is the process noise.
"""
function integrator_chain(n_integrators)
    parameters = Dict{String, Any}(
        "sampling_time" => 0.1,  # [s]
        "alpha" => 0.01          # (0, 1) probability threshold
    )
    
    # A * x + B * u
    A = zeros(n_integrators, n_integrators)
    for i in 1:n_integrators
        A[i, i] = 1.0
        for j in i + 1:n_integrators
            A[i, j] = parameters["sampling_time"]^(j - i) / factorial(j - i)
        end
    end
    B = zeros(n_integrators, 1)
    for i in 1:n_integrators
        B[i, 1] = parameters["sampling_time"]^(n_integrators - i + 1) / factorial(n_integrators - i + 1)
    end

    nominal = Linear2(A, B)

    σ = [0.01 for i in 1:n_integrators]

    Tx = DiagonalGaussianKernel(nominal, σ)

    X = Universe(n_integrators)
    U = LazySets.Interval(-1.0, 1.0)

    system = DiscreteTimeStochasticSystem(parameters, X, U, Tx)

    return system
end

function integrator_chain_exact_time_reachavoid(n_integrators)
    system = integrator_chain(n_integrators)

    safe_set = Hyperrectangle(low=[-10.0 for i in 1:n_integrators], high=[10.0 for i in 1:n_integrators])
    target_set = Hyperrectangle(low=[-8.0 for i in 1:n_integrators], high=[8.0 for i in 1:n_integrators])

    horizon = 5
    spec = ExactTimeReachAvoidSpecification(Complement(safe_set), target_set, horizon)
    spec = ControllerSynthesisSpecification(maximize, spec)
    spec = ProbabilityGreaterThanInitialConditionSpecification(spec, system.parameters["alpha"])

    prob = BenchmarkProblem("integrator_chain_($n_integrators)_exact_time_reachavoid", system, spec)

    return prob
end