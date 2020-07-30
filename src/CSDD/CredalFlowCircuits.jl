
function credal_marginal_upper_pass_up(circuit::UpFlowΔ{O,F}, data::XData{E}) where {E <: eltype(F)} where {O,F}
    resize_flows(circuit, num_examples(data))
    cache = zeros(Float64, num_examples(data)) #TODO: fix type later
    credal_marginal_upper_pass_up_node(n::UpFlowΔNode, ::PlainXData) = ()

    function credal_marginal_upper_pass_up_node(n::UpFlowLiteral{O,F}, cache::Array{Float64}, data::PlainXData{E}) where {E <: eltype(F)} where {O,F}
        #println("LITERAL")
        pass_up_node(n, data)
        # now override missing values by 1
        npr = pr(n)
        npr[feature_matrix(data)[:,variable(n)] .< zero(eltype(F))] .= 1
        npr .= log.( npr .+ 1e-300 )


        return nothing
    end

    function credal_marginal_upper_pass_up_node(n::UpFlow⋀Cached, cache::Array{Float64}, ::PlainXData)
       # println("AND NODE")

        pr(n) .= 0
        for i=1:length(n.children)
            # pr(n) .+= pr(n.children[i])
            broadcast!(+, pr(n), pr(n), pr(n.children[i]))
        end

        return nothing
    end


    function credal_marginal_upper_pass_up_node(n::UpFlow⋁Cached, cache::Array{Float64}, ::PlainXData)
       # println("OR NODE")

        n.pr .= 1e-300
        #pr(n) .= 1e-300

        l = Array{Float64}(undef, num_examples(data), length(n.children))
        u = Array{Float64}(undef, num_examples(data), length(n.children))
        c = Array{Float64}(undef, num_examples(data), length(n.children))


        for i=1:num_examples(data)

            l[i,:] .=  exp.(prob_origin(n).log_thetas)
            u[i,:] .=  exp.(prob_origin(n).log_thetas_u)
        end


        for i=1:num_examples(data)

            c[i,:] .= exp.(getindex.(pr.(n.children),i)) ## TODO log is monotone + broadcast
        end




        optx = Array{Float64}(undef, num_examples(data), length(n.children))
        optx = copy(u)

        for i=1:num_examples(data)

            for j=1:length(n.children)
                if c[i,j] == sort(c[i,:])[1]
                    optx[i,j] = 0.0
                    somma = sum(optx[i,:])
                    optx[i,j] = 1.0-somma ## TODO compatta questo pezzo con find o findall
                    break
                end
            end
        end



        for i=1:num_examples(data)
            pr(n)[i] = log(optx[i,:]'c[i,:])
        end

        return nothing

    end

    ## Pass Up on every node in order
    for n in circuit
        credal_marginal_upper_pass_up_node(n, cache, data)
    end

    return nothing
end

#########
###marginal lower

##################

function credal_marginal_lower_pass_up(circuit::UpFlowΔ{O,F}, data::XData{E}) where {E <: eltype(F)} where {O,F}
    resize_flows(circuit, num_examples(data))
    cache = zeros(Float64, num_examples(data)) #TODO: fix type later
    credal_marginal_lower_pass_up_node(n::UpFlowΔNode, ::PlainXData) = ()

   function credal_marginal_lower_pass_up_node(n::UpFlowLiteral{O,F}, cache::Array{Float64}, data::PlainXData{E}) where {E <: eltype(F)} where {O,F}
        pass_up_node(n, data)
        # now override missing values by 1
        npr = pr(n)
        npr[feature_matrix(data)[:,variable(n)] .< zero(eltype(F))] .= 1
        npr .= log.( npr .+ 1e-300 )
        return nothing
   end

    function credal_marginal_lower_pass_up_node(n::UpFlow⋀Cached, cache::Array{Float64}, ::PlainXData)
        pr(n) .= 0
        for i=1:length(n.children)
            # pr(n) .+= pr(n.children[i])
            broadcast!(+, pr(n), pr(n), pr(n.children[i]))
        end
        return nothing
    end

    function credal_marginal_lower_pass_up_node(n::UpFlow⋁Cached, cache::Array{Float64}, ::PlainXData)
        #println("OR NODE")

        n.pr .= 1e-300
        #pr(n) .= 1e-300

        l = Array{Float64}(undef, num_examples(data), length(n.children))
        c = Array{Float64}(undef, num_examples(data), length(n.children))


        for i=1:num_examples(data)

            l[i,:] .=  exp.(prob_origin(n).log_thetas)
        end



        for i=1:num_examples(data)

            c[i,:] .= exp.(getindex.(pr.(n.children),i)) ## TODO log is monotone + broadcast
        end




        optx = Array{Float64}(undef, num_examples(data), length(n.children))
        optx = copy(l)



        for i=1:num_examples(data)

            for j=1:length(n.children)
                if c[i,j] == sort(c[i,:])[1]
                    optx[i,j] = 0.0
                    somma = sum(optx[i,:])
                    optx[i,j] = 1.0-somma ## TODO compatta questo pezzo con find o findall
                    break
                end
            end
        end



        for i=1:num_examples(data)
            pr(n)[i] = log(optx[i,:]'c[i,:])
        end

        return nothing

    end


      ## Pass Up on every node in order
      for n in circuit
          credal_marginal_lower_pass_up_node(n, cache, data)
      end
      return nothing
end




##### marginal_pass_down ##### might need this for complete observation

# function marginal_pass_down(circuit::DownFlowΔ{O,F}) where {O,F}
#     resize_flows(circuit, flow_length(origin(circuit)))
#     for n in circuit
#         reset_downflow_in_progress(n)
#     end
#     for downflow in downflow_sinks(circuit[end])
#         # initialize root flows to 1
#         downflow.downflow .= one(eltype(F))
#     end
#     for n in Iterators.reverse(circuit)
#         marginal_pass_down_node(n)
#     end
# end

# marginal_pass_down_node(n::DownFlowΔNode) = () # do nothing
# marginal_pass_down_node(n::DownFlowLeaf) = ()

# function marginal_pass_down_node(n::DownFlow⋀Cached)
#     # todo(pashak) might need some changes, not tested, also to convert to logexpsum later
#      # downflow(n) = EF_n(e), the EF for edges or leaves are note stored
#     for c in n.children
#         for sink in downflow_sinks(c)
#             if !sink.in_progress
#                 sink.downflow .= downflow(n)
#                 sink.in_progress = true
#             else
#                 sink.downflow .+= downflow(n)
#             end
#         end
#     end
# end

# function marginal_pass_down_node(n::DownFlow⋁Cached)
#     # todo(pashak) might need some changes, not tested, also to convert to logexpsum later
#     # downflow(n) = EF_n(e), the EF for edges or leaves are note stored
#     for (ind, c) in enumerate(n.children)
#         for sink in downflow_sinks(c)
#             if !sink.in_progress
#                 sink.downflow .= downflow(n) .* exp.(prob_origin(n).log_thetas[ind] .+ pr(origin(c)) .- pr(origin(n)) )
#                 sink.in_progress = true
#             else
#                 sink.downflow .+= downflow(n) .* exp.(prob_origin(n).log_thetas[ind] .+ pr(origin(c)) .- pr(origin(n)))
#             end
#         end
#     end
# end

# #### marginal_pass_up_down

# function marginal_pass_up_down(circuit::DownFlowΔ{O,F}, data::XData{E}) where {E <: eltype(F)} where {O,F}
#     @assert !(E isa Bool)
#     # marginal_pass_up(origin(circuit), data)
#     marginal_pass_down(circuit)
# end

#############
###Conditional Upper

###############

# function conditional_upper_pass_up(circuit::UpFlowΔ{O,F}, data::XData{E}) where {E <: eltype(F)} where {O,F}
#     resize_flows(circuit, num_examples(data))

#     conditional_upper_pass_up_node(n::UpFlowΔNode, ::PlainXData) = ()


#     # pr() now returns a vector of triples (a,b,c), where:
#     #  * a:Float64 is the minValue,
#     #  * b:Float64 is the maxValue,
#     #  * c:Int8 is the type of sub-circuit (to check if contains query variables)

#     function conditional_upper_pass_up_node(n::UpFlowLiteral{O,F}, data::PlainXData{E}) where {E <: eltype(F)} where {O,F}
#         npr = pr(n)
#         nsize = length(npr)
#         val = zeros(nsize)
#         # Type 0 observed, 1 query, 2 marginalize
#         type = zeros( nsize)

#         #copy values from data input
#         #values form data input
#         #   *1,0 observed variable values;
#         #   *2,3 query variable values, where  2:0 and 3:1
#         #   *-1 unobserved variables (marginalize variables)
#         if positive(n)
#             val = feature_matrix(data)[:,variable(n)]
#         else
#             val =  ones(Float64,nsize) - feature_matrix(data)[:,variable(n)]
#         end


#         # override query variable values by 0 and 1
#         val[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)] .= 0

#         val[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)] .= 1

#         type[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize).+2.0)] .= 1

#         type[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize).+3.0)] .= 1

#         #  override marginalize variable  by 1
#         val[feature_matrix(data)[:,variable(n)] .< zeros(Float64,nsize)] .= 1
#         type[feature_matrix(data)[:,variable(n)] .< zeros(Float64,nsize)] .= 2

#         # Construct the tuple to  propagate 4 values : conditional message, marginal upper message, marginal lower message, type
#         pr(n) .= [x for x in zip(val,val,val,type)]
#         return nothing
#     end

#     function conditional_upper_pass_up_node(n::UpFlow⋀Cached, ::PlainXData)
#         npr = pr(n)
#         #Initialize values for tuples
#         val_min = ones( length(npr))
#         val_max = ones( length(npr))
#         type = zeros( length(npr))

#         for i=1:length(n.children)
#             #Obtain values from child i -> Message
#             val_min_i = getindex.(pr(n.children[i]),1) # vector a: minValue len(a)=number of queries
#             val_max_i = getindex.(pr(n.children[i]),2) # vector b: maxValue
#             type_i = getindex.(pr(n.children[i]),3)    # vector c: type of subcircuit

#             #...
#         end

#         pr(n) .= [x for x in zip(val_min,val_max,val_max,type)]
#         return nothing
#     end

#     function conditional_upper_pass_up_node(n::UpFlow⋁Cached,  ::PlainXData)
#         npr = pr(n)
#         val_min = zeros( length(npr))
#         val_max = zeros( length(npr))
#         type = zeros( length(npr))
#         for i=1:length(n.children)
#             val_min_i = getindex.(pr(n.children[i]),1)
#             val_max_i = getindex.(pr(n.children[i]),2)
#             type_i = getindex.(pr(n.children[i]),3)

#             #.....

#         end
#         pr(n) .= [x for x in zip(val_min,val_max,val_max,type)]
#         return nothing
#     end

#     for n in circuit
#         conditional_upper_pass_up_node(n,data)
#     end
#     return nothing
# end


#############
###Conditional Lower

#########

function conditional_lower_pass_up(circuit::UpFlowΔ{O,F}, data::XData{E}, mu::Array{Float64,1}) where {E <: eltype(F)} where {O,F}


    resize_flows(circuit, num_examples(data))

    conditional_lower_pass_up_node(n::UpFlowΔNode, ::PlainXData, mu::Array{Float64,1}) = ()


    # pr() now returns a vector of triples (a,b,c,d), where:
    #  * a: Float64 "val_min" is the conditional lower message
    #  * b: Float64 "marginal_lower" is the marginal lower message ,
    #  * c: Float64 "marginal_upper" is the marginal upper message,
    #  * d: Int8 "type" is the type of sub-circuit (to check if contains query variables)
    # NB: type takes values  0 observed, 1 query, 2 marginalize for marginal inference, but for conditional inference we only need to distinguish query/no query


    function conditional_lower_pass_up_node(n::UpFlowLiteral{O,F}, data::PlainXData{E}, mu::Array{Float64,1}) where {E <: eltype(F)} where {O,F}
        npr = pr(n)
        nsize = length(npr)
        val_min = zeros(nsize)     # or ones?      # primo el tuple
        marginal_lower = zeros(nsize) # secondo el tuple !!! e non zeros ! nella prog marginale P(empty obs)=1 !!!
        marginal_upper = zeros(nsize) # terzo el tuple
        type = zeros( nsize)

        # values from data input
        #   *1,0 observed variable values;
        #   *2,3 query variable values, where  2:0 and 3:1
        #   *-1 unobserved variables (marginalize variables)


        # copy values from data input: this takes care of entries concerning observed variables, for other variables see changes below
        # terminal are only literal (top terminal too. what about bot ?)

        if positive(n)

            marginal_lower = zeros(Float64,nsize) + feature_matrix(data)[:,variable(n)]
            marginal_upper = zeros(Float64,nsize) + feature_matrix(data)[:,variable(n)]
        else

            marginal_lower =  ones(Float64,nsize) - feature_matrix(data)[:,variable(n)]
            marginal_upper =  ones(Float64,nsize) - feature_matrix(data)[:,variable(n)]
        end



        # override query variable entries, depending both on the queried status and the literal status

        if positive(n)

            val_min[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)] .= (zeros(Float64,nsize) .- mu)[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)]

            val_min[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)] .= (ones(Float64,nsize) .- mu)[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)]



            marginal_lower[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)] .= 1.0
            marginal_upper[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)] .= 1.0

            marginal_lower[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)] .= 1.0
            marginal_upper[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)] .= 1.0

            # marginal_lower[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)] .= 0.0
            # marginal_upper[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)] .= 0.0

            # marginal_lower[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)] .= 1.0
            # marginal_upper[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)] .= 1.0
        else

            val_min[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)] .= (ones(Float64,nsize) .- mu)[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)]

            val_min[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)] .= (zeros(Float64,nsize) .- mu)[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)]


            marginal_lower[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)] .= 1.0
            marginal_upper[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)] .= 1.0

            marginal_lower[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)] .= 1.0
            marginal_upper[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)] .= 1.0


            # marginal_lower[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)] .= 1.0
            # marginal_upper[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 2.0)] .= 1.0

            # marginal_lower[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)] .= 0.0
            # marginal_upper[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize) .+ 3.0)] .= 0.0

        end





         # type of queried variables (independent both from the query status and the literal status, correct)

         type[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize).+2.0)] .= 1

         type[feature_matrix(data)[:,variable(n)] .== (zeros(Float64,nsize).+3.0)] .= 1




         #  override marginalize variables entries  by 1, independently from queried status and literal status
         val_min[feature_matrix(data)[:,variable(n)] .< zeros(Float64,nsize)] .= 1
         marginal_lower[feature_matrix(data)[:,variable(n)] .< zeros(Float64,nsize)] .= 1
         marginal_upper[feature_matrix(data)[:,variable(n)] .< zeros(Float64,nsize)] .= 1



         # type of variables to marginalize
         type[feature_matrix(data)[:,variable(n)] .< zeros(Float64,nsize)] .= 2


         # TODO put everything in log space

         #marginal_lower .= log.(marginal_lower .+ 1e-300 )
         #marginal_upper .= log.(marginal_upper .+ 1e-300 )
         # etc etc

         # Construct the tuple to  propagate 4 values : conditional message, marginal lower message, marginal upper message, type
         pr(n) .= [x for x in zip(val_min,marginal_lower,marginal_upper,type)]

         #println("tuple literal - ", pr(n))

         return nothing
    end

    function conditional_lower_pass_up_node(n::UpFlow⋀Cached, ::PlainXData, mu::Array{Float64,1})

        #println("AND NODE")

        # to check if bot nodes are represented as and nodes
        # if n.children[1] isa UpFlowLiteral && n.children[2] isa UpFlowLiteral
        #     if positive(n.children[1])*positive(n.children[2]) == 0 && same variable ??
        #         println("IT'S A BOT ! ")
        #     end
        # end


        npr = pr(n)
        #Initialize values for tuples
        val_min = ones( length(npr))
        marginal_lower = ones( length(npr)) # when we'll work with logs these will be zeros
        marginal_upper = ones( length(npr)) #
        type = zeros( length(npr))
        vect = ones( length(npr))

        for i=1:length(n.children) # for CSDD this is 2

            #### Marginal messages: TODO work with their log
            # broadcast!(*, marginal_lower, marginal_lower, getindex.(pr(n.children[i]),2)) SBAGLIATO!!! MI RITORNA LA SECONDA TUPLA
            # broadcast!(*, marginal_upper, marginal_upper, getindex.(pr(n.children[i]),3)) SBAGLIATO!!! MI RITORNA LA TERZA TUPLA
            marginal_lower .*= getindex.(pr(n.children[i]),2)
            marginal_upper .*= getindex.(pr(n.children[i]),3)

            # println("figlio -", i, "- è un ", typeof(n.children[i]))
            #
            # println("tuple del figlio -", i, "- ", pr(n.children[i]))
            #
            # println("marginal lowers del figlio -", i,"- ", getindex.(pr(n.children[i]),2))
            # println("marginal uppers del figlio -", i,"- ", getindex.(pr(n.children[i]),3))



            ##### conditional message (val_min) is the product of pi_lower and marginal_lower/upper of the children, depending of the types of the latter
            # val_min for now has all entries set to 1
            # start by giving pi_lower values when the type of the children i (in which we are in the for cycle) is 1
            val_min[getindex.(pr(n.children[i]),4) .== ones( length(npr))] .= getindex.(pr(n.children[i]),1)[getindex.(pr(n.children[i]),4) .== ones( length(npr))]


            ##### type. as soon as I see a children with type 1, set type = 1. otherwise it stays 0. IN AND/OR NODES TYPE IS ONLY 1 OR 0 !
            type[getindex.(pr(n.children[i]),4) .== ones( length(npr))] .= 1


        end

        ####################### WORK IN PROGRESS ########################


        ### prova


        cond_query_first_child = getindex.(pr(n.children[1]),4) .== ones( length(npr))
        #cond_no_query_first_child = getindex.(pr(n.children[1]),4) .!== ones( length(npr))

        cond_positive_val_second_child = getindex.(pr(n.children[2]),1) .> zeros( length(npr))
        cond_negative_val_second_child = getindex.(pr(n.children[2]),1) .< zeros( length(npr))

        cond_query_second_child = getindex.(pr(n.children[2]),4) .== ones( length(npr))
        #cond_no_query_second_child = getindex.(pr(n.children[2]),4) .!== ones( length(npr))

        cond_positive_val_first_child = getindex.(pr(n.children[1]),1) .> zeros( length(npr))
        cond_negative_val_first_child = getindex.(pr(n.children[1]),1) .< zeros( length(npr))




        #println("val min prima ", val_min)

        val_min[cond_query_second_child .& cond_positive_val_second_child].*= getindex.(pr(n.children[1]),2)[cond_query_second_child .& cond_positive_val_second_child]
        val_min[cond_query_second_child  .& cond_negative_val_second_child].*= getindex.(pr(n.children[1]),3)[cond_query_second_child .& cond_negative_val_second_child]

       # println("val min step 1 ", val_min)

        val_min[cond_query_first_child .& cond_positive_val_first_child].*= getindex.(pr(n.children[2]),2)[cond_query_first_child .& cond_positive_val_first_child]
        val_min[cond_query_first_child .& cond_negative_val_first_child ].*= getindex.(pr(n.children[2]),3)[cond_query_first_child .& cond_negative_val_first_child]

        #println("val min step 2 ", val_min)


        ### original one:  multiply val_min by the correct marginal

        # val_min[(getindex.(pr(n.children[1]),4) .!== ones( length(npr))) .& (getindex.(pr(n.children[2]),1) .> zeros( length(npr))) ].*= getindex.(pr(n.children[1]),2)[(getindex.(pr(n.children[1]),4) .!== ones( length(npr))) .& (getindex.(pr(n.children[2]),1) .> zeros( length(npr))) ]
        # val_min[(getindex.(pr(n.children[1]),4) .!== ones( length(npr))) .& (getindex.(pr(n.children[2]),1) .< zeros( length(npr))) ].*= getindex.(pr(n.children[1]),3)[(getindex.(pr(n.children[1]),4) .!== ones( length(npr))) .& (getindex.(pr(n.children[2]),1) .< zeros( length(npr))) ]

        # val_min[(getindex.(pr(n.children[2]),4) .!== ones( length(npr))) .& (getindex.(pr(n.children[1]),1) .> zeros( length(npr))) ].*= getindex.(pr(n.children[2]),2)[(getindex.(pr(n.children[2]),4) .!== ones( length(npr))) .& (getindex.(pr(n.children[1]),1) .> zeros( length(npr))) ]
        # val_min[(getindex.(pr(n.children[2]),4) .!== ones( length(npr))) .& (getindex.(pr(n.children[1]),1) .< zeros( length(npr))) ].*= getindex.(pr(n.children[2]),3)[(getindex.(pr(n.children[2]),4) .!== ones( length(npr))) .& (getindex.(pr(n.children[1]),1) .< zeros( length(npr))) ]


        pr(n) .= [x for x in zip(val_min,marginal_lower,marginal_upper,type)]


        return nothing
    end

    function conditional_lower_pass_up_node(n::UpFlow⋁Cached,  ::PlainXData, mu::Array{Float64,1})
        #println("OR NODE")

        npr = pr(n)
        val_min = zeros( length(npr))
        marginal_lower = zeros( length(npr))
        marginal_upper = zeros( length(npr))
        type = zeros( length(npr))

        # type :  enough to set it equal to any of its children, eg the first one

        type = getindex.(pr(n.children[1]),4)


        #if n.children[1] isa UpFlowLiteral


         ##### qui risolvo, in parallelo per ogni instance (query) LP e storo gli ottimi nei vari vettori


        c_co = Array{Float64}(undef, length(npr), length(n.children))
        c_marg_lo = Array{Float64}(undef, length(npr), length(n.children))
        c_marg_up = Array{Float64}(undef, length(npr), length(n.children))

        #println("coefficenti prima - problema conditional", c_co)
        #println("coefficenti prima - problema marginal lower", c_marg_lo)
        #println("coefficenti prima - problema marginal upper", c_marg_up)



        #println("pr.(n.children): ", pr.(n.children))

        #println("getindex.(pr.(n.children),1) : ", getindex.(pr.(n.children),1))
        #println("c_marg_lo = getindex.(getindex.(pr.(n.children),1),2) : ", getindex.(getindex.(pr.(n.children),1),2))
        #println("c_marg_up = getindex.(getindex.(pr.(n.children),1),3) : ", getindex.(getindex.(pr.(n.children),1),3))



        #println("getindex.(pr.(n.children),2): ", getindex.(pr.(n.children),2))


        for i=1:length(npr)
             c_co[i,:] = getindex.(getindex.(pr.(n.children),i),1) # vettore dei coefficenti del i-esimo problema COND  (i-esima instance)
             c_marg_lo[i,:] = getindex.(getindex.(pr.(n.children),i),2) # vettore dei coefficenti del i-esimo problema MARG_LOWER (i-esima instance)
             c_marg_up[i,:] = getindex.(getindex.(pr.(n.children),i),3) # vettore dei coefficenti del i-esimo problema MARG_UPPER  (i-esima instance)
        end
        # println("coefficenti dopo - problema conditional", c_co)
        # println("coefficenti dopo - problema marginal lower", c_marg_lo)
        # println("coefficenti dopo - problema marginal upper", c_marg_up)


         # con lp PROVA

                #coeff[:,i] .= getindex.(pr(n.children[i]),1)

            #end
            #print("=========xxx============")
            #for i=1:length(npr) ### TODO broadcast this
                #val_min[i] = minimi(coeff[i,:], exp.(prob_origin(n).log_thetas), exp.(prob_origin(n).log_thetas_u))
                #@show coeff[i,:]
                #@show typeof(coeff[i,:])
            #end

             #println("IT'S A TOP !")
        #else




         ##### qui risolvo, in parallelo per ogni instance (query) LP e storo gli ottimi nei vari vettori

         ## conditional


            #c_co = Array{Float64}(undef, length(npr), length(n.children))
            #c_marg_lo = Array{Float64}(undef, length(npr), length(n.children))
            #c_marg_up = Array{Float64}(undef, length(npr), length(n.children))


            #for i=1:length(npr)
            #    c_co[i,:] = getindex.(getindex.(pr.(n.children),i),1) # vettore dei coefficenti del i-esimo problema COND  (i-esima instance)
            #    c_marg_lo[i,:] = getindex.(getindex.(pr.(n.children),i),2) # vettore dei coefficenti del i-esimo problema MARG_LOWER (i-esima instance)
            #    c_marg_up[i,:] = getindex.(getindex.(pr.(n.children),i),3) # vettore dei coefficenti del i-esimo problema MARG_UPPER  (i-esima instance)
            #end



            #for i=1:length(npr)
                #@show c_co[i,:]
                #@show typeof(c_co[i,:])
                #val_min[i] = minimi(c_co[i,:], exp.(prob_origin(n).log_thetas), exp.(prob_origin(n).log_thetas) )
                #@show val_min[i]
                #marginal_lower[i] = minimi(c_marg_lo[i,:], exp.(prob_origin(n).log_thetas), exp.(prob_origin(n).log_thetas) )
                #marginal_upper[i] = minimi(c_marg_up[i,:], exp.(prob_origin(n).log_thetas), exp.(prob_origin(n).log_thetas) )
            #end

        bounds = Array{Float64,2}(undef, 2, length(n.children))
        #bounds = hcat(exp.(prob_origin(n).log_thetas), exp.(prob_origin(n).log_thetas_u))
        bounds = hcat(prob_origin(n).log_thetas, prob_origin(n).log_thetas_u)




        for i=1:length(npr)
            val_min[i] = lp(c_co[i,:], bounds, false, true )
            marginal_lower[i] = lp(c_marg_lo[i,:], bounds, false, true)
            marginal_upper[i] = lp(c_marg_up[i,:], bounds, true, true )
        end


        pr(n) .= [x for x in zip(val_min,marginal_lower,marginal_upper,type)]

        #println("tuple OR - ", pr(n))

        return nothing
    end

    for n in circuit
        conditional_lower_pass_up_node(n,data,mu)
    end
    return nothing
end
