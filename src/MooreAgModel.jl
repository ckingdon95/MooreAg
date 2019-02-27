module MooreAgModel 

using Mimi
using DelimitedFiles

include("helper.jl")
include("MooreAgComponent.jl")


function get_model(gtap; pulse=false)

    # TODO: The following input params need to be verified with Moore et al
    fund_datadir = joinpath(@__DIR__, "../data/FUND params")
    ssp2_population = readdlm(joinpath(fund_datadir, "ssp2_population.csv"),',')   # CK saved this data from running FUND with SSP2, should be replaced with exact data Moore et al used for population
    ssp2_income = readdlm(joinpath(fund_datadir, "ssp2_income.csv"),',')           # CK saved this data from running FUND with SSP2, should be replaced with exact data Moore et al used for income
    
    # CK saved these dice temperature data from running DICE with SSP2 and interpolating the output, should be replaced with exact data Moore et al used for temp
    dice_temp_file = pulse ? "dice_temp_2005_2300_pulse_2015.csv" : "dice_temp_2005_2300.csv"
    dice_temp = readdlm(joinpath(@__DIR__, "../data/DICE climate output", dice_temp_file))[:]      

    # helper function
    _load_fund_param(fn) = Array{Float64, 1}(readdlm(joinpath(fund_datadir, fn), ',', skipstart=1)[:,2])    # specific to FUND regional parameter file formatting

    params = Dict{String, Any}([
        "population" =>  ssp2_population,
        "income" =>      ssp2_income,
        "pop90" =>       _load_fund_param("pop90.csv"),
        "gdp90" =>       _load_fund_param("gdp90.csv"),
        "temp" =>        dice_temp,
        "agrish0" =>     _load_fund_param("agrish0.csv")
    ])

    m = Model()
    set_dimension!(m, :time, years)       # const `years` defined in helper.jl
    set_dimension!(m, :regions, fund_regions)   # const `fund_regions` defined in helper.jl
    add_comp!(m, MooreAg, :agriculture)
    set_param!(m, :agriculture, :gtap_df, get_gtap_df(gtap))
    set_leftover_params!(m, params)
    return m
end

# not yet correctly implemented
# function get_model_quadratic(gtap)
#     m = get_model(gtap)
#     replace_comp!(m, MooreAg_quadratic, :agriculture)
#     return m
# end

end