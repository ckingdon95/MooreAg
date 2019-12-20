#------------------------------------------------------------------------------
# 1. Test that the MCS component gives the same output as the low, mid, and
#   and high specs of the normal model for quantiles of 0.025, 0.5, and 0.975
#------------------------------------------------------------------------------

m1 = MooreAg.get_mcs_model()
m2 = MooreAg.get_model("midDF")
run(m1)
run(m2)

@test all(m1[:Agriculture, :gtap_df] .== m2[:Agriculture, :gtap_df])

update_param!(m1, :yield_scale, 0.025)
update_param!(m2, :gtap_spec, "lowDF")
run(m1)
run(m2)

@test all(m1[:Agriculture, :gtap_df] .== m2[:Agriculture, :gtap_df])

update_param!(m1, :yield_scale, 0.975)
update_param!(m2, :gtap_spec, "highDF")
run(m1)
run(m2)

@test isapprox(m1[:Agriculture, :gtap_df], m2[:Agriculture, :gtap_df], atol=1e-14)

#------------------------------------------------------------------------------
# 2. Test running the simulation
#------------------------------------------------------------------------------

N = 10000
prtp = 0.03

sim, SCC = MooreAg.run_mcs(:yield_only, N, prtp=prtp, floor_on_damages=true)
# explore(sim_results)

@test median(SCC) ≈ MooreAg.get_ag_scc("midDF", prtp=prtp, floor_on_damages=false) atol = 1e-1
@test quantile(SCC, 0.975) ≈ MooreAg.get_ag_scc("lowDF", prtp=prtp, floor_on_damages=false) atol = 1e-1
@test quantile(SCC, 0.025) ≈ MooreAg.get_ag_scc("highDF", prtp=prtp, floor_on_damages=false) atol = 1e-1

sim2, SCC2 = MooreAg.run_mcs(:full, N, prtp=prtp, floor_on_damages=true)
@test mean(SCC2) > mean(SCC)
