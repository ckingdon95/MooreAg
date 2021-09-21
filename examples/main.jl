# This script runs Moore et al's agirculture component for USG2 with temperature input from DICE.
# It runs for all five gtap DFS (two AgMIP DFs and the low, mid, and high meta-analysis DFs).
# The variable `AgLossGTAP` (percent loss in the ag sector) is saved for each DF in `output/AgLossGTAP`. 

using DelimitedFiles
using MooreAg

output_dir = joinpath(@__DIR__, "../output/AgLossGTAP/")
mkpath(output_dir)

for gtap in MooreAg.gtaps

    m = MooreAg.get_model(gtap)
    run(m)
    AgLossGTAP = m[:Agriculture, :AgLossGTAP]   # this is the percent loss variable calculated across all FUND regions and time periods (currently 2005 to 2300)
    writedlm(joinpath(output_dir, "AgLossGTAP_$gtap.csv"), AgLossGTAP, ',')

end
