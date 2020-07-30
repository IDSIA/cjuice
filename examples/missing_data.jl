using LogicCircuits, LinearAlgebra, Plots, Pkg
Pkg.activate(".")
using ProbabilisticCircuits

function learner(data :: PlainXData{Bool,BitArray{2}} , ess :: Float64)
    # Learning PSDD and CSDD
    psdd = learn_struct_prob_circuit(data; pseudocount = ess)[1]
    csdd = learn_struct_credal_circuit(WXData(data), ess)[1]
    spn = learn_probabilistic_circuit(data; pseudocount = ess)
    cspn =learn_credal_circuit(WXData(data), ess)
    @show length(psdd), length(csdd)
    @show length(spn), length(cspn)
    return true
end

#for db in twenty_dataset_names # ["nltcs"]
db = "nltcs"
@show db
ess = 1.0
threshold = 0.1
dataSet=dataset(twenty_datasets(db); do_shuffle=false, batch_size=-1)

learner(dataSet.train,ess)
dataSetMissing = add_missingness(dataSet.train, threshold)
csdd = learn_struct_credal_circuit(WXData(dataSet.train), ess)[1]

n = 16
@show log_marginal_lower(csdd, PlainXData(convert.(Int8, -ones(n,n) + 2*I)))

sdd = load_logical_circuit("examples/random.sdd")
@show typeof(sdd),length(sdd)
