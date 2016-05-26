include("common_trial_data.jl")

filename = split(splitdir(@__FILE__)[2], ".")[1] # pick up current file name, strip off directory and file postfix
const fp = open("results/$(filename).txt", "w+")

# timeout after 4 hours, and force SOC linearization
solver = CplexSolver(CPX_PARAM_TILIM=4*3600.0, CPX_PARAM_MIQCPSTRAT=2)

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

    sol = Solution(prob,
                   getValue(vars.cˣ),
                   getValue(vars.cʸ),
                   getValue(vars.ℓˣ),
                   getValue(vars.ℓʸ),
                   getObjectiveValue(model),
                   trial.formulation,
                   trial.cuts,
                   model,
                   tm,
                   MathProgBase.numvar(model),
                   MathProgBase.numlinconstr(model),
                   stat,
                   num_nodes,
                   rel_gap,
                   lowerbound)

    verify_and_print(fp, prob, sol)
end

for bench in benchmarks
    println(fp, "bench = $bench, β = $β")
    for trial in approaches
        run_test(bench, trial)
        gc()
    end
end

close(fp)
