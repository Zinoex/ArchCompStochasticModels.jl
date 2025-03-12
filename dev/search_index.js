var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = ArchCompStochasticModels","category":"page"},{"location":"#ArchCompStochasticModels","page":"Home","title":"ArchCompStochasticModels","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ArchCompStochasticModels.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ArchCompStochasticModels]","category":"page"},{"location":"#ArchCompStochasticModels.DiscreteTimeStochasticHybridSystem","page":"Home","title":"ArchCompStochasticModels.DiscreteTimeStochasticHybridSystem","text":"DiscreteTimeStochasticHybridSystem\n\nA discrete-time stochastic hybrid system in the style of [1] is a tuple H = (mathcalQ n mathcalU Sigma T_x T_q R) where:\n\nmathcalQ = q_1 q_2 ldots q_m is a finite set of discrete modes;\nn  mathcalQ to mathbbN is the number of continuous dimensions in each mode.   The hybrid state space is defined as mathcalS = bigcup_q in mathcalQ q times mathbbR^n(q);\nmathcalU is a compact Borel space representing the transition control space;\nSigma is a compact Borel space representing the reset control space;\nT_x  mathcalB(mathbbR^n(cdot)) times mathcalS times mathcalU to 0 1 is the continuous transition kernel;\nT_q  mathcalQ times mathcalS times mathcalU to 0 1 is the discrete transition kernel, and\nR  mathcalB(mathbbR^n(cdot)) times mathcalS times Sigma times mathcalQ to 0 1 is the reset transition kernel.\n\nGiven a Markov policy mu  mathcalS to mathcalU times Sigma,  the system that evolves according to the following at each time step k with state s_k = (q_k x_k):\n\nLet u_k sigma_k = mu(s_k);\nExtract the (potential) mode transition q_k+1 sim T_q(cdot mid s_k u_k);\nIf q_k+1 = q_k, then extract the continuous state evolution as x_k + 1 sim T_x(cdot mid s_k u_k), and\nIf q_k+1 neq q_k, then extract the continuous state evolution as x_k + 1 sim R(cdot mid s_k sigma_k q_k+1).\n\nwarning: Warning\nThe transition and reset control space are assumed to be compact but it is not enforced in the type definition.\n\nFields\n\nExample\n\n\n\n[1] Abate, A., Prandini, M., Lygeros, J., & Sastry, S. (2008). Probabilistic reachability and safety for controlled discrete time stochastic hybrid systems. Automatica, 44(11), 2724-2734.\n\n\n\n\n\n","category":"type"},{"location":"#ArchCompStochasticModels.DiscreteTimeStochasticSystem","page":"Home","title":"ArchCompStochasticModels.DiscreteTimeStochasticSystem","text":"DiscreteTimeStochasticSystem\n\nA discrete-time stochastic system is a tuple H = (mathcalX mathcalU T_x) where:\n\nmathcalX subseteq mathbbR^n is the state space;\nmathcalU is a compact Borel space representing the control space, and\nT_x  mathcalB(mathbbR^n(cdot)) times mathcalX times mathcalU to 0 1 is the continuous transition kernel.\n\nGiven a Markov policy mu  mathcalX to mathcalU, the system that evolves according to the following at each time step k:\n\nLet u_k = mu(x_k), and\nExtract the continuous state evolution as x_k + 1 sim T_x(cdot mid x_k u_k).\n\nwarning: Warning\nThe control space are assumed to be compact but it is not enforced in the type definition.\n\nFields\n\nExample\n\n\n\n\n\n\n\n","category":"type"},{"location":"#ArchCompStochasticModels.automated_anaesthesia-Tuple{}","page":"Home","title":"ArchCompStochasticModels.automated_anaesthesia","text":"Automated Anaesthesia Delievery System Benchmark\n\nThe concentration of Propofol in different compartments of the body are modelled using the three-compartment pharmacokinetic system. An automated system controls the basal dosage of Propofol to the patient, while an aneasthesiologist can administer a bolus dose. The system model includes a stochastic model of the aneasthesiologist behavior based on the concentration and the number of bolus doses administered. The hybrid system behavior arises from this aneasthesiologist behavior.\n\nFirst presented in Abate, A., Blom, H., Cauchi, N., Hartmanns, A., Lesser, K., Oishi, M., ... & Vinod, A. P. (2018). ARCH-COMP19 category report: Stochastic modelling. In 5th International Workshop on Applied Verification of Continuous and Hybrid Systems, ARCH 2018 (pp. 71-103). EasyChair.\n\nMathematical Model\n\nbeginaligned\n    barxk + 1 = beginbmatrix 08192  003412  001265  001646  09822  00001  00009  000002  09989 endbmatrix barxk + beginbmatrix 001883  00002  000001 endbmatrix (vk + sigmak) + wk \n                    = A barxk + B (vk + sigmak) + wk\nendaligned\n\nwhere barxk is the continuous state vector, vk is the automated delivery system control input, wk sim mathcalN(0 M) is the process noise, and sigmak is the noise from the aneasthesiologist. sigmak is a semi-Markov random variable taking values in 0 30 that represents the aneasthesiologist's decision to administer a bolus dose. To make the stochastic system Markovian, a binary state vector qk is introduced that represents the aneasthesiologist's decision to administer a bolus dose at time k. Then the stochastic decision to administer a bolus dose is conditioned on barx_1k and qk.\n\n\n\n\n\n","category":"method"},{"location":"#ArchCompStochasticModels.controlled_van_der_pol-Tuple{}","page":"Home","title":"ArchCompStochasticModels.controlled_van_der_pol","text":"Controlled Stochastic Van der Pol Oscillator Benchmark\n\nFirst presented in Alessandro, A., Henk, B., Nathalie, C., Joanna, D., Arnd, H., Mahmoud, K., ... & Zuliani, P. (2020). ARCH-COMP20 Category Report: Stochastic Models.\n\nMathematical Model\n\nbeginaligned\n    x_1k + 1 = x_1k + tau x_2k + wk\n    x_2k + 1 = x_2k + tau ((1 - x_1k^2) x_2k - x_1k) + uk wk\nendaligned\n\n\n\n\n\n","category":"method"},{"location":"#ArchCompStochasticModels.cs1_bas-Tuple{}","page":"Home","title":"ArchCompStochasticModels.cs1_bas","text":"Building Automation System 2D Benchmark\n\nA building automation system (BAS) with two zones, each heated by one radiator and with a shared air supply.\n\nFirst presented in Abate, A., Blom, H., Cauchi, N., Hartmanns, A., Lesser, K., Oishi, M., ... & Vinod, A. P. (2018). ARCH-COMP19 category report: Stochastic modelling. In 5th International Workshop on Applied Verification of Continuous and Hybrid Systems, ARCH 2018 (pp. 71-103). EasyChair. Concrete values taken from Abate, A., Blom, H., Cauchi, N., Degiorgio, K., Fraenzle, M., Hahn, E. M., ... & Vinod, A. P. (2019). ARCH-COMP19 category report: Stochastic modelling. In 6th International Workshop on Applied Verification of Continuous and Hybrid Systems, ARCH 2019 (pp. 62-102). EasyChair.\n\nMathematical Model\n\nbeginaligned\n    xk + 1 = A xk + B uk + Q + B_w wk\n    yk = beginbmatrix 1  0  0  0  0  1  0  0 endbmatrix xk\nendaligned\n\n\n\n\n\n","category":"method"},{"location":"#ArchCompStochasticModels.cs2_bas-Tuple{}","page":"Home","title":"ArchCompStochasticModels.cs2_bas","text":"Building Automation System 7D Benchmark\n\nA building automation system (BAS).\n\nFirst presented in Abate, A., Blom, H., Cauchi, N., Hartmanns, A., Lesser, K., Oishi, M., ... & Vinod, A. P. (2018). ARCH-COMP19 category report: Stochastic modelling. In 5th International Workshop on Applied Verification of Continuous and Hybrid Systems, ARCH 2018 (pp. 71-103). EasyChair.\n\nbeginaligned\n    xk + 1 = A xk + B uk + Q + B_w wk\n    yk = beginbmatrix 1  0  0  0  0  0  0 endbmatrix xk\nendaligned\n\n\n\n\n\n","category":"method"},{"location":"#ArchCompStochasticModels.fully_automated_anaesthesia-Tuple{}","page":"Home","title":"ArchCompStochasticModels.fully_automated_anaesthesia","text":"Fully-Automated Anaesthesia Delievery System Benchmark\n\nThe concentration of Propofol in different compartments of the body are modelled using the three-compartment pharmacokinetic system. An fully-automated system controls the dosage of Propofol to the patient.\n\nFirst presented in Abate, A., Blom, H., Cauchi, N., Hartmanns, A., Lesser, K., Oishi, M., ... & Vinod, A. P. (2018). ARCH-COMP19 category report: Stochastic modelling. In 5th International Workshop on Applied Verification of Continuous and Hybrid Systems, ARCH 2018 (pp. 71-103). EasyChair.\n\nMathematical Model\n\nbeginaligned\n    barxk + 1 = beginbmatrix 08192  003412  001265  001646  09822  00001  00009  000002  09989 endbmatrix barxk + beginbmatrix 001883  00002  000001 endbmatrix vk + wk \n                    = A barxk + B vk + wk\nendaligned\n\nwhere barxk is the continuous state vector, vk is the automated delivery system control input, and wk sim mathcalN(0 M) is the process noise.\n\n\n\n\n\n","category":"method"},{"location":"#ArchCompStochasticModels.integrator_chain-Tuple{Any}","page":"Home","title":"ArchCompStochasticModels.integrator_chain","text":"Integrator-Chain Benchmark\n\nMathematical Model\n\nFor a system of n integrators, the state-space model is given by\n\n    x_ik + 1 = x_ik + sum_j = i + 1^n fractau^j - i(j - i) x_jk + fractau^n - i + 1(n - i + 1) uk + w_ik\n\nwhere tau is the sampling time and w_ik sim mathcalN(0 001) is the process noise.\n\n\n\n\n\n","category":"method"},{"location":"#ArchCompStochasticModels.van_der_pol-Tuple{}","page":"Home","title":"ArchCompStochasticModels.van_der_pol","text":"Stochastic Van der Pol Oscillator Benchmark\n\nFirst presented in Alessandro, A., Henk, B., Nathalie, C., Joanna, D., Arnd, H., Mahmoud, K., ... & Zuliani, P. (2020). ARCH-COMP20 Category Report: Stochastic Models.\n\nMathematical Model\n\nbeginaligned\n    x_1k + 1 = x_1k + tau x_2k + wk\n    x_2k + 1 = x_2k + tau ((1 - x_1k^2) x_2k - x_1k) + wk\nendaligned\n\n\n\n\n\n","category":"method"}]
}
