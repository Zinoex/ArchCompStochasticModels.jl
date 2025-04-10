using PDMats

"""
Building Automation System 2D Benchmark

A building automation system (BAS) with two zones, each heated by one radiator and with a shared air supply.

First presented in Abate, A., Blom, H., Cauchi, N., Hartmanns, A., Lesser, K., Oishi, M., ... & Vinod, A. P. (2018). ARCH-COMP19 category report: Stochastic modelling. In 5th International Workshop on Applied Verification of Continuous and Hybrid Systems, ARCH 2018 (pp. 71-103). EasyChair.
Concrete values taken from Abate, A., Blom, H., Cauchi, N., Degiorgio, K., Fraenzle, M., Hahn, E. M., ... & Vinod, A. P. (2019). ARCH-COMP19 category report: Stochastic modelling. In 6th International Workshop on Applied Verification of Continuous and Hybrid Systems, ARCH 2019 (pp. 62-102). EasyChair.

## Mathematical Model
```math
\\begin{aligned}
    x[k + 1] &= A x[k] + B u[k] + Q + B_w w[k]\\\\
    y[k] &= \\begin{bmatrix} 1 & 0 & 0 & 0 \\\\ 0 & 1 & 0 & 0 \\end{bmatrix} x[k]
\\end{aligned}
```
"""
function cs1_bas()
    parameters = Dict{String, Any}()

    A = [
        0.6682  0.0     0.02632    0.0
        0.0     0.6830  0.0        0.02096
        1.0005  0.0     -0.000499  0.0
        0.0     0.8004  0.0        0.1996
    ]

    B = [
        0.1320
        0.1402
        0.0
        0.0
    ][:, :]


    Q = [
        3.3378
        2.9272
        13.0207
        10.4166
    ]

    M = [0.0774, 0.0774, 0.3872, 0.3098]

    # A * x + B * u + Q
    mean = Affine2(A, B, Q)

    Tx = DiagonalGaussianKernel(mean, M)

    X = Universe(4)
    U = Interval(15.0, 22.0)

    system = DiscreteTimeStochasticSystem(parameters, X, U, Tx)

    return system
end

function cs1_bas_finite_time_safety()
    system = cs1_bas()

    safe_set = CartesianProduct(
        Hyperrectangle(low=[19.5, 19.5], high=[20.5, 20.5]),
        Universe(2)
    )
    time_horizon = 6
    spec = ControllerSynthesisSpecification(
        maximize,
        FiniteTimeSafetySpecification(safe_set, time_horizon)
    )

    prob = BenchmarkProblem("cs1_bas_finite_time_safety", system, spec)

    return prob
end

"""
Building Automation System 7D Benchmark

A building automation system (BAS).

First presented in Abate, A., Blom, H., Cauchi, N., Hartmanns, A., Lesser, K., Oishi, M., ... & Vinod, A. P. (2018). ARCH-COMP19 category report: Stochastic modelling. In 5th International Workshop on Applied Verification of Continuous and Hybrid Systems, ARCH 2018 (pp. 71-103). EasyChair.

```math
\\begin{aligned}
    x[k + 1] &= A x[k] + B u[k] + Q + B_w w[k]\\\\
    y[k] &= \\begin{bmatrix} 1 & 0 & 0 & 0 & 0 & 0 & 0 \\end{bmatrix} x[k]
\\end{aligned}
```
"""
function cs2_bas()
    parameters = Dict{String, Any}()

    A = [
        0.9678 0.0    0.0036 0.0    0.0036 0.0    0.0036
        0.0    0.9682 0.0    0.0034 0.0    0.0034 0.0034
        0.0106 0.0    0.9494 0.0    0.0    0.0    0.0
        0.0    0.0097 0.0    0.9523 0.0    0.0    0.0
        0.0106 0.0    0.0    0.0    0.9494 0.0    0.0
        0.0    0.0097 0.0    0.0    0.0    0.9523 0.0
        0.0106 0.0097 0.0    0.0    0.0    0.0    0.9794
    ]

    B = [
        0.0195
        0.0200
        0.0
        0.0
        0.0
        0.0
        0.0
    ][:, :]

    Bw = [
        0.0    0.0    1.9381e-4 0.0       7.924e-4 0.0
        0.0    0.0    0.0       5.7769e-6 0.0      6.094e-4
        0.0084 0.0    0.0       0.0       0.0      0.0
        0.0074 0.0    0.0       0.0       0.0      0.0
        0.0    0.0073 0.0       0.0       0.0      0.0
        0.0    0.0066 0.0       0.0       0.0      0.0
        0.0    0.0    0.0       0.0       0.0      0.0
    ]

    Q = [
        0.0493
        -0.0055
        0.0387
        0.0189
        0.011
        0.0108
        0.0109
    ]

    μ = [9.0, 15.0, 500.0, 500.0, 35.0, 35.0]
    Σ = PDiagMat([1.0, 1.0, 100.0, 100.0, 5.0, 5.0])  # Positive definite diagonal matrix

    # Relying on the linear transformation theorem for multi-variate normal distributions.
    # https://statproofbook.github.io/P/mvn-ltt.html
    transformed_μ = Bw * μ
    transformed_Σ = Bw * Σ * Bw'

    # A * x + B * u + Q + transformed_μ
    mean = Affine2(A, B, Q + transformed_μ)

    Tx = GaussianKernel(mean, transformed_Σ)

    X = Universe(7)
    U = Interval(15.0, 22.0)

    system = DiscreteTimeStochasticSystem(parameters, X, U, Tx)

    return system
end

function cs2_bas_finite_time_safety()
    system = cs2_bas()

    safe_set = CartesianProduct(
        Hyperrectangle(low=[19.5, 19.5], high=[20.5, 20.5]),
        Universe(6)
    )
    time_horizon = 6
    spec = ControllerSynthesisSpecification(
        maximize,
        FiniteTimeSafetySpecification(safe_set, time_horizon)
    )

    prob = BenchmarkProblem("cs2_bas_finite_time_safety", system, spec)

    return prob
end