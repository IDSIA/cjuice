###########################################################################################################################################
### Marginal lower and upper for single variables 
###########################################################################################################################################
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



# ds in twenty_dataset_names, see https://github.com/UCLA-StarAI/Density-Estimation-Datasets

function plot_marg(ds ::String)

   dataSet=dataset(twenty_datasets(ds); do_shuffle=false, batch_size=-1)
   dataTrain = dataSet.train
   matrixValid = convert.(Int8,dataSet.valid.x) #covert Bool to Int8
   n_var = size(matrixValid)[2]

   batch_neg = convert.(Int8, -ones(n_var,n_var)+I)
   batch_pos = convert.(Int8, -ones(n_var,n_var) + 2*I)


   # learn the csdd
   csdd = learn_credal_circuit(WXData(dataTrain), 40.0); #using clt

   
   println("CSDD done")
  
   # matrices to plot for negative/positive status queries

   mat_neg = Array{Float64}(undef, n_var , 3)
   mat_pos = Array{Float64}(undef, n_var , 3)

   c_neg_low = Array{Float64}(undef, n_var)
   c_neg_up = Array{Float64}(undef, n_var)
   c_pos_low = Array{Float64}(undef, n_var)
   c__pos_up = Array{Float64}(undef, n_var)
   

   c_neg_low = exp.(log_marginal_lower(csdd, PlainXData(batch_neg)))
   c_neg_up = exp.(log_marginal_upper(csdd, PlainXData(batch_neg)))
   c_pos_low = exp.(log_marginal_lower(csdd, PlainXData(batch_pos)))
   c_pos_up = exp.(log_marginal_upper(csdd, PlainXData(batch_pos)))

   println("COLONNE done")
   
   mat_neg = hcat(c_neg_low, c_neg_up)
   mat_pos = hcat(c_pos_low, c_pos_up)

   # plot 
   x = 1:n_var
   plot1 = plot(x,mat_neg, title = string(ds, ": X=0"), label = ["P_lower" "P_upper"])
   plot2 = plot(x,mat_pos,  title = string(ds, ": X=1"), label = ["P_lower" "P_upper"])
   plot(plot1, plot2, layout=(2,1))
   savefig(string("plot_marg_", ds, ".png"))
      
end


# example 
plot_marg("nltcs")

plot_marg("bnetflix")

plot_marg("plants")









