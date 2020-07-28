using LogicCircuits
using LinearAlgebra
using Plots
import Pkg
Pkg.activate(".")
using ProbabilisticCircuits

const n_exp = 20        # Number of experiments
const ess = 1.0         # Equivalent sample size
const ess_max = 100.0   # Maximum perturbation for SA
const shuffling = false # Shuffling data

lik_spn = zeros(n_exp)
likl_cspn = zeros(n_exp)
liku_cspn = zeros(n_exp)
lik_psdd = zeros(n_exp)
likl_csdd = zeros(n_exp)
liku_csdd = zeros(n_exp)

# https://github.com/UCLA-StarAI/Density-Estimation-Datasets
for db in twenty_dataset_names # ["nltcs"]

    @show db

    # Training data set
    dataSet=dataset(twenty_datasets(db); do_shuffle=shuffling, batch_size=-1)
    dataTrain = dataSet.train

    # Learning PSDD and CSDD
    psdd = learn_struct_prob_circuit(dataTrain; pseudocount = ess)[1]
    csdd = learn_struct_credal_circuit(WXData(dataTrain), ess)[1]

    # Parsing the number of variables in the db
    matrixValid = convert.(Int8,dataSet.valid.x) # Bool2Int
    n = size(matrixValid)[2] # Number of variables in the db

    # Computing and plotting inferences
    x = 1:n
    p = log_proba(psdd, PlainXData(convert.(Int8, -ones(n,n) + 2*I)))
    l = log_marginal_lower(csdd, PlainXData(convert.(Int8, -ones(n,n) + 2*I)))
    u = log_marginal_upper(csdd, PlainXData(convert.(Int8, -ones(n,n) + 2*I)))
    f = log.(sum(matrixValid,dims=1)./size(matrixValid)[1])[1,:]
    plot(x,exp.(p), seriestype = :scatter, label="PSDD", lw=1)
    plot!(x,exp.(u), seriestype = :scatter, label="CSDD (upper)", lw=1)
    plot!(x,exp.(l), seriestype = :scatter, label="CSDD (lower)", lw=1)
    plot!(x,exp.(f), seriestype = :scatter, label="frequence", lw=1)
    savefig("./examples/marginals-$db.png")

    # Preparing data set
    dataValid = XData(matrixValid)
    matrixTrain_ = convert.(Int8, dataSet.train.x)

    # Loop over n_exp experiments with increasing training set size
    for k = 1:n_exp

        # Fist k slices (out of n_exp) of the training data
        matrixTrain_k = matrixTrain_[1:trunc(Int, (num_examples(dataTrain)/n_exp)*k),:]
        dataTrain_k= PlainXData(convert.(Bool,matrixTrain_k))

        # Learning the circuits (PSDD, SPN and their credal counterparts)
        psdd_k = learn_struct_prob_circuit(dataTrain_k; pseudocount = ess)[1]
        csdd_k =learn_struct_credal_circuit(WXData(dataTrain_k), ess)[1]
        spn_k = learn_probabilistic_circuit(dataTrain_k; pseudocount = ess)
        cspn_k =learn_credal_circuit(WXData(dataTrain_k), ess)

        # Computing db likelihood for each model
        likl_csdd[k] = sum(log_marginal_lower(csdd_k, dataValid))
        liku_csdd[k] = sum(log_marginal_upper(csdd_k, dataValid))
        lik_psdd[k] = sum(log_proba(psdd_k, dataValid))
        likl_cspn[k] = sum(log_marginal_lower(cspn_k, dataValid))
        liku_cspn[k] = sum(log_marginal_upper(cspn_k, dataValid))
        lik_spn[k] = sum(log_proba(spn_k, dataValid))

    end

    # Plotting the likelihoods
    x = 1:n_exp
    plot(x, lik_psdd, xticks=0:n_exp, ribbon =(lik_psdd-likl_csdd,liku_csdd-lik_psdd), title=uppercase(db), xlabel="Training set size",
    label ="PSDD", fillalpha=0.5, ylabel="Log-likelihood", lw=1)
    plot!(x, lik_spn,ribbon =(lik_spn-likl_cspn,liku_cspn-lik_spn),fillalpha=0.5,label ="SPN", lw=1)
    savefig("./examples/loglik-$db.png")

    # Learning credal circuits with increasing ESS
    for k = 1:n_exp
        ess2 = ess_max * k/n_exp
        csdd_k = learn_struct_credal_circuit(WXData(dataTrain), ess2)[1]
        cspn_k =learn_credal_circuit(WXData(dataTrain), ess2)
        likl_csdd[k] = sum(log_marginal_lower(csdd_k, dataValid))
        liku_csdd[k] = sum(log_marginal_upper(csdd_k, dataValid))
        likl_cspn[k] = sum(log_marginal_lower(cspn_k, dataValid))
        liku_cspn[k] = sum(log_marginal_upper(cspn_k, dataValid))
    end

    # Plotting
    plot(x, likl_csdd, xticks=0:n_exp, title=uppercase(db), xlabel="Perturbation level (s)",
    label ="CSDD (lower)", ylabel="Log-likelihood", lw=1)
    plot!(x, liku_csdd, xticks=0:n_exp, title=uppercase(db),label ="CSDD (upper)", lw=1)
    plot!(x, likl_cspn, xticks=0:n_exp, title=uppercase(db),label ="CSPN (lower)", lw=1)
    plot!(x, liku_cspn, xticks=0:n_exp, title=uppercase(db),label ="CSPN (upper)", lw=1)
    savefig("./examples/sensitivity-$db.png")

end
