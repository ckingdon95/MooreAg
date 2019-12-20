# helper function used by the component definition below
function _get_scaled_effect(_range::Vector{Float64}, _scale::Float64)
    if _scale < 0.5
        low, high = _range[1], _range[2]
        return low + ((_scale - 0.025)/(0.5 - 0.025)) * (high - low)
    else
        low, high = _range[2], _range[3]
        return low + ((_scale - 0.5)/(0.975 - 0.5)) * (high - low)
    end
end

# A version of the Moore et al Agriculture component to be used in Monte Carlo analysis.
@defcomp AgricultureMC begin
    regions = Index()

    gdp90 = Parameter(index=[regions])
    income = Parameter(index=[time,regions])
    pop90 = Parameter(index=[regions])
    population = Parameter(index=[time,regions])

    agrish = Variable(index=[time,regions])     # agricultural share of the economy
    agrish0 = Parameter(index=[regions])        # initial share 
    agel = Parameter(default = 0.31)            # elasticity

    agcost = Variable(index=[time,regions])     # This is the main damage variable (positive means benefits)

    temp = Parameter(index=[time])              # Moore et al uses global temperature (original FUND ImpactAgriculture component uses regional temperature)

    # Moore additions:

    AgLossGTAP = Variable(index=[time,regions]) # Moore's fractional loss (intermediate variable for calculating agcost)

    yield_scale = Parameter(default=0.5)   # scaling parameter for Monte Carlo simulation. default is the median
    gtap_df_all_mcs = Parameter(index = [regions, 3, 3]) # In the regular component, there ar e5 choices. Here we just have the low, mid, and high from the meta analysis. 
    gtap_df = Variable(index=[regions, 3])  # three temperature data points per region

    floor_on_damages::Bool = Parameter(default = true)
    ceiling_on_benefits::Bool = Parameter(default = false)

    agcost_global = Variable(index=[time])

    function run_timestep(p, v, d, t)
                
        for r in d.regions
            # Calculate the damage function parameters based on the sampled yield_scale parameter
            for temp in [1,2,3]
                v.gtap_df[r, temp] = _get_scaled_effect(p.gtap_df_all_mcs[r, temp, :], p.yield_scale)
            end

            ypc = p.income[t, r] / p.population[t, r] * 1000.0
            ypc90 = p.gdp90[r] / p.pop90[r] * 1000.0

            v.agrish[t, r] = p.agrish0[r] * (ypc / ypc90)^(-p.agel)

            # Interpolate for p.temp, using the three gtap welfare points with the additional origin (0,0) point
            loss = linear_interpolate([0, v.gtap_df[r, :]...], collect(0:3), p.temp[t])
            loss = p.floor_on_damages ? max(-100, loss) : loss
            loss = p.ceiling_on_benefits ? min(100, loss)  : loss
            v.AgLossGTAP[t, r] = loss / 100

            # Calculate total cost for the ag sector based on the percent loss
            v.agcost[t, r] = p.income[t, r] * v.agrish[t, r] * v.AgLossGTAP[t, r]  # take out the -1 from original fund component here because damages are the other sign in Moore data
        end
        v.agcost_global[t] = sum(v.agcost[t, :])
    end
end
