include("../src/MooreAgSCC.jl")

output_dir = joinpath(@__DIR__, "../output/AgSCC/")
mkpath(output_dir)

for gtap in MooreAgModel.gtaps

    ag_scc = get_ag_scc(gtap)
    println(gtap, ": ", ag_scc)

end