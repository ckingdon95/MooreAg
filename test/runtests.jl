# Need to test the results against the R code output values
# Instead of testing the whole SCC, can just test the AgLosstGTAP variable

using Mimi
using MooreAg
using Test

discount_rate = 0.03
horizon = 2300

for gtap in MooreAg.gtaps
    ag_scc = MooreAg.get_ag_scc(gtap, prtp=discount_rate, horizon=horizon)
    println(gtap, ": \$", ag_scc)
end

# test invalid GTAP spec:
@test_throws ErrorException m = MooreAg.get_model("foo")
m = MooreAg.get_model("midDF")
update_param!(m, :gtap_spec, "foo")
@test_throws ErrorException run(m)  # should error with helpful message
