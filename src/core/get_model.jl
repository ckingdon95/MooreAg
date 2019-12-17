"""
    MooreAg.get_model(gtap::String; pulse::Bool=false)

Return a Mimi model with one component, the Moore Agriculture component. The user must 
specify the `gtap` input parameter as one of `["AgMIP_AllDF", "AgMIP_NoNDF", "highDF", 
"lowDF", "midDF"]`, indicating which gtap damage function the component should use. 

The model has a time dimension of 2000:10:2300, and the regions are the same as the FUND model. 

Population and income levels are set to values from the USG2 MERGE Optimistic scenario. 
Temperature is set to output from the DICE model. If the user specifies `pulse=true`, then 
tmeperature is set to output from the DICE model with a 1 GtC pulse of CO2 emissions in 2020.

If `floor_on_damages` = true, then the agricultural damages (negative values of the 
`agcost` variable) in each timestep will not be allowed to exceed 100% of the size of the 
agricutlural sector in each region.
If `ceiling_on_benefits` = true, then the agricultural benefits (positive values of the
`agcost` variable) in each timestep will not be allowed to exceed 100% of the size of the 
agricutlural sector in each region.
"""
function get_model(gtap::String; 
    pulse::Bool=false,
    floor_on_damages::Bool = true,
    ceiling_on_benefits::Bool = false)

    gtap in gtaps ? nothing : error("Unknown GTAP dataframe specification: \"$gtap\". Must be one of the following: $gtaps")

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
        "agrish0" =>     Array{Float64, 1}(readdlm(joinpath(fund_datadir, "agrish0.csv"), ',', skipstart=1)[:,2]),
        "gtap_df_all" => gtap_df_all
    ])

    m = Model()
    set_dimension!(m, :time, years)       # const `years` defined in helper.jl
    set_dimension!(m, :regions, fund_regions)   # const `fund_regions` defined in helper.jl
    add_comp!(m, Agriculture)
    set_param!(m, :Agriculture, :gtap_spec, gtap)
    set_param!(m, :Agriculture, :floor_on_damages, floor_on_damages)
    set_param!(m, :Agriculture, :ceiling_on_benefits, ceiling_on_benefits)
    set_leftover_params!(m, params)
    return m
end

"""
    MooreAg.get_ag_scc(gtap::String; 
        prtp::Float64 = 0.03, 
        horizon::Int = _default_horizon,
        floor_on_damages::Bool = true,
        ceiling_on_benefits::Bool = false)

Return the Agricultural SCC for a pulse in 2020 DICE temperature series and constant 
pure rate of time preference discounting with the specified keyword argument `prtp`. 
Optional keyword argument `horizon` can specify the final year of marginal damages to be 
included in the SCC calculation, with a default year of 2300.

If `floor_on_damages` = true, then the agricultural damages (negative values of the 
`agcost` variable) in each timestep will not be allowed to exceed 100% of the size of the 
agricutlural sector in each region.
If `ceiling_on_benefits` = true, then the agricultural benefits (positive values of the
`agcost` variable) in each timestep will not be allowed to exceed 100% of the size of the 
agricutlural sector in each region.
"""
function get_ag_scc(gtap::String; 
    prtp::Float64 = 0.03, 
    horizon::Int = _default_horizon,
    floor_on_damages::Bool = true,
    ceiling_on_benefits::Bool = false)

    horizon in years ? nothing : error("Invalid value: $horizon for `horizon`, must be within the model years.")

    # Run base model
    base_m = get_model(gtap, floor_on_damages = floor_on_damages, ceiling_on_benefits = ceiling_on_benefits)
    run(base_m)

    # Run model with pulse in 2020
    pulse_m = get_model(gtap, pulse=true, floor_on_damages = floor_on_damages, ceiling_on_benefits = ceiling_on_benefits)
    run(pulse_m)

    # calculate SCC 
    base_damages = dropdims(sum(base_m[:Agriculture, :agcost], dims=2), dims=2)
    pulse_damages = dropdims(sum(pulse_m[:Agriculture, :agcost], dims=2), dims=2)
    marginal_damages = -1 * (pulse_damages - base_damages) * 10^9 / 10^9 * 12/44  # 10^9 for billions of dollars; /10^9 for Gt pulse; 12/44 to go from $/ton C to $/ton CO2

    start_idx = findfirst(isequal(pulse_year), years)
    end_idx = findfirst(isequal(horizon), years)

    # Implement discounting as a 10-year step function as described by Delevane
    discount_factor = [(1 + prtp) ^ (-1 * t * 10) for t in 0:end_idx-start_idx]
    npv = marginal_damages[start_idx:end_idx] .* 10 .* discount_factor  # multiply by 10 so that value of damages is used for all 10 years

    ag_scc = sum(npv) 

    return ag_scc
end
