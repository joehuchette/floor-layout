include("../trials/common_trial_data.jl")

names = [:U, :Up, :BLDP1, :BLDP1p, :SP, :SPp, :SPpVI, :SPpVI3, :RU, :RUpVI, :RUpVI3]

for bench in benchmarks
    sbench = string(bench)
    try mkdir(sbench) end
    for (trial,name) in zip(approaches,names)
        model = Model(solver=CplexSolver(CPX_PARAM_MIQCPSTRAT=2))
        prob = get_problem_data(bench, β)
        vars = base_model(model, prob, trial.formulation)
        buildInternalModel(model)
        for cut in trial.cuts
            addcuts(model, prob, vars, cut)
        end
        MathProgBase.writeproblem(getInternalModel(model), joinpath(sbench,"$sbench-$name.mps"))
    end
end
