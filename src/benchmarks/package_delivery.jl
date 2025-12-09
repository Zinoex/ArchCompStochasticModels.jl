function package_delivery_regions()
    p1 = Hyperrectangle(; low = [5.0, -1.0], high = [6.0, 1.0]) # [5,6]x[-1, 1]
    p2 = Hyperrectangle(; low = [0.0, -5.0], high = [1.0, 1.0]) # [0,1]x[-5, 1]
    p3 = Hyperrectangle(; low = [-4.0, -4.0], high = [-2.0, -3.0]) # [-4,-2]x[-4,-3]

    return p1, p2, p3
end

function pacakge_delivery()
    parameters = Dict{String,Any}()

    X = Hyperrectangle(; low = [-6.0, -6.0], high = [6.0, 6.0]) # X \in [-6, 6]x[-6, 6]
    U = Universe(2) # U \in R^2

    A = Diagonal([0.9, 0.8])
    B = Diagonal([1.4, 1.4])

    var = [0.2, 0.2]
    nominal = Linear2(A, B)
    Tx = DiagonalGaussianKernel(nominal, var)

    system = DiscreteTimeStochasticSystem(parameters, X, U, Tx)

    return system
end

function package_delivery_synthesis()
    system = pacakge_delivery()

    p1, p2, p3 = package_delivery_regions()

    sets = Dict("p1" => p1, "p2" => p2, "p3" => p3)
    formula = "F(p1 & (!p2 U p3))"
    scLTL_spec = scLTLSpecification(sets, formula)
    spec = ControllerSynthesisSpecification(maximize, scLTL_spec)

    prob = BenchmarkProblem("package_delivery_synthesis", system, spec)

    return prob
end


