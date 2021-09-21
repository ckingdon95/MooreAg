module MooreAg 

using Mimi
using Interpolations
using DelimitedFiles
using CSVFiles
using DataFrames

include("core/utils.jl")
include("core/AgricultureComponent.jl")
include("core/get_model.jl")
include("core/get_ag_scc.jl")

end