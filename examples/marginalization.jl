# this assumes we have already installed LogicCircuits
using LogicCircuits
# Loads our local package
# We need to "activate" our local version first
import Pkg
# This assumes you are running the file from inside the Project's folder
Pkg.activate(".")
# If this is not the case, you need to give the full path address, e.g.
# Pkg.activate("/Users/denis/ProbabilisticCircuits.jl/")
# Alternatively, we can import our packages from github (but then local changes are not included)
#Pkg.add("https://github.com/denismaua/ProbabilisticCircuits.jl")
using ProbabilisticCircuits

# psdd = learn_probabilistic_circuit(WXData(data)); #using clt
# Loads a PSDD file 
####pc = zoo_psdd("little_4var.psdd")
# Set some query. 1 assignts True, 0 assigns False, -1 missing
####data = XData(Int8.([1 1 -1 -1]))
####prob = exp.(log_proba(pc, data))
# println("Prob: $(prob)")


# loads a .vtree file
# vtree_lines = parse_vtree_file("examples/4vars.vtree");
# vtree = compile_vtree_format_lines(vtree_lines);
# println(vtree)

#loads formula and vtree from  the repo https://github.com/UCLA-StarAI/Circuit-Model-Zoo
# 
# cnf = zoo_cnf("easy/C17_mince.cnf")
# vtree = zoo_vtree("easy/C17_mince.min.vtree");
# mgr = SddMgr(TrimSddMgr, vtree)
# cnfΔ = node2dag(compile_cnf(mgr, cnf))


#loads a .sdd  file
# sdd = load_logical_circuit("examples/random.sdd")

# Learns CSDD from data based on learn_probabilistic_circuit
data = train(dataset(twenty_datasets("nltcs"); do_shuffle=false, batch_size=-1));
# learn_credal_circuit(data, s_idm) using CSDD/CredalCircuits.jl:estimate_credal_parameters(CredalΔ, data, s_idm)
csdd = learn_credal_circuit(WXData(data), 40.0); #using clt

# println(csdd)

###for node in csdd
###    if node isa Credal⋀  # typeof(node) == Credal⋁{UnstLogicalΔNode}
###        println(node)
###        println(length(node.children))
###    end
###end

# for node in csdd
#     if node isa Credal⋁  # typeof(node) == Credal⋁{UnstLogicalΔNode}
#         println(node)
#         for j=1:length(node.children)
#             println(typeof(node.children[j]))
#             println(length(node.children[j].children))
#             println(length(node.children[j].children[1]))
#         end
#     end
# end

#         println("lower: ",exp.(node.log_thetas))
#         println("upper: ",exp.(node.log_thetas_u))
#     end
# end

# Testing marginal upper and lower flows

#obs = XData(Int8.([1 -1 -1 0 0 -1 -1 1 1 -1 -1 1 -1 -1 -1 -1 ; -1 -1 -1 0 0 -1 -1 1 1 -1 -1 1 -1 -1 -1 -1]))
#obs_c = XData(Int8.([0 -1 -1 0 0 -1 -1 1 1 -1 -1 1 -1 -1 -1 -1 ; -1 -1 -1 0 0 -1 -1 1 1 -1 -1 1 -1 -1 -1 -1]))

obs1 = XData(Int8.([1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1;0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1;0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1])) 
#obs1 = XData(Int8.([1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1])) 

#obs1 = XData(Int8.([-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 1 -1 -1; 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1])) 
#obs2 = XData(Int8.([-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 0 -1 ; -1 -1 -1 0 0 -1 -1 1 1 -1 -1 1 -1 -1 -1 -1 ; -1 -1 -1 0 0 -1 -1 1 1 -1 -1 1 -1 -1 -1 -1]))



# lower_marg_x2 = log_marginal_lower(csdd, obs1)
# lower_marg_nonx2 = log_marginal_lower(csdd, obs2)

upper_marg_obs1 = exp.(log_marginal_upper(csdd, obs1))
lower_marg_obs1 = exp.(log_marginal_lower(csdd, obs1))

#upper_marg_nonx2 = exp.(log_marginal_upper(csdd, obs2))

#println("Lower marginal x1: $(lower_marg_x2)")
println("Upper marginal obs1: $(upper_marg_obs1)")

println("Lower marginal obs1: $(lower_marg_obs1)")


#println("Lower marginal nonx1: $(lower_marg_nonx2)")
#println("Upper marginal nonx1: $(upper_marg_nonx2)")


# Testing log_likelihood of dataset (here of batch obs )

#println("LL of batch of obs = ", log_likelihood_lower_dataset(csdd, obs))

#my_test_dataset = test(dataset(twenty_datasets("nltcs"); do_shuffle=false, batch_size=-1));
#my_test_datasett = test(BatchedXDataset(twenty_datasets("nltcs"); do_shuffle=false, batch_size=-1));
#my_test_datasettt = test(XDataset(twenty_datasets("nltcs"); do_shuffle=false, batch_size=-1));
#my_test_datasetttt = test(BatchedXYDataset(twenty_datasets("nltcs"); do_shuffle=false, batch_size=-1));


#my_dataset = PlainXData


#println("tipo dataset mio : ", typeof(my_test_dataset))
#println("tipo datasett mio : ", typeof(my_test_datasett))
#println("tipo datasettt mio : ", typeof(my_test_datasettt))
#println("tipo datasetttt mio : ", typeof(my_test_datasetttt))
#println("coso dentro : ", typeof(twenty_datasets("nltcs")))
#println(twenty_datasets("nltcs"))


#println("dataset mio : ", my_test_dataset)
#println("LL of batch of obs = ", log_likelihood_lower_dataset(csdd, my_test_dataset))


# Testing complete evidence likelihood upper and lower flows

# complete_obs = XData(Bool.([1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1; 1 1 1 0 0 1 1 1 1 1 0 0 0 0 0 0]))
# #complete_obs_int = XData(Int8.([1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1; 1 1 1 0 0 1 1 1 1 1 0 0 0 0 0 0]))

# lower_prob = exp.(log_prob_lower(csdd, complete_obs))
# upper_prob = exp.(log_prob_upper(csdd, complete_obs))
# println("Lower prob: $(lower_prob)")
# println("Upper prob: $(upper_prob)")

#lower_prob_con_marginal = exp.(log_marginal_lower(csdd, complete_obs_int))
#println("Lower prob con marginal : $(lower_prob_con_marginal)")



# Testing conditional inference upper and lower bounds
## 1,0 observed/evidence variables values; 2,3 query varables values for 0,1;  -1 marginalize variables.
## cond_queries:    X_1=0,X_2=0|X_3=0,X_4=0
##             X_15=1,X_16=1|X_1=1,X_2=1             
######cond_queries= XData(Int8.([2 1 0 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1; 1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 3 1; 1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 3 1 ]))
######lower_cond = conditional_lower(csdd, cond_queries, [0.5, 0.6, 0.7])
#upper_cond = conditional_upper(csdd, cond_queries)
######println("Lower cond. prob: $(lower_cond)")
#println("Upper cond. prob: $(upper_cond)")

# for n in csdd
#     println("type of node : ", typeof(n))
# end

