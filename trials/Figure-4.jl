include("common_trial_data.jl")

using Gadfly

const bench = :xerox

solver = CplexSolver(CPX_PARAM_MIQCPSTRAT=2)

const sampling_rate = 10

immutable NodeData
    node::Int
    time::Float64
    incumbent_value::Float64
    bestbound::Float64
end

type BBData
    nodes::Vector{NodeData}
    name::UTF8String
end

function node_data_callback(cb, model::Model)
    node_data::Vector{NodeData} = model.ext[:bbvis].nodes
    nodes_explored  = MathProgBase.cbgetexplorednodes(cb)
    (nodes_explored ≤ 100) || (nodes_explored % sampling_rate == 0) || return
    start_time      = isempty(node_data) ? 0.0 : node_data[1].time
    current_time    = time()
    has_incumbent   = CPLEX.cbgetfeasibility(cb)
    incumbent_value = MathProgBase.cbgetobj(cb)
    bestbound       = MathProgBase.cbgetbestbound(cb)
    push!(node_data, NodeData(nodes_explored,
                              current_time - start_time,
                              has_incumbent == 1 ? incumbent_value : NaN,
                              bestbound))
    nothing
end

function record_node_data(model::JuMP.Model, name::String)
    model.ext[:bbvis] = BBData(NodeData[], name)
    addInfoCallback(model, cb -> node_data_callback(cb,model))
end

function plot_mip_gaps(models::JuMP.Model...)
    layers = Any[]
    for (it,model) in enumerate(models)
        _nodes = model.ext[:bbvis].nodes
        nodes = filter(x -> !isnan(x.incumbent_value), _nodes)
        name  = fill(model.ext[:bbvis].name, length(nodes))
        append!(layers, [layer(x=[n.node for n in nodes], y=[n.incumbent_value for n in nodes], color=[name], Geom.line, Stat.step),
                         layer(x=[n.node for n in nodes], y=[n.bestbound       for n in nodes], color=[name], Geom.line, Stat.step)])
    end
    return plot(layers..., Guide.xlabel("Node number"), Guide.ylabel(""), Stat.step)
end

function run_test(bench, trial, name)
    model = Model(solver=solver)
    prob = get_problem_data(bench, β)
    vars = base_model(model, prob, trial.formulation; redundant=true)

    for cut in trial.cuts
        addcuts(model, prob, vars, cut)
    end

    record_node_data(model, name)

    solve(model)

    model
end

models = Model[]
for (trial,name) in zip([SPp,RU],["SP+","RU"])
    model = run_test(bench, trial, name)
    push!(models, model)
    gc()
end

p1 = plot_mip_gaps(models...)
draw(PDF(joinpath("results", "Figure-4.pdf"), 10inch, 6inch), p1)
