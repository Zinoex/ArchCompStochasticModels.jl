function automated_anaesthesia_regions()
    safe = Hyperrectangle(low=[1.0, 0.0, 0.0], high=[6.0, 10.0, 10.0])
    reach = Hyperrectangle(low=[4.0, 8.0, 8.0], high=[6.0, 10.0, 10.0])

    return safe, reach
end

"""
Automated Anaesthesia Delievery System Benchmark

The concentration of Propofol in different compartments of the body are modelled using the three-compartment pharmacokinetic system.
An automated system controls the basal dosage of Propofol to the patient, while an aneasthesiologist can administer a bolus dose.
The system model includes a stochastic model of the aneasthesiologist behavior based on the concentration and the number of bolus
doses administered. The hybrid system behavior arises from this aneasthesiologist behavior.

First presented in Abate, A., Blom, H., Cauchi, N., Hartmanns, A., Lesser, K., Oishi, M., ... & Vinod, A. P. (2018). ARCH-COMP18 category report: Stochastic modelling. In 5th International Workshop on Applied Verification of Continuous and Hybrid Systems, ARCH 2018 (pp. 71-103). EasyChair.

## Mathematical Model
```math
\\begin{aligned}
    \\bar{x}[k + 1] &= \\begin{bmatrix} 0.8192 & 0.03412 & 0.01265 \\\\ 0.01646 & 0.9822 & 0.0001 \\\\ 0.0009 & 0.00002 & 0.9989 \\end{bmatrix} \\bar{x}[k] + \\begin{bmatrix} 0.01883 \\\\ 0.0002 \\\\ 0.00001 \\end{bmatrix} (v[k] + \\sigma[k]) + w[k] \\\\
                    &= A \\bar{x}[k] + B (v[k] + \\sigma[k]) + w[k]
\\end{aligned}
```
where ``\\bar{x}[k]`` is the continuous state vector, ``v[k]`` is the automated delivery system control input, ``w[k] \\sim \\mathcal{N}(0, M)`` is the process noise, and ``\\sigma[k]`` is the noise from the aneasthesiologist.
``\\sigma[k]`` is a semi-Markov random variable taking values in ``\\{0, 30\\}`` that represents the aneasthesiologist's decision to administer a bolus dose.
To make the stochastic system Markovian, a binary state vector ``q[k]`` is introduced that represents the aneasthesiologist's decision to administer a bolus dose at time ``k``.
Then the stochastic decision to administer a bolus dose is conditioned on ``\\bar{x}_1[k]`` and ``q[k]``.
"""
function automated_anaesthesia()
    parameters = Dict{String, Any}(
        "k_10" => 0.4436, 
        "k_12" => 0.1140,
        "k_13" => 0.0419,
        "k_21" => 0.0550,
        "k_31" => 0.0033,
        "V" => 16.044,
        "Ts" => 20.00,  # [s]
        "bolus_dose_rate" => 30.0,  # [mg/min]
        "alpha" => 0.1,  # TODO: Find the correct value
        "noise_variance" => 5.0
    )
    parameters["bolus_dose"] = parameters["bolus_dose_rate"] / 60 * parameters["Ts"]  # [mg]
    
    # Continuous transition kernel
    A = [
        0.8192  0.03412 0.01265;
        0.01646 0.9822  0.0001;
        0.0009  0.00002 0.9989
    ]

    B_u = [
        0.01883
        0.0002
        0.00001
    ][:, :]

    U = Interval(0.0, 7.0)

    # A * x + B_u * (u + parameters["bolus_dose_rate"] * Int(q[1]))
    mean = Parallel2(
        Linear2(A, B_u),
        Discrete1(q -> B_u * parameters["bolus_dose_rate"] * Int(state2binary(q, 9)[1])),
    )

    M = fill(parameters["noise_variance"], 3)
    Tx = DiagonalGaussianKernel(mean, M)

    # Discrete transition kernel
    num_discrete_modes = 2^9

    α = parameters["alpha"]
    Tq_region1 = HalfSpace([1.0, 0.0, 0.0], α)  # z₁ ≤ α
    Tq_region1_matrix = spzeros(num_discrete_modes, num_discrete_modes)

    for j in 1:num_discrete_modes
        q = state2binary(j, 9)
        s = sum(q)
        
        # qp0 = [0, q[1:end-1]]
        qp0 = circshift(q, 1)
        qp0[1] = 0
        qp0 = binary2state(qp0)

        # qp1 = [1, q[1:end-1]]
        qp1 = circshift(q, 1)
        qp1[1] = 1
        qp1 = binary2state(qp1)

        if s == 0
            Tq_region1_matrix[qp0, j] = 0.1
            Tq_region1_matrix[qp1, j] = 0.9
        elseif s == 1
            Tq_region1_matrix[qp0, j] = 0.5
            Tq_region1_matrix[qp1, j] = 0.5
        else
            Tq_region1_matrix[qp0, j] = 1.0
        end
    end

    Tq_region2 = HalfSpace([-1.0, 0.0, 0.0], α) # z₁ > α
    Tq_region2_matrix = spzeros(num_discrete_modes, num_discrete_modes)

    for j in 1:num_discrete_modes
        q = state2binary(j, 9)
        s = sum(q)
        
        # qp0 = [0, q[1:end-1]]
        qp0 = circshift(q, 1)
        qp0[1] = 0
        qp0 = binary2state(qp0)

        # qp1 = [1, q[1:end-1]]
        qp1 = circshift(q, 1)
        qp1[1] = 1
        qp1 = binary2state(qp1)

        if s ≤ 1
            Tq_region1_matrix[qp0, j] = 0.05
            Tq_region1_matrix[qp1, j] = 0.95
        else
            Tq_region1_matrix[qp0, j] = 1.0
        end
    end

    Tq = RegionDependentSparseTransitionKernel([(Tq_region1, Tq_region1_matrix), (Tq_region2, Tq_region2_matrix)])

    cont_dims = @SVector fill(3, num_discrete_modes)
    system = DiscreteTimeStochasticHybridSystem(parameters, cont_dims, U, Tq, Tx)

    return system
end

function automated_anaesthesia_finite_time_safety()
    system = automated_anaesthesia()

    ## Finite time safety specification
    safe, reach = automated_anaesthesia_regions()
    time_horizon = 10
    spec = ControllerSynthesisSpecification(maximize,
        FiniteTimeSafetySpecification(safe, time_horizon)
    )

    ft_ra_prob = BenchmarkProblem("automated_anaesthesia_finite_time_safety", system, spec)

    return ft_ra_prob
end

function automated_anaesthesia_first_hitting_time_reachavoid()
    system = automated_anaesthesia()

    ## First hitting time reach-avoid specification
    safe, reach = automated_anaesthesia_regions()
    avoid = Complement(safe)
    spec = ControllerSynthesisSpecification(minimize,
        FirstHittingTimeReachAvoidSpecification(avoid, reach)
    )

    fht_ra_prob = BenchmarkProblem("automated_anaesthesia_first_hitting_time_reachavoid", system, spec)

    return fht_ra_prob
end


"""
Fully-Automated Anaesthesia Delievery System Benchmark

The concentration of Propofol in different compartments of the body are modelled using the three-compartment pharmacokinetic system.
An fully-automated system controls the dosage of Propofol to the patient.

First presented in Abate, A., Blom, H., Cauchi, N., Hartmanns, A., Lesser, K., Oishi, M., ... & Vinod, A. P. (2018). ARCH-COMP18 category report: Stochastic modelling. In 5th International Workshop on Applied Verification of Continuous and Hybrid Systems, ARCH 2018 (pp. 71-103). EasyChair.

## Mathematical Model
```math
\\begin{aligned}
    \\bar{x}[k + 1] &= \\begin{bmatrix} 0.8192 & 0.03412 & 0.01265 \\\\ 0.01646 & 0.9822 & 0.0001 \\\\ 0.0009 & 0.00002 & 0.9989 \\end{bmatrix} \\bar{x}[k] + \\begin{bmatrix} 0.01883 \\\\ 0.0002 \\\\ 0.00001 \\end{bmatrix} v[k] + w[k] \\\\
                    &= A \\bar{x}[k] + B v[k] + w[k]
\\end{aligned}
```
where ``\\bar{x}[k]`` is the continuous state vector, ``v[k]`` is the automated delivery system control input, and ``w[k] \\sim \\mathcal{N}(0, M)`` is the process noise.
"""
function fully_automated_anaesthesia()
    parameters = Dict{String, Any}(
        "k_10" => 0.4436, 
        "k_12" => 0.1140,
        "k_13" => 0.0419,
        "k_21" => 0.0550,
        "k_31" => 0.0033,
        "V" => 16.044,
        "Ts" => 20.00,  # [s]
        "bolus_dose_rate" => 30.0,  # [mg/min]
        "noise_variance" => 5.0
    )
    parameters["bolus_dose"] = parameters["bolus_dose_rate"] / 60 * parameters["Ts"]  # [mg]
    
    # Continuous transition kernel
    A = [
        0.8192  0.03412 0.01265;
        0.01646 0.9822  0.0001;
        0.0009  0.00002 0.9989
    ]

    B_u = [
        0.01883
        0.0002
        0.00001
    ][:, :]

    X = Universe(3)
    U = Interval(0.0, 7.0)

    # A * x + B_u * u
    mean = Linear2(A, B_u)

    M = fill(parameters["noise_variance"], 3)
    Tx = DiagonalGaussianKernel(mean, M)

    system = DiscreteTimeStochasticSystem(parameters, X, U, Tx)

    return system
end

function fully_automated_anaesthesia_finite_time_safety()
    system = fully_automated_anaesthesia()

    ## Finite time safety specification
    safe, reach = automated_anaesthesia_regions()
    time_horizon = 10
    spec = ControllerSynthesisSpecification(maximize,
        FiniteTimeSafetySpecification(safe, time_horizon)
    )

    ft_ra_prob = BenchmarkProblem("fully_automated_anaesthesia_finite_time_safety", system, spec)

    return ft_ra_prob
end

function fully_automated_anaesthesia_first_hitting_time_reachavoid()
    system = fully_automated_anaesthesia()

    ## First hitting time reach-avoid specification
    safe, reach = automated_anaesthesia_regions()
    avoid = Complement(safe)
    spec = ControllerSynthesisSpecification(minimize,
        FirstHittingTimeReachAvoidSpecification(avoid, reach)
    )

    fht_ra_prob = BenchmarkProblem("fully_automated_anaesthesia_first_hitting_time_reachavoid", system, spec)

    return fht_ra_prob
end