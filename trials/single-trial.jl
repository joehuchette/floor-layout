curdir = pwd()

include(joinpath(curdir,"common_trial_data.jl"))
bench = symbol(ARGS[1])
γ = float(ARGS[2])
β = parse(Int,ARGS[3])
approach = approaches[ARGS[4]]

srand(hash(γ)*hash(β)*hash(bench))

const fp = open(joinpath(curdir, "results", "single-trial.csv"), "a")

# timeout after 4 hours, and force SOC linearization
solver = CplexSolver(CPX_PARAM_TILIM=4, CPX_PARAM_MIQCPSTRAT=2)

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
close(fp)
