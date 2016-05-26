include("common_trial_data.jl")

filename = split(splitdir(@__FILE__)[2], ".")[1] # pick up current file name, strip off directory and file postfix
const fp = open("results/$(filename).txt", "w+")

# timeout after 4 hours, and force SOC linearization
# solver = CplexSolver(CPX_PARAM_TILIM=4*3600.0, CPX_PARAM_MIQCPSTRAT=2)
solver = CplexSolver(CPX_PARAM_TILIM=4, CPX_PARAM_MIQCPSTRAT=2)

function run_test(bench, γ, β, approach::Approach)
    prob = get_problem_data(bench, β)
    jitter_data!(prob, γ)

    model = Model(solver=solver)
    vars = base_model(model, prob, approach.formulation)

    for cut in approach.cuts
        addcuts(model, prob, vars, cut)
    end

    tm = @elapsed (stat = solve(model))

    rel_gap    = try MathProgBase.getobjgap(model.internalModel);     catch Inf; end
    num_nodes  = try CPLEX.get_node_count(model.internalModel.inner); catch 0;   end
    lowerbound = try MathProgBase.getobjbound(model.internalModel);   catch 0;   end

    println(fp, join(["$bench-$γ",
                      β,
                      approach.name,
                      tm,
                      lowerbound,
                      getobjectivevalue(model),
                      num_nodes,
                      rel_gap], ", "))
    flush(fp)
end

println(fp, "Benchmark, beta, approach, runtime, lowerbound, upperbound, nodecount, gap")
srand(11)

for bench in benchmarks; for γ in [0,.1,.2]
    for β in [4,5,6]
        for approach in approaches
            run_test(bench, γ, β, approach)
            gc()
        end
    end
end; end

close(fp)
