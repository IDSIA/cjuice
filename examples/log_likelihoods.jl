###############################################################################################################################################
## LLL, LLU for growing portions of training data, for the twenty (one) datasets in https://github.com/UCLA-StarAI/Density-Estimation-Datasets
################################################################################################################################################
   

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
# splits = nr of splits in the training dataset

function plot_ll(ds :: String, splits :: Int)
      
  LL = Array{Float64}(undef, splits, 2)
          
  dataSet=dataset(twenty_datasets(ds); do_shuffle=false, batch_size=-1)
  dataTrain = dataSet.train
  l = num_examples(dataTrain)


  matrixValid = convert.(Int8,dataSet.valid.x) #covert Bool to Int8
  dataValid = XData(matrixValid) 

  matrixTrain_ = convert.(Int8, dataSet.train.x)

  for k = 1:splits

     matrixTrain_k = matrixTrain_[1:trunc(Int, (l/splits)*k),:]

     dataTrain_k= PlainXData(convert.(Bool,matrixTrain_k))

    #  csdd_k = learn_credal_circuit(WXData(dataTrain_k), 40.0); #using clt
    csdd_k =learn_struct_credal_circuit(WXData(dataTrain_k), 40.0)[1]; #using clt and vtree

     LL[k,1] = sum(log_marginal_lower(csdd_k, dataValid))
     LL[k,2] = sum(log_marginal_upper(csdd_k, dataValid))

  end

  # plot

  x = 1:splits
  plot(x, LL, title = string("Lower and Upper LogLikelihood of ", ds), label = ["Lower LL" "Upper LL"])
  savefig(string("examples/plot_ll_", ds, ".png"))  
   
  return nothing
  #return LL
   

end


# example 

#plot_ll("nltcs", 10)
plot_ll("bnetflix", 10)

plot_ll("plants", 10)




