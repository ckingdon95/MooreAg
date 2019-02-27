include("MooreAgModel.jl")

function get_ag_scc(gtap; rate = 0.03)

    # Run base model
    base = MooreAgModel.get_model(gtap)
    run(base)

    # Run model with pulse in 2015
    pulse = MooreAgModel.get_model(gtap, pulse=true)
    run(pulse)

    # calculate marginal damages
    diff = -1 * (pulse[:agriculture, :agcost] - base[:agriculture, :agcost])
    global_diff = sum(diff, 2)

    # calculate SCC
    pyear = 2015
    start_idx = findfirst(isequal(pyear), MooreAgModel.years)
    discount_factor = [(1 + rate) ^ (-1 * t) for t in 0:length(MooreAgModel.years)-start_idx]
    ag_scc = sum(global_diff[start_idx:end] .* discount_factor)

    return ag_scc
end