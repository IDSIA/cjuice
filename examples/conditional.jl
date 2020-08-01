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


# Testing conditional inference upper and lower bounds
# 1,0 observed/evidence variables values; 2,3 query varables values for 0,1;  -1 marginalize variables.

# cond_queries X=0|e ,  X=1|e , X=1| e'
cond_queries= XData(Int8.([2 1 0 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1; 3 1 0 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1; 1 1 1 1 -1 -1 -1 1 -1 1 -1 1 -1 -1 3 1 ]))


### bissection scheme

a = zeros(Float64, num_examples(cond_queries))
b = ones(Float64, num_examples(cond_queries))
m = zeros(Float64, num_examples(cond_queries))
cond_lo = zeros(Float64, num_examples(cond_queries))

aa = zeros(Float64, num_examples(cond_queries))
bb = ones(Float64, num_examples(cond_queries))
mm = zeros(Float64, num_examples(cond_queries))
cond_up = zeros(Float64, num_examples(cond_queries))

for k=1:10
    for i=1:num_examples(cond_queries)
        if conditional_lower(csdd, cond_queries, a)[i]* conditional_lower(csdd, cond_queries, b)[i] < 0.0
            m[i] = 0.5*(a[i]+b[i])
            conditional_lower(csdd, cond_queries, a)[i]* conditional_lower(csdd, cond_queries, m)[i] < 0.0 ? b[i]=m[i] : a[i]=m[i]
        end

        if conditional_upper(csdd, cond_queries, aa)[i]* conditional_upper(csdd, cond_queries, bb)[i] < 0.0
            mm[i] = 0.5*(aa[i]+bb[i])
            conditional_upper(csdd, cond_queries, aa)[i]* conditional_upper(csdd, cond_queries, mm)[i] < 0.0 ? bb[i]=mm[i] : aa[i]=mm[i]
        end
    end
end

cond_lo = 0.5*(a+b)
cond_up = 0.5*(aa+bb)




println("conditional lower probability estimated intervals = ", hcat(a,b))
println("estimated lower conditional probabilities = ", cond_lo)

println("conditional upper probability estimated intervals = ", hcat(aa,bb))
println("estimated conditional upper probabilities = ", cond_up)









# aa = zeros(Float64, num_examples(cond_queries))
# bb = ones(Float64, num_examples(cond_queries))
# mm = zeros(Float64, num_examples(cond_queries))
# cond_up = zeros(Float64, num_examples(cond_queries))
#
# for k=1:10
#     for i=1:num_examples(cond_queries)
#         if conditional_upper(csdd, cond_queries, aa)[i]* conditional_upper(csdd, cond_queries, bb)[i] < 0.0
#             mm[i] = 0.5*(aa[i]+bb[i])
#             conditional_upper(csdd, cond_queries, aa)[i]* conditional_upper(csdd, cond_queries, mm)[i] < 0.0 ? bb[i]=mm[i] : aa[i]=mm[i]
#         end
#     end
# end
#
# cond_up = 0.5*(aa+bb)
#
#
# println("conditional upper probability estimated intervals = ", hcat(aa,bb))
# println("estimated conditional upper probabilities = ", cond_up)

# Bisection Code (Alessandro)
n_iteraz = 15
mu_left = zeros(Float64, num_examples(cond_queries))
mu_right = ones(Float64, num_examples(cond_queries))
for k in 1:n_iteraz
mu_middle .= (mu_left + mu_right) ./ 2.0
f_middle = conditional_upper(csdd, cond_queries, mu_middle)
f_left = conditional_upper(csdd, cond_queries, mu_left)
f_right = conditional_upper(csdd, cond_queries, mu_right)
mu_right[f_left .* f_middle .< 0.0] .= mu_middle[f_left .* f_middle .< 0.0]
mu_left[f_left .* f_middle .>= 0.0] .= mu_middle[f_left .* f_middle .>= 0.0]
f_left = conditional_upper(csdd, cond_queries, mu_left)
f_right = conditional_upper(csdd, cond_queries, mu_right)
end
@show mu_middle
