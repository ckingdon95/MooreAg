using Interpolations

const years = 2005:2300 #TODO: confirm what years Moore et al ran for
const gtaps = ["AgMIP_AllDF", "AgMIP_NoNDF", "highDF", "lowDF", "midDF"]

# Moore et al uses regions in alphabetical order; need to be conscious of switching the regional ordering for running with FUND
alpha_order = ["ANZ","CAM","CAN","CEE","CHI","FSU","JPK","MDE","NAF","SAM","SAS","SEA","SIS","SSA","USA","WEU"]
alpha_order[[4, 9, 10]] = ["EEU", "MAF", "LAM"]     # three regions named slightly different: CEU, NAF, CAM --> EEU, MAF, LAM
const fund_regions = ["USA","CAN","WEU","JPK","ANZ","EEU","FSU","MDE","CAM","LAM","SAS","SEA","CHI","MAF","SSA","SIS"]
const switch_region_indices = [findfirst(isequal(region), alpha_order) for region in fund_regions]

# Returns the Moore gtap data points (16 regions x 3 points) in the FUND regional order
function get_gtap_df(gtap::String)
    gtap in gtaps ? nothing : error("Unknown gtap dataframe specification: $gtap.")
    gtap_dir = joinpath(@__DIR__, "../data/GTAP DFs")
    gtap_data = Array(readdlm(joinpath(gtap_dir, "$gtap.csv"), ',', skipstart=1)')
    return gtap_data[switch_region_indices, :]
end 

# helper function for linear interpolation
function linear_interpolate(values, orig_x, new_x)
    itp = extrapolate(interpolate((orig_x,), values, Gridded(Linear())), Line())    # linear interpolation within the provided points; extrapolation beyond
    return [convert(Float64, itp[i]) for i in new_x]
end

# TODO: implement quadratic interpolation correctly
# function quadratic_interpolate(values, orig_x, new_x)
    # itp = interpolate(values, BSpline(Quadratic(Free())), OnGrid()) # TODO: only works if original x values are 1,2,3,etc.
    # return [itp[i] for i in new_x]
# end