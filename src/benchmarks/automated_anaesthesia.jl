function automated_anaesthesia()
    parameters = Dict(
        "k_10" => 0.4436, 
        "k_12" => 0.1140,
        "k_13" => 0.0419,
        "k_21" => 0.0550,
        "k_31" => 0.0033,
        "V" => 16.044,
        "Ts" => 20.00,  # [s]
        "bolus_dose_rate" => 30.0,  # [mg/min]
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
    ]

    function mean(q, x, u)
        return A * x + B_u * (u + parameters["bolus_dose_rate"] * (q == 1))
    end

    M = [1e-3, 1e-3, 1e-3]

    Tx = DiagonalGaussianKernel(mean, M)

    # Discrete transition kernel
    A_q = [

    ]
end