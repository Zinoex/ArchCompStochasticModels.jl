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
    
    function nominal(x, u)
        x_next = zeros(n_integrators)
        for i in 1:n_integrators
            x_next[i] = x[i]
            for j in i + 1:n_integrators
                x_next[i] += parameters["sampling_time"]^(j - i) * x[j] / factorial(j - i)
            end
        end

        for i in 1:n_integrators
            x_next[i] += parameters["sampling_time"]^(n_integrators - i + 1) / factorial(n_integrators - i + 1) * u[1]
        end

        return x_next
    end

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
    spec = ExactTimeReachAvoidSpecification(safe_set, target_set, horizon)
    spec = ProbabilityGreaterThanInitialConditionSpecification(spec, system.parameters["alpha"])
    spec = ControllerSynthesisSpecification(maximize, spec)

    prob = BenchmarkProblem("integrator_chain_($(n_integators))_exact_time_reachavoid", system, spec)

    return prob
end