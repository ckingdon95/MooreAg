using Mimi
using MimiMooreEtAlAgricultureImpacts

m = MimiMooreEtAlAgricultureImpacts.get_model("midDF")
run(m)
explore(m)
