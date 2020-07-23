using LogicCircuits
using ProbabilisticCircuits
#using JuMP, Clp
#=
function idm(data_counts :: Array{Int64,1}, s=2.0 :: Float64, logspace=true :: Bool)
    n = length(data_counts)
    p = zeros(2,n)
    p[1,:] = data_counts
    p[2,:] = data_counts .+ s
    p = p ./ (sum(data_counts) .+ s)
    return logspace ? [log.(x) for x in p] : p
end

function solver_lp(c :: Array{Float64,1}, p :: Array{Float64,2}, maximize=true :: Bool, logspace=true :: Bool)
    my_model = Model(Clp.Optimizer)
    set_optimizer_attribute(my_model, "LogLevel", 0)
    set_optimizer_attribute(my_model, "Algorithm", 4)
    if logspace
        @variable(my_model, exp(p[1,i]) <= x[i = 1:length(c)]<= exp(p[2,i])) 
    else
        @variable(my_model, p[1,i] <= x[i = 1:length(c)]<= p[2,i]) 
    end
    @constraint(my_model, normalization, ones(Float64, length(c))'x == 1.)
    maximize ? @objective(my_model,Max,c'*x) : @objective(my_model,Min,c'*x)
    optimize!(my_model)
    #println("x = ", JuMP.value.(x))
    return JuMP.objective_value(my_model)     
end      

function manual_lp(c :: Array{Float64,1}, p :: Array{Float64,2}, maximize=true :: Bool, logspace=true :: Bool)
    x = p[1,:]
    i = sortperm(c,rev=maximize)[1]
    x[i] = p[2,i]
    return logspace ? c'*exp.(x) : c'*x
end

=#
#=
using Plots;
x = 1:10;
y = rand(10,2); # These are the plotting data
plot(x, y, title="Alessandro", label = ["A" "B"], lw=3)
xlabel!("My x label")
savefig("myplot.png") # Saves the CURRENT_PLOT as a .png
print("Finito")
=#
for n in 3:4
    A = rand(1:10, n)
    pA = idm(A,2.0,false)
    pA2 = idm(A,2.0,true)
    c = rand(Float64,n)
    #println(pA[1,:])
    #println(pA[2,:])
    #println("===")
    println(lp(c,pA,true,false))
    println(lp(c,pA,false,false))
    #println(solver_lp(c,pA,true,false))
    #println(solver_lp(c,pA2,true,true))
    #println(manual_lp(c,pA,true,false))
    #println(manual_lp(c,pA2,true,true))
    #println(solver_lp(c,pA,false,false))
    #println(solver_lp(c,pA2,false,true))
    #println(manual_lp(c,pA,false,false))
    #println(manual_lp(c,pA2,false,true))
end

#a :: Float64
#b :: Float64
#c :: Float64

#for k = 1:1
#    left = 1.0
#    right = 4.0
#    middle = 0.5
#    if f(left)*f(right)<0
#        middle = 0.0
#        for j = 1:10
#            middle = (left+right)/2.0
#            f(left)*f(middle)<0.0 ? right = middle : left = middle
#        end
#    end
#end
#print(middle," ",f(middle))