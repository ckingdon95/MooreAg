include("../src/helper.jl")
include("../src/MooreAgModel.jl")


# 1. Generate DICE temperature series

include("../../dice-IWG/src/IWG_DICE2010.jl")
m = IWG_DICE2010.get_model("MERGEoptimistic")
run(m)
dice_ssp2_temp = linear_interpolate(m[:climatedynmics, :temp], IWG_DICE2010.years, MooreAgModel.years)


# 2. Generate DICE temperature series with a pulse in 2015 (?)

pyear = 2015
m = IWG_DICE2010.get_model("MERGEoptimistic")
run(m)
IWG_DICE2010.add_marginal_emissions!(m, pyear)
dice_ssp2_temp_pulse = linear_interpolate(m[:climatedynmics, :temp], IWG_DICE2010.years, MooreAgModel.years)


# 3. Generate socioeconomics variables for SSP2 from FUND

include("../../fund-IWG/src/IWG_FUND.jl")
m = IWG_FUND.get_model("MERGE Optimistic")
run(m)
idx = findfirst(isequal(MooreAgModel.years[1]), IWG_FUND.years):findfirst(isequal(MooreAgModel.years[end]), IWG_FUND.years)
ssp2_population = m[:population, :population][idx, :]
ssp2_income = m[:socioeconomics, :income][idx, :]