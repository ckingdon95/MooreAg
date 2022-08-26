using DelimitedFiles
using Mimi
using MimiMooreEtAlAgricultureImpacts
using Test

@testset "MimiMooreEtAlAgricultureImpacts" begin

include("test_api.jl")
include("test_validation.jl")

end