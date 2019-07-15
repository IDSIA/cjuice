using LightGraphs
using SimpleWeightedGraphs
using MetaGraphs

#####################
# Get mutual information
#####################

function marginal_distribution(vector::AbstractArray, weight::Array, type_num::Int,
        smoothing_factor::Real)::Dict
    dis = Dict()
    len = length(vector)
    for (v, w) in zip(vector, weight)
        dis[v] = get(dis, v, 0) + w
    end
    for x in 0 : type_num - 1
        dis[x] = (get(dis, x, 0) + smoothing_factor * type_num) /
            (len + type_num * type_num * smoothing_factor)
    end
    return dis
end


function pairwise_distribution(vector1::AbstractArray, vector2::AbstractArray,
        weight::Array, type_num::Int, smoothing_factor::Real)::Dict
    @assert length(vector1) == length(vector2)
    dis = Dict()
    len = length(vector1)
    for i in 1 : len
        dis[(vector1[i], vector2[i])] = get(dis, (vector1[i], vector2[i]), 0) + weight[i]
    end
    for x in 0 : type_num - 1, y in 0 : type_num - 1
        dis[(x, y)] = (get(dis, (x, y), 0) + smoothing_factor) /
            (len + type_num * type_num * smoothing_factor)
    end
    return dis
end


function mutual_information(data::WXData, index1::Int, index2::Int, type_num::Int;
        base = ℯ, smoothing_factor=0)::Float64
    weight = Data.weights(data)
    data_matrix = feature_matrix(data)
    vector1 = data_matrix[:, index1]
    vector2 = data_matrix[:, index2]

    prob_i = marginal_distribution(vector1, weight, type_num, smoothing_factor)
    prob_j = marginal_distribution(vector2, weight, type_num, smoothing_factor)
    prob_ij = pairwise_distribution(vector1, vector2, weight, type_num, smoothing_factor)
    mi = 0.0
    for x in keys(prob_i), y in keys(prob_j)
        if !isapprox(0.0, prob_ij[(x, y)]; atol=eps(Float64), rtol=0)
            mi += prob_ij[(x, y)] * log(base, prob_ij[(x, y)] / (prob_i[x] * prob_j[y]))
        end
    end
    return mi
end

#####################
# Get CPTs of tree-structured BN
#####################

function get_cpt(data::WXData,parent_index::Int, child_index::Int,
        type_num::Int;smoothing_factor=0)::Dict
    weight_vector = Data.weights(data)
    data_matrix = feature_matrix(data)
    child = data_matrix[:, child_index]
    prob_c = marginal_distribution(child, weight_vector, type_num, smoothing_factor)
    if parent_index == 0 return prob_c end
    parent = data_matrix[:, parent_index]
    prob_p = marginal_distribution(parent, weight_vector, type_num, smoothing_factor)
    prob_pc = pairwise_distribution(parent, child, weight_vector, type_num, smoothing_factor)
    cpt = Dict()
    for p in keys(prob_p), c in keys(prob_c)
        if !isapprox(0.0, prob_p[p]; atol=eps(Float64), rtol=0)
            cpt[(c, p)] = prob_pc[(p, c)] / prob_p[p]
        end
    end
    return cpt
end


#####################
# Learn a Chow-Liu tree from weighted data
#####################

function learn_chow_liu_tree(data::WXData; smoothing_factor=0)::MetaDiGraph
    weight_vector = Data.weights(data)
    data_matrix = feature_matrix(data)
    features_num = num_features(data)
    type_num = maximum(data_matrix[:, 1]) + 1

    # Calculate mutual information matrix
    g = SimpleWeightedGraph(features_num)
    for i in 1:features_num, j in i+1:features_num
        mi = mutual_information(data, i, j, type_num;smoothing_factor=smoothing_factor)
        add_edge!(g, i, j, - mi)
    end

    # Maximum spanning tree/ forest
    mst_edges = kruskal_mst(g)
    tree = SimpleWeightedGraph(features_num)
    for edge in mst_edges
        add_edge!(tree, src(edge), dst(edge), - weight(edge))
    end
    roots = [c[1] for c in connected_components(tree)]
    rooted_tree = SimpleDiGraph(features_num)
    for root in roots rooted_tree = union(rooted_tree, bfs_tree(tree, root)) end

    # Construct Chow-Liu tree with CPTs
    clt = MetaDiGraph(rooted_tree)
    set_prop!(clt, :description, "Chow-Liu Tree of Weighted Sample")
    ## add weights
    for edge in edges(clt)
        set_prop!(clt, edge, :weight, tree.weights[src(edge), dst(edge)])
    end
    ## set parent
    for root in roots set_prop!(clt, root, :parent, 0) end
    for edge in edges(clt)
        set_prop!(clt, dst(edge), :parent, src(edge))
    end
    ## calculate cpts
    for v in vertices(clt)
        parent = get_prop(clt, v, :parent)
        cpt_matrix = get_cpt(data, parent, v, type_num; smoothing_factor = smoothing_factor)
        set_prop!(clt, v, :cpt, cpt_matrix)
    end
    return clt
end
