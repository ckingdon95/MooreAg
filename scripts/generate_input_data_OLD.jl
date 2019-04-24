# By CK before receiving input data from Delavane.
#       extract usg2 soicoeconomics from running FUND on that scenario
#       extract temperature pathways from DICE climate 

include("../src/helper.jl")
include("../src/MooreAgModel.jl")

include("../../dice-IWG/src/IWG_DICE2010.jl")
include("../../fund-IWG/src/IWG_FUND.jl")

fund_datadir = joinpath(@__DIR__, "../data/FUND params")
dice_datadir = joinpath(@__DIR__, "../data/DICE climate output")


# 1. Generate DICE temperature series

m = IWG_DICE2010.get_model("MERGEoptimistic")
run(m)
dice_usg2_temp = linear_interpolate(m[:climatedynamics, :TATM], IWG_DICE2010.years, MooreAgModel.years)
writedlm(joinpath(dice_datadir, "dice_temp_$(MooreAgModel.years[1])_$(MooreAgModel.years[end]).csv"), dice_usg2_temp, ',')

# 2. Generate DICE temperature series with a pulse in 2015 (?)

pyear = 2015
m = IWG_DICE2010.get_model("MERGEoptimistic")
IWG_DICE2010.add_marginal_emissions!(m, pyear)
run(m)
dice_usg2_temp_pulse = linear_interpolate(m[:climatedynamics, :TATM], IWG_DICE2010.years, MooreAgModel.years)
writedlm(joinpath(dice_datadir, "dice_temp_$(MooreAgModel.years[1])_$(MooreAgModel.years[end])_pulse_$pyear.csv"), dice_usg2_temp_pulse, ',')


# 3. Generate socioeconomics variables for usg2 from FUND

m = IWG_FUND.get_model("MERGE Optimistic")
run(m)
idx = findfirst(isequal(MooreAgModel.years[1]), IWG_FUND.years):findfirst(isequal(MooreAgModel.years[end]), IWG_FUND.years)
usg2_population = m[:population, :population][idx, :]
usg2_income = m[:socioeconomic, :income][idx, :]
writedlm(joinpath(fund_datadir, "usg2_population.csv"), usg2_population, ',')
writedlm(joinpath(fund_datadir, "usg2_income.csv"), usg2_income, ',')