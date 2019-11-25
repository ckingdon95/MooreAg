
module MooreAg 

using Mimi
using DelimitedFiles

include("helper.jl")
include("MooreAgComponent.jl")

# Return a model with the MooreAg Component for the specified gtap damage function.
function get_model(gtap; pulse=false)

    # Read in the USG2 socioeconomics data 
    usg2_population = Array{Float64, 2}(readdlm(joinpath(fund_datadir, "usg2_population.csv"),',')[2:end, 2:end])   # Saved from SCCinputs.rdata from Delavane
    usg2_income = Array{Float64, 2}(readdlm(joinpath(fund_datadir, "usg2_income.csv"),',')[2:end, 2:end])   # Saved from SCCinputs.rdata from Delavane
    
    # Read in DICE temperature pathway
    dice_temp_file = pulse ? "dice_temp_pulse.csv" : "dice_temp.csv"
    dice_temp = readdlm(joinpath(dice_datadir, dice_temp_file), Float64)[:]      

    params = Dict{String, Any}([
        "population" =>  usg2_population[2:end, :],     # 2000:10:2300
        "income" =>      usg2_income[2:end, :],         # 2000:10:2300
        "pop90" =>       usg2_population[1, :],         # 1990 is the first row
        "gdp90" =>       usg2_income[1, :],             # 1990 is the first row
        "temp" =>        dice_temp,
        "agrish0" =>     Array{Float64, 1}(readdlm(joinpath(fund_datadir, "agrish0.csv"), ',', skipstart=1)[:,2])
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
    base_m = get_model(gtap)
    run(base_m)

    # Run model with pulse in 2015
    pulse = get_model(gtap, pulse=true)
    run(pulse)

    # calculate SCC based on annually interpolated marginal damages (sum across regions to global, then interpolate)
    annual_years = collect(2000:2300)
    base_damages = linear_interpolate(dropdims(sum(base_m[:agriculture, :agcost], dims=2), dims=2), years, annual_years)
    pulse_damages = linear_interpolate(dropdims(sum(pulse[:agriculture, :agcost], dims=2) ,dims=2), years, annual_years)
    diff = -1 * (pulse_damages - base_damages) * 10^9 / 10^9 # 10^9 for billions of dollars; /10^9 for Gt pulse TODO: need to confirm that this is the same for Delavane's data

    start_idx = findfirst(isequal(pulse_year), annual_years)
    end_idx = findfirst(isequal(horizon), annual_years)
    discount_factor = [(1 + rate) ^ (-1 * t) for t in 0:end_idx-start_idx]

    npv = diff[start_idx:end_idx] .* discount_factor
    ag_scc = sum(npv) * 12/44 # We don't have to go from $/ton C to $/ton CO2? it's already in CO2? TODO: is this in 1995$ from FUND? do we need to multiply by USD2005to1995

    return ag_scc
end

end