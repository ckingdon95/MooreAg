# Test the main API

@testset "API" begin

for gtap in MimiMooreEtAlAgricultureImpacts.gtaps
    ag_scc = MimiMooreEtAlAgricultureImpacts.get_ag_scc(gtap, prtp=0.03, horizon=2300)
    println(gtap, ": \$", ag_scc)
end

# test invalid GTAP spec:
@test_throws ErrorException m = MimiMooreEtAlAgricultureImpacts.get_model("foo")

# Test the floor on damages
@test MimiMooreEtAlAgricultureImpacts.get_ag_scc("midDF", prtp=0.03, floor_on_damages=false) > MimiMooreEtAlAgricultureImpacts.get_ag_scc("midDF", prtp=0.03, floor_on_damages=true)
@test MimiMooreEtAlAgricultureImpacts.get_ag_scc("highDF", prtp=0.03, floor_on_damages=false) == MimiMooreEtAlAgricultureImpacts.get_ag_scc("highDF", prtp=0.03, floor_on_damages=true) # in the "high" case, no regions hit 100% loss so the SCC values are the same here
@test MimiMooreEtAlAgricultureImpacts.get_ag_scc("lowDF", prtp=0.03, floor_on_damages=false) > MimiMooreEtAlAgricultureImpacts.get_ag_scc("lowDF", prtp=0.03, floor_on_damages=true)

# Test the ceiling on benefits
@test MimiMooreEtAlAgricultureImpacts.get_ag_scc("lowDF", prtp=0.03, ceiling_on_benefits=false) < MimiMooreEtAlAgricultureImpacts.get_ag_scc("lowDF", prtp=0.03, ceiling_on_benefits=true) # ceiling on benefits is only binding in the "lowDF" scenario

end