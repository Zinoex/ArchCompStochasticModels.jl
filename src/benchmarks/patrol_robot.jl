
function reduced_patrol_robot_regions()
    target = Hyperrectangle(; low=[5.0, 5.0], high=[7.0, 7.0])
    avoid = Hyperrectangle(; low=[-2.0, -2.0], high=[2.0, 2.0])

    return target, avoid
end


function reduced_patrol_robot()
    parameters = Dict{String, Any}(
        "control_strength" => 10
    )

    function mean(x, u)
        return x + parameters["control_strength"] * u[1] * [
            cos(u[2]),
            sin(u[2])
        ]
    end

    variance = [0.75, 0.75]

    Tx = DiagonalGaussianKernel(Smooth2(mean), variance)

    state_space = Hyperrectangle(; low=[-10.0, -10.0], high=[10.0, 10.0])
    control_space = Hyperrectangle(; low=[-1.0, -1.0], high=[1.0, 1.0])

    system = DiscreteTimeStochasticSystem(
        parameters,
        state_space,
        control_space,
        Tx
    )

    return system
end

function reduced_patrol_robot_infinite_time_reach()
    system = reduced_patrol_robot()
    T, _ = reduced_patrol_robot_regions()

    ## Infinite time reachability specification
    convergence_threshold = 1e-6
    spec = ControllerSynthesisSpecification(maximize,
        InfiniteTimeReachabilitySpecification(T, convergence_threshold)
    )

    it_r_prob = BenchmarkProblem("reduced_patrol_robot_infinite_time_reach", system, spec)

    return it_r_prob
end

function reduced_patrol_robot_infinite_time_reachavoid()
    system = reduced_patrol_robot()
    T, A = reduced_patrol_robot_regions()

    ## Infinite time reachability specification
    convergence_threshold = 1e-6
    spec = ControllerSynthesisSpecification(maximize,
        InfiniteTimeReachAvoidSpecification(T, A, convergence_threshold)
    )

    it_r_prob = BenchmarkProblem("reduced_patrol_robot_infinite_time_reachavoid", system, spec)

    return it_r_prob
end

function reduced_patrol_robot_disturbance()
    parameters = Dict{String, Any}(
        "control_strength" => 10
    )

    function mean(x, u, w)
        return x + parameters["control_strength"] * u[1] * [
            cos(u[2]),
            sin(u[2])
        ] + w
    end

    Tx = DiagonalGaussianKernel(Smooth3(mean), variance)

    state_space = Hyperrectangle(; low=[-10.0, -10.0], high=[10.0, 10.0])
    control_space = Hyperrectangle(; low=[-1.0, -1.0], high=[1.0, 1.0])
    disturbance_space = Hyperrectangle(; low=[-0.5, -0.5], high=[0.5, 0.5])

    system = DiscreteTimeStochasticDisturbanceSystem(
        parameters,
        state_space,
        control_space,
        disturbance_space,
        Tx
    )

    return system
end

function reduced_patrol_robot_disturbance_infinite_time_reach()
    sys = reduced_patrol_robot_disturbance()
    T, _ = reduced_patrol_robot_regions()

    ## Infinite time reachability specification
    convergence_threshold = 1e-6
    spec = ControllerSynthesisSpecification(maximize,
        InfiniteTimeReachabilitySpecification(T, convergence_threshold)
    )

    it_r_prob = BenchmarkProblem("reduced_patrol_robot_disturbance_infinite_time_reach", system, spec)

    return it_r_prob
end

function reduced_patrol_robot_disturbance_infinite_time_reachavoid()
    sys = reduced_patrol_robot_disturbance()
    T, A = reduced_patrol_robot_regions()

    ## Infinite time reachability specification
    convergence_threshold = 1e-6
    spec = ControllerSynthesisSpecification(maximize,
        InfiniteTimeReachAvoidSpecification(T, A, convergence_threshold)
    )

    it_r_prob = BenchmarkProblem("reduced_patrol_robot_disturbance_infinite_time_reachavoid", system, spec)

    return it_r_prob
end