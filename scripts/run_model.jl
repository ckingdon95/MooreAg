using Mimi

include("../src/MooreAg.jl")

m = MooreAg.get_model("midDF")
run(m)
explore(m)