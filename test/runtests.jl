using DelimitedFiles
using Mimi
using MooreAg
using Test

@testset "MooreAg" begin

include("test_api.jl")
include("test_validation.jl")

end