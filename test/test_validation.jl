# Validate the output agains the result from the R code

@testset "Validation" begin

results = readdlm(joinpath(@__DIR__, "../data/validation/ag_scc.csv"), ',')
mimi_sccs = Vector{Any}()
global i = 2
for gtap in MooreAg.gtaps 
    for dr in [0.025, 0.03, 0.05]
        println(gtap, dr)
        mimi_scc = MooreAg.get_ag_scc(gtap, prtp = dr)
        r_scc = results[i, 3]
        @test mimi_scc == r_scc
        push!(mimi_sccs, mimi_scc)
        println(mimi_scc)
        println(r_scc)
        global i = i + 1
    end
end

# comparison = hcat(results, ["Mimi_scc", mimi_sccs...])
# writedlm(joinpath(@__DIR__, "scc_comparison.csv"), comparison, ",")

end