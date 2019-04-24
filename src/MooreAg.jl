
module MooreAg 

using Mimi
using DelimitedFiles

include("helper.jl")
include("MooreAgComponent.jl")

# Return a model with the MooreAg Component for the specified gtap damage function.
function get_model(gtap; pulse=false)

    # TODO: The following input params need to be verified with Moore et al
    fund_datadir = joinpath(@__DIR__, "../data/FUND params")
    usg2_population = readdlm(joinpath(fund_datadir, "usg2_population.csv"),',')   # CK saved this data from running FUND with usg2, should be replaced with exact data Moore et al used for population
    usg2_income = readdlm(joinpath(fund_datadir, "usg2_income.csv"),',')           # CK saved this data from running FUND with usg2, should be replaced with exact data Moore et al used for income
    
    # CK saved these dice temperature data from running DICE with usg2 and interpolating the output, should be replaced with exact data Moore et al used for temp
    dice_temp_file = pulse ? "dice_temp_2005_2300_pulse_2015.csv" : "dice_temp_2005_2300.csv"
    dice_temp = readdlm(joinpath(@__DIR__, "../data/DICE climate output", dice_temp_file))[:]      

    # helper function
    _load_fund_param(fn) = Array{Float64, 1}(readdlm(joinpath(fund_datadir, fn), ',', skipstart=1)[:,2])    # specific to FUND regional parameter file formatting

    params = Dict{String, Any}([
        "population" =>  usg2_population,
        "income" =>      usg2_income,
        "pop90" =>       _load_fund_param("pop90.csv"),
        "gdp90" =>       _load_fund_param("gdp90.csv"),
        "temp" =>        dice_temp,
        "agrish0" =>     _load_fund_param("agrish0.csv")
    ])

    m = Model()
    set_dimension!(m, :time, years)       # const `years` defined in helper.jl
    set_dimension!(m, :regions, fund_regions)   # const `fund_regions` defined in helper.jl
    add_comp!(m, MooreAgComponent, :agriculture)
    set_param!(m, :agriculture, :gtap_df, get_gtap_df(gtap))
    set_leftover_params!(m, params)
    return m
end


# not yet correctly implemented
# function get_model_quadratic(gtap)
#     m = get_model(gtap)
#     replace_comp!(m, MooreAgComponent_quadratic, :agriculture)
#     return m
# end

# Calculates the Ag SCC for a pulse in 2015 DICE temperature series and the specified discount rate
function get_ag_scc(gtap; rate = 0.03, horizon = _default_horizon)

    # Run base model
    base = get_model(gtap)
    run(base)

    # Run model with pulse in 2015
    pulse = get_model(gtap, pulse=true)
    run(pulse)

    # calculate marginal damages
    diff = -1 * (pulse[:agriculture, :agcost] - base[:agriculture, :agcost])
    global_diff = sum(diff, dims=2) * 10^9 / 10^9  # 10^9 for billions of dollars; /10^9 for Gt pulse   # TODO: is this in 1995$ from FUND?

    # calculate SCC
    pyear = 2015
    start_idx = findfirst(isequal(pyear), years)
    end_idx = findfirst(isequal(horizon), years)
    discount_factor = [(1 + rate) ^ (-1 * t) for t in 0:end_idx-start_idx]
    npv = global_diff[start_idx:end_idx] .* discount_factor
    ag_scc = sum(npv) * 12/44   # go from $/ton C to $/ton CO2

    return ag_scc
end

end