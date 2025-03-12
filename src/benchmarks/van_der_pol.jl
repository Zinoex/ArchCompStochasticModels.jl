"""
Stochastic Van der Pol Oscillator Benchmark

First presented in Alessandro, A., Henk, B., Nathalie, C., Joanna, D., Arnd, H., Mahmoud, K., ... & Zuliani, P. (2020). ARCH-COMP20 Category Report: Stochastic Models.

## Mathematical Model
```math
\\begin{aligned}
    x_1[k + 1] &= x_1[k] + \\tau x_2[k] + w[k]\\\\
    x_2[k + 1] &= x_2[k] + \\tau ((1 - x_1[k]^2) x_2[k] - x_1[k]) + w[k]
\\end{aligned}
```
"""
function van_der_pol()
    parameters = Dict{String, Any}(
        "sampling_time" => 0.1  # [s]
    )
    
    function center(x, u)
        return [
            x[1] + praameters["sampling_time"] * x[2],
            x[2] + parameters["sampling_time"] * ((1 - x[1]^2) * x[2] - x[1])
        ]
    end

    r = [0.02, 0.02]

    Tx = RectangularUniformKernel(center, r)

    X = Universe(2)
    U = Universe(0)

    system = DiscreteTimeStochasticSystem(X, U, Tx)

    return system
end

function van_der_pol_qualitative()
    system = van_der_pol()

    A = Hyperrectangle(low=[-5.0, -5.0], high=[5.0, 5.0])
    B = Hyperrectangle(low=[-1.2, -2.9], high=[-0.9, -2.0])

    sets = Dict("a" => A, "b" => B)
    formula = "G(a) & G(F(b))"
    buchi_spec = BuchiSpecification(sets, formula)
    spec = ProbabilityOneInitialConditionSpecification(buchi_spec)

    prob = BenchmarkProblem("van_der_pol_qualitative", system, spec)

    return prob
end

function van_der_pol_quantitative()
    system = van_der_pol()

    A = Hyperrectangle(low=[-5.0, -5.0], high=[5.0, 5.0])
    B = Hyperrectangle(low=[-1.2, -2.9], high=[-0.9, -2.0])

    sets = Dict("a" => A, "b" => B)
    formula = "G(a) & G(F(b))"
    spec = BuchiSpecification(sets, formula)

    prob = BenchmarkProblem("van_der_pol_quantitative", system, spec)

    return prob
end

"""
Controlled Stochastic Van der Pol Oscillator Benchmark

First presented in Alessandro, A., Henk, B., Nathalie, C., Joanna, D., Arnd, H., Mahmoud, K., ... & Zuliani, P. (2020). ARCH-COMP20 Category Report: Stochastic Models.

## Mathematical Model
```math
\\begin{aligned}
    x_1[k + 1] &= x_1[k] + \\tau x_2[k] + w[k]\\\\
    x_2[k + 1] &= x_2[k] + \\tau ((1 - x_1[k]^2) x_2[k] - x_1[k]) + u[k] w[k]
\\end{aligned}
```
"""
function controlled_van_der_pol()
    parameters = Dict{String, Any}(
        "sampling_time" => 0.1  # [s]
    )
    
    function center(x, u)
        return [
            x[1] + praameters["sampling_time"] * x[2],
            x[2] + parameters["sampling_time"] * ((1 - x[1]^2) * x[2] - x[1])
        ]
    end

    function radius(x, u)
        return [0.02, 0.02 * u]
    end

    Tx = RectangularUniformKernel(center, radius)

    X = Universe(2)
    U = Universe(1)

    system = DiscreteTimeStochasticSystem(X, U, Tx)

    return system
end

function controlled_van_der_pol_quantitative()
    system = van_der_pol()

    A = Hyperrectangle(low=[-5.0, -5.0], high=[5.0, 5.0])
    B = Hyperrectangle(low=[-1.2, -2.9], high=[-0.9, -2.0])

    sets = Dict("a" => A, "b" => B)
    formula = "G(a) & G(F(b))"
    buchi_spec = BuchiSpecification(sets, formula)
    spec = ControllerSynthesisSpecification(maximize, buchi_spec)

    prob = BenchmarkProblem("van_der_pol_quantitative", system, spec)

    return prob
end