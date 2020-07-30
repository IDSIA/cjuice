using JuMP, Clp

function idm(d :: Array{Int64,1}, s=2.0 :: Float64, logspace=true :: Bool)
    n = length(d)
    p = zeros(2,n)
    p[1,:] = d
    p[2,:] = d .+ s
    p = p ./ (sum(d) .+ s)
    return logspace ? [log.(x) for x in p] : p
end

function lp(c :: Array{Float64,1}, p :: Array{Float64,2}, maximize=true :: Bool, logspace=true :: Bool)
    x = p[1,:]
    i = sortperm(c,rev=maximize)[1]
    x[i] = p[2,i]
    return logspace ? c'*exp.(x) : c'*x
end

function add_missingness(data :: PlainXData{Bool,BitArray{2}} , ratio :: Float64)
    data2 = convert.(Int8,data.x)
    data2[rand(Float16,size(data.x)) .< ratio] .= -1
    return data2
end

function minimi(coeff :: Array{Float64,1}, l_bounds :: Array{Float64,1}, u_bounds :: Array{Float64,1})
    my_model = Model(Clp.Optimizer)
    set_optimizer_attribute(my_model, "LogLevel", 0)
    set_optimizer_attribute(my_model, "Algorithm", 4)
    @variable(my_model, l_bounds[i] <= x[i = 1:length(l_bounds)]<= u_bounds[i])
    @objective(my_model,Min,coeff' *x) # perché anche * ?
    @constraint(my_model, normalization, ones(Float64, length(l_bounds))'x == 1)
    optimize!(my_model)
    return JuMP.objective_value(my_model)
end
