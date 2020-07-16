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



#  dataSet=dataset(twenty_datasets("nltcs"); do_shuffle=false, batch_size=-1)
#  dataTrain = dataSet.train
#  l = num_examples(dataTrain)
#  println("num examples = ", l)


# println("type of dataTrain = ", typeof(dataTrain)) #type of dataTrain = PlainXData{Bool,BitArray{2}}


# matrixTrain=convert.(Int8,dataSet.train.x) #covert Bool to Int8
# matrixTrain2 = matrixTrain[1:100,:]


# dataTrain2_ = convert.(Bool,matrixTrain2)

 #dataTrain2 = PlainXData(dataTrain2_)

# println(typeof(dataTrain2))


# # data validation

# matrixValid = convert.(Int8,dataSet.valid.x) #covert Bool to Int8

#dataValid = XData(matrixValid) 




# #println("type Datatest",typeof(dataTest))

#  #csdd = learn_credal_circuit(WXData(dataTrain2), 40.0); #using clt

#  csdd = learn_credal_circuit(WXData(dataTrain), 40.0); #using clt




 #println(twenty_dataset_names)

   ###############################################################################################################################################
#   # LLL, LLU and gap for growing portions of training data, for the twenty datasets in https://github.com/UCLA-StarAI/Density-Estimation-Datasets
#   ###############################################################################################################################################
   
    function LL_lo_up_twenty_ds(training_portion::Float64)
  
       show = Array{Tuple{String,Float64,Float64,Float64}}(undef,21)

       for i=1:21 #name in twenty_dataset_names
          name = twenty_dataset_names[i]
          
          dataSet=dataset(twenty_datasets(name); do_shuffle=false, batch_size=-1)
          dataTrain = dataSet.train
          l = num_examples(dataTrain)


          matrixValid = convert.(Int8,dataSet.valid.x) #covert Bool to Int8
          dataValid = XData(matrixValid) 



          matrixTrain_ = convert.(Int8, dataSet.train.x)
          matrixTrain = matrixTrain_[1:trunc(Int, training_portion*l),:]

          dataTrain= PlainXData(convert.(Bool,matrixTrain))

          csdd = learn_credal_circuit(WXData(dataTrain), 40.0); #using clt

          LLL = sum(log_marginal_lower(csdd, dataValid))
          LLU = sum(log_marginal_upper(csdd, dataValid))
          gap = - (LLL-LLU)

          show[i] = (name, LLL, LLU, gap)

          end


       return show

    end

    println( LL_lo_up_twenty_ds(0.5))
  

##
# #########################################################################################



# # obs1 = XData(Int8.([1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1;0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1;0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1])) 




# # upper_marg_obs1 = exp.(log_marginal_upper(csdd, obs1))
# # lower_marg_obs1 = exp.(log_marginal_lower(csdd, obs1))


# # println("Upper marginal obs1: $(upper_marg_obs1)")

# # println("Lower marginal obs1: $(lower_marg_obs1)")



# # # Testing log_likelihood of test dataset

# # LLL = sum(log_marginal_lower(csdd, dataValid))
# # LLU = sum(log_marginal_upper(csdd, dataValid))


# # println("LLL of data validation = ", LLL)
# # println("LLU of data validation = ", LLU)




# # # Testing complete evidence likelihood upper and lower flows

# # complete_obs = XData(Bool.([1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1; 1 1 1 0 0 1 1 1 1 1 0 0 0 0 0 0]))



# # upper_marg_complete_obs = exp.(log_marginal_upper(csdd, obs1))
# # lower_marg_complete_obs = exp.(log_marginal_lower(csdd, obs1))


# # println("Upper of complete obs using marginal: $(upper_marg_complete_obs)")

# # println("Lower of complete obs using marginal: $(lower_marg_complete_obs)")


# # # lower_prob = exp.(log_prob_lower(csdd, complete_obs))
# # # upper_prob = exp.(log_prob_upper(csdd, complete_obs))
# # # println("Lower prob: $(lower_prob)")
# # # println("Upper prob: $(upper_prob)")




# # # Testing conditional inference upper and lower bounds
# # ## 1,0 observed/evidence variables values; 2,3 query varables values for 0,1;  -1 marginalize variables.
# # ## cond_queries:    X_1=0,X_2=0|X_3=0,X_4=0
# # ##             X_15=1,X_16=1|X_1=1,X_2=1             
# # ######cond_queries= XData(Int8.([2 1 0 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1; 1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 3 1; 1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 3 1 ]))
# # ######lower_cond = conditional_lower(csdd, cond_queries, [0.5, 0.6, 0.7])
# # #upper_cond = conditional_upper(csdd, cond_queries)
# # ######println("Lower cond. prob: $(lower_cond)")
# # #println("Upper cond. prob: $(upper_cond)")

# # # for n in csdd
# # #     println("type of node : ", typeof(n))
# # # end

