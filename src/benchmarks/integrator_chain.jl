"""
Integrator-Chain Benchmark

## Mathematical Model
For a system of ``n`` integrators, the state-space model is given by
```math
    x_i[k + 1] &= x_i[k] + \\sum_{j = i + 1}^n \\frac{\\tau^{j - 1}}{(j - 1)!} x_j[k] + \\frac{\\tau^{n - i + 1}}{(n - i + 1)!} + w_i[k]
```
where ``\\tau`` is the sampling time and ``w_i[k]`` is the process noise.
"""
function integrator_chain(n_integrators)
    parameters = Dict{String, Any}(
        "sampling_time" => 0.1  # [s]
    )
    
    function nominal(x, u)
        x_next = zeros(n_integrators)
        for i in 1:n_integrators
            x_next[i] = x[i]
            for j in i + 1:n_integrators
                x_next[i] += parameters["sampling_time"] * x[j] / factorial(j - 1)
            end
        end
        return x_next
    end

    σ = [0.01 for i in 1:n_integrators]

    Tx = DiagonalGaussianKernel(nominal, σ)

    X = Universe(n_integrators)
    U = LazySets.Interval(-1.0, 1.0)

    system = DiscreteTimeStochasticSystem(X, U, Tx)

    return system
end