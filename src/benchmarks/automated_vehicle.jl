
"""
Automated Vehicle

First presented in Alessandro, A., Henk, B., Nathalie, C., Joanna, D., Arnd, H., Mahmoud, K., ... & Zuliani, P. (2020). ARCH-COMP20 Category Report: Stochastic Models.
TODO: Update to relevant paper

## Mathematical Model
TODO: Add mathematical model
"""
function automated_vehicle()
    parameters = Dict{String, Any}(
        "sampling_time" => 0.1,       # [s]
        "wheelbase" => 2.5789,        # [m]
        "friction" => 1.0489,
        "mass" => 1093.3,             # [kg]
        "front_distance" => 1.156,    # [m]
        "rear_distance" => 1.422,     # [m]
        "cog_height" => 0.6137,       # [m]
        "moment_inertia" => 1791.6,   # [kg m^2]
        "front_stiffness" => 20.89,   # [1/rad]
        "rear_stiffness" => 20.89,    # [1/rad]
        "gravity" => 9.82,            # [m/s^2]
        "acceleration_limit" => 11.5, # [m/s^2]
        "steering_rate_limit" => 0.4, # [rad/s]
    )
    total_length = parameters["front_distance"] + parameters["rear_distance"]
    
    function small_velocity_mean(x, u)
        a1 = x[4] * cos(x[5])
        a2 = x[4] * sin(x[5])
        a3 = clamp(u[1], -parameters["steering_rate_limit"], parameters["steering_rate_limit"])
        a4 = clamp(u[2], -parameters["acceleration_limit"], parameters["acceleration_limit"])
        a5 = (x[4] / parameters["wheelbase"]) * tan(x[3])
        a6 = (u[2] / parameters["wheelbase"]) * tan(x[3]) + (x[4] / (parameters["wheelbase"] * cos(x[3])^2)) * u[1] 
        a7 = 0

        a = [a1, a2, a3, a4, a5, a6, a7]

        return x .+ parameters["sampling_time"] * a
    end
    m = Smooth2(small_velocity_mean)
    
    # Variance, not std.dev.
    M = [0.25, 0.25, 0.2, 0.1, 0.2, 0.2, 0.2] .^ 2

    Tx1 = DiagonalGaussianKernel(m, M)
    region1 = Universe(3) × Interval(-0.1, 0.1) × Universe(3)

    function high_velocity_mean(x, u)
        b1 = x[4] * cos(x[5] + x[7])
        b2 = x[4] * sin(x[5] + x[7])
        b3 = clamp(u[1], -parameters["steering_rate_limit"], parameters["steering_rate_limit"])
        b4 = clamp(u[2], -parameters["acceleration_limit"], parameters["acceleration_limit"])
        b5 = x[6]
        b6 = (parameters["friction"] * parameters["mass"] / (parameters["moment_inertia"] * total_length)) * (
            parameters["front_distance"] * parameters["front_stiffness"] * (parameters["gravity"] * parameters["rear_distance"] − u[2] * parameters["height"]) * x[3] +
            (
                parameters["rear_distance"] * parameters["rear_stiffness"] * (parameters["gravity"] * parameters["front_distance"] + u[2] * parameters["height"]) - 
                parameters["front_distance"] * parameters["front_stiffness"] * (parameters["gravity"] * parameters["rear_distance"] − u[2] * parameters["height"])
            ) * x[7] -
            (
                parameters["front_distance"]^2 * parameters["front_stiffness"] * (parameters["gravity"] * parameters["rear_distance"] - u[2] * parameters["height"]) +
                parameters["rear_distance"]^2 * parameters["rear_stiffness"] * (parameters["gravity"] * parameters["front_distance"] + u[2] * parameters["height"])
            ) * x[6] / x[4]
        )
        b7 = parameters["friction"] / (x[4] * total_length) * (
            parameters["front_stiffness"] * (parameters["gravity"] * parameters["rear_distance"] − u[2] * parameters["height"]) * x[3] +
            (
                parameters["rear_stiffness"] * (parameters["gravity"] * parameters["front_distance"] + u[2] * parameters["height"]) +
                parameters["front_stiffness"] * (parameters["gravity"] * parameters["rear_distance"] − u[2] * parameters["height"])
            ) * x[7] -
            (
                parameters["front_distance"] * parameters["front_stiffness"] * (parameters["gravity"] * parameters["rear_distance"] - u[2] * parameters["height"]) -
                parameters["rear_distance"] * parameters["rear_stiffness"] * (parameters["gravity"] * parameters["front_distance"] + u[2] * parameters["height"])
            ) * x[6] / x[4]
        ) - x[6]

        b = [b1, b2, b3, b4, b5, b6, b7]

        return x .+ parameters["sampling_time"] * b
    end
    m = Smooth2(high_velocity_mean)

    Tx23 = DiagonalGaussianKernel(m, M)
    
    # x[4] <= -0.1 ⟺ -x[4] >= 0.1
    # [0, 0, 0, -1, 0, 0, 0] * x >= 0.1
    region2 = HalfSpace([0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0], 0.1)

    # x[4] >= 0.1
    # [0, 0, 0, 1, 0, 0, 0] * x >= 0.1
    region3 = HalfSpace([0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0], 0.1)

    Tx = PiecewiseContinuousKernel([
        (region1, Tx1),
        (region2, Tx23),
        (region3, Tx23)
    ])

    X = Hyperrectangle(; low=[-10.0, -10.0, -0.4, -2.0, -0.3, -0.4, -0.04], high=[10.0, 10.0, 0.4, 2.0, 0.3, 0.4, 0.04])
    U = Hyperrectangle(; low=[-0.4, -4.0], high=[0.4, 4.0])

    system = DiscreteTimeStochasticSystem(parameters, X, U, Tx)

    return system
end

function automated_vehicle_finite_time_ra()
    system = automated_vehicle()

    reach = Hyperrectangle(; low=[−1.5, 0.0], high=[0.0, 1.5]) × Universe(5)
    avoid = Hyperrectangle(; low=[-1.5, -0.5], high=[0.0, 0.0]) × Universe(5)

    ra_spec = FiniteTimeReachAvoidSpecification(reach, avoid, 32)
    spec = ControllerSynthesisSpecification(maximize, ra_spec)

    prob = BenchmarkProblem("automated_vehicle_finite_time_ra", system, spec)

    return prob
end