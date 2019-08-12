function vtree_test_top_down()
    vars = Set(Var.([1,2,3,4,5,6]))
    context = TestContext()
    vtree = construct_top_down(vars, test_top_down, context)
    save(vtree, "./test/circuits/vtree/vtree-test-top-down.vtree.dot")
    return vtree
end

function vtree_test_bottom_up()
    vars = Set(Var.([1,2,3,4,5,6]))
    context = TestContext()
    vtree = construct_bottom_up(vars, test_bottom_up!, context)
    save(vtree, "./test/circuits/vtree/vtree-test-bottom-up.vtree.dot")
    return vtree
end

function vtree_blossom_simply()
    # even
    vars = Set(Var.([1,2,3,4]))
    mi = [  0.0 3.0 9.0 6.0;
            3.0 0.0 5.0 8.0;
            9.0 5.0 0.0 7.0;
            6.0 8.0 7.0 0.0]
    context = BlossomContext(vars, mi)
    vtree = construct_bottom_up(vars, blossom_bottom_up!, context)
    save(vtree, "./test/circuits/vtree/vtree-blossom-bottom-up-even.vtree.dot")

    # odd
    vars = Set(Var.([1, 2, 3, 4, 5]))
    mi = [  0.0 3.0 9.0 6.0 1.0;
            3.0 0.0 5.0 8.0 4.0;
            9.0 5.0 0.0 7.0 3.0;
            6.0 8.0 7.0 0.0 2.0;
            1.0 4.0 3.0 2.0 0.0]
    context = BlossomContext(vars, mi)
    vtree = construct_bottom_up(vars, blossom_bottom_up!, context)
    save(vtree, "./test/circuits/vtree/vtree-blossom-bottom-up-odd.vtree.dot")
end

function vtree_blossom_20sets()
    for name in twenty_dataset_names
        data = dataset(twenty_datasets(name); do_shuffle=false, batch_size=-1)
        train_data = train(data)
        vars = Set(Var.(1:num_features(data)))
        (dis_cache, MI) = mutual_information(WXData(train_data))

        context = BlossomContext(vars, MI)
        vtree = construct_bottom_up(vars, blossom_bottom_up!, context)
        save(vtree, "./test/circuits/vtree/vtree-blossom-$name.vtree")
        save(vtree, "./test/circuits/vtree/vtree-blossom-$name.vtree.dot")

end

function vtree_metis_20sets()
    for name in twenty_dataset_names
        data = dataset(twenty_datasets(name); do_shuffle=false, batch_size=-1)
        train_data = train(data)
        vars = Set(Var.(1 : num_features(data)))
        (dis_cache, MI) = mutual_information(WXData(train_data))
        
        context = MetisContext(MI)
        vtree = construct_top_down(vars, metis_top_down, context)
        save(vtree, "./test/circuits/vtree/vtree-metis-$name.vtree")
        save(vtree, "./test/circuits/vtree/vtree-metis-$name.vtree.dot")
    end
end