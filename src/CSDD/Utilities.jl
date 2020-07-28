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