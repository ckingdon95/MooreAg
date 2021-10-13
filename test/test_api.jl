# Test the main API

@testset "API" begin

for gtap in MooreAg.gtaps
    ag_scc = MooreAg.get_ag_scc(gtap, prtp=0.03, horizon=2300)
    println(gtap, ": \$", ag_scc)
end

# test invalid GTAP spec:
@test_throws ErrorException m = MooreAg.get_model("foo")

# Test the floor on damages
@test MooreAg.get_ag_scc("midDF", prtp=0.03, floor_on_damages=false) > MooreAg.get_ag_scc("midDF", prtp=0.03, floor_on_damages=true)
@test MooreAg.get_ag_scc("highDF", prtp=0.03, floor_on_damages=false) == MooreAg.get_ag_scc("highDF", prtp=0.03, floor_on_damages=true) # in the "high" case, no regions hit 100% loss so the SCC values are the same here
@test MooreAg.get_ag_scc("lowDF", prtp=0.03, floor_on_damages=false) > MooreAg.get_ag_scc("lowDF", prtp=0.03, floor_on_damages=true)

# Test the ceiling on benefits
@test MooreAg.get_ag_scc("lowDF", prtp=0.03, ceiling_on_benefits=false) < MooreAg.get_ag_scc("lowDF", prtp=0.03, ceiling_on_benefits=true) # ceiling on benefits is only binding in the "lowDF" scenario

end