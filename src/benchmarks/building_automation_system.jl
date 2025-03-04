"""

"""
function cs1_bas()
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

    function mean(x, u)
        return A * x + B * u + Q
    end

    Tx = DiagonalGaussianKernel(mean, M)

    X = Universe(4)
    U = Interval(15.0, 22.0)

    system = DiscreteTimeStochasticSystem(X, U, Tx)

    safe_set = CartesianProduct(
        Hyperrectangle(low=[19.5, 19.5], high=[20.5, 20.5]),
        Universe(2)
    )
    time_horizon = 6
    spec = ControllerSynthesisSpecification(
        maximize,
        FiniteTimeSafetySpecification(safe_set, time_horizon)
    )

    prob = BenchmarkProblem("cs1_bas", system, spec)

    return prob
end

function cs2_bas()
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
    ]

    Bw = [
        0.0    0.0    1.9381e-4 0.0       7.924e-4 0.0
        0.0    0.0    0.0       5.7769e-6 0.0      6.094e-4
        0.0084 0.0    0.0       0.0       0.0      0.0
        0.0074 0.0    0.0       0.0       0.0      0.0
        0.0    0.0073 0.0       0.0       0.0      0.0
        0.0    0.0066 0.0       0.0       0.0      0.0
        0.0    0.0    0.0       0.0       0.0      0.0
    ]
end