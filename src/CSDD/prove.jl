using JuMP
using Clp
using LinearAlgebra

function minimi(coeff :: Array{Float64,1}, l_bounds :: Array{Float64,1}, u_bounds :: Array{Float64,1})
# cosi poi gli entro in broadcasting c, exp.(prob_origin(n).log_thetas), exp.(prob_origin(n).log_thetas_u)
    my_model = Model(Clp.Optimizer)
    set_optimizer_attribute(my_model, "LogLevel", 1)
     set_optimizer_attribute(my_model, "Algorithm", 4)


     @variable(my_model, l_bounds[i] <= x[i = 1:length(l_bounds)]<= u_bounds[i]) 
     @objective(my_model,Min,coeff' *x) # perché anche * ?
     @constraint(my_model, normalization, ones(Float64, length(l_bounds))'x == 1)
    
        
     optimize!(my_model)
        # println("Optimal Solutions:")
        # println("x = ", JuMP.value.(x))
        #  println("Optimal Value:")
        #  println("min =", JuMP.objective_value(my_model))
        #  #getobjectivevalue
     return JuMP.objective_value(my_model)     
end      


# c=rand(3,5)
# println(c)

# l = zeros(3)
# u = ones(3)

# println(l)
# println(u)

# println(l.+c)

# #println(minimi(c[:,1], l[:,1], u[:,1]))

# #println(minimi(c[:,1], l, u))
# #println(minimi.(c, l, u)) cosi no perché lo fa elemento per elemento !

# optima = Vector(undef,5)
# for i=1:5
#     optima[i]=minimi(c[:,i], l, u)
# end

# println(optima)

# type = zeros(8)
# vect = ones(8)

# tupl = Tuple{Float64,Float64,Float64,Float64}

# println(type)

# println(vect)

# println(tupl)

# [13:16] Antonucci Alessandro
    

# vettore =[10,20,30,40,50]
# q =zeros(5)
# q[2]=4
# q[4]=4
# q[5]=4
# quattro =ones(5)*4
 
# v =zeros(5)
# tre =ones(5)*3
# v[1]=3
# v[2]=3
# v[5]=3
 
# #print(v)
# l3 = v.==tre
# l4 = q.==quattro
# print(l3)
# print(l4)
# print(l3 .& l4)
# vettore[l3 .& l4].*=10
# print(vettore[l3 .& l4])
# print(vettore)


# vettore =[10,20,30,40,50]
# q =zeros(5)
# q[2]=4
# q[4]=4
# q[5]=4
# quattro =ones(5)*4
 
# v =zeros(5)
# tre =ones(5)*3
# v[1]=3
# v[2]=3
# v[5]=3
 
# #print(v)
# l3 = v.==tre
# l4 = q.==quattro
# print(l3)
# print(l4)
# print(l3 .& l4)
# vettore[l3 .& l4].*=10
# print(vettore[l3 .& l4])
# print(vettore)



# ppp = ones(Float64,8)
# println(ppp)
# println(sum(ppp))

array = [1 2 3; 4 5 6]
println(array)
println(typeof(array))
println("prima colonna : ", array[:,1])
println("prima riga : ", array[1,:])

println(getindex(array[:,1],1))
