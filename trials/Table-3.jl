include("common_trial_data.jl")

filename = split(splitdir(@__FILE__)[2], ".")[1] # pick up current file name, strip off directory and file postfix
const fp = open("results/$(filename).txt", "w+")

solver = CplexSolver(CPX_PARAM_MIQCPSTRAT=2, CPX_PARAM_NODELIM=0)

function run_test(bench, trial::Approach)
    model = Model(solver=solver)
    prob = get_problem_data(bench, β)
    vars = base_model(model, prob, trial.formulation)

    for cut in trial.cuts
        addcuts(model, prob, vars, cut)
    end

    tm = @elapsed (stat = solve(model))

    rel_gap    = try MathProgBase.getobjgap(model.internalModel);     catch Inf; end
    num_nodes  = try CPLEX.get_node_count(model.internalModel.inner); catch 0;   end
    lowerbound = try MathProgBase.getobjbound(model.internalModel);   catch 0;   end

    upper = get(UB, bench, NaN)
    lower = MathProgBase.getobjbound(model.internalModel)
    println(fp, "form = $(trial.formulation), cuts = $(trial.cuts)")
    println(fp, "    rows:  $(MathProgBase.numlinconstr(model))")
    println(fp, "    time:  $tm")
    println(fp, "    gap:   $(gap(upper, lower))")
    println(fp, "    lower: $lower")
    println(fp)
    flush(fp)
end

for bench in benchmarks
    println(fp, "bench = $bench, β = $β")
    for trial in approaches
        run_test(bench, trial)
        gc()
    end
end

close(fp)
