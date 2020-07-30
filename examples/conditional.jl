# this assumes we have already installed LogicCircuits
using LogicCircuits
using LinearAlgebra
using Plots

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






dataSet=dataset(twenty_datasets("nltcs"); do_shuffle=false, batch_size=-1)
dataTrain = dataSet.train


#csdd = learn_credal_circuit(WXData(dataTrain), 40.0); #using clt
csdd =learn_struct_credal_circuit(WXData(dataTrain), 40.0)[1]; #using clt and vtree
println("csdd done")

# Testing conditional inference upper and lower bounds
# 1,0 observed/evidence variables values; 2,3 query varables values for 0,1;  -1 marginalize variables.
# cond_queries:    X_1=0,X_2=0|X_3=0,X_4=0
#             X_15=1,X_16=1|X_1=1,X_2=1

cond_queries= XData(Int8.([2 1 0 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1; 1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 3 1; -1 1 -1 -1 -1 -1 -1 -1 -1 -1 1 -1 -1 -1 3 1 ]))
lower_cond1 = conditional_lower(csdd, cond_queries, [0.5, 0.2, 0.7])
#lower_cond2 = conditional_lower(csdd, cond_queries, [1.0, 1.0, 1.0])

#upper_cond = conditional_upper(csdd, cond_queries)
println("Lower cond. prob: $(lower_cond1)")
#println("Lower cond. prob: $(lower_cond2)")

#println("Upper cond. prob: $(upper_cond)")

# for n in csdd
#     if n isa Credal⋀
#     println("nr of children : ", length(n.children))
#     println("tipo children1 : ", typeof(n.children[1]))
#     println("tipo children2 : ", typeof(n.children[2]))
#     end

# end

 
