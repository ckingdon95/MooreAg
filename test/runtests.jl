using DelimitedFiles
using Mimi
using MooreAg
using Statistics
using Test

@testset "MooreAg" begin

include("test_api.jl")
include("test_validation.jl")
include("test_mcs.jl")

end