include("common_trial_data.jl")

filename = split(splitdir(@__FILE__)[2], ".")[1] # pick up current file name, strip off directory and file postfix
const fp = open("results/$(filename).txt", "w+")

solver = CplexSolver(CPX_PARAM_MIQCPSTRAT=2)

function run_test(bench, trial::Approach, symbreak)
    model = Model(solver=solver)
    prob = get_problem_data(bench, β)
    vars = base_model(model, prob, trial.formulation, symbreak=symbreak)

    for cut in trial.cuts
        addcuts(model, prob, vars, cut)
    end

    tm = @elapsed (stat = solve(model, relaxation=true))

    upper = get(UB, bench, NaN)
    lower = getObjectiveValue(model)
    println(fp, "form = $(trial.formulation), cuts = $(trial.cuts)")
    println(fp, "    rows:  $(MathProgBase.numlinconstr(model))")
    println(fp, "    time:  $tm")
    println(fp, "    gap:   $(gap(upper, lower))")
    println(fp, "    lower: $lower")
    println(fp)
    flush(fp)
end

for bench in benchmarks, symbreak in [false,true]
    println(fp, "bench = $bench, β = $β, symbreak = $symbreak")
    for trial in approaches
        run_test(bench, trial, symbreak)
        gc()
    end
end

close(fp)
