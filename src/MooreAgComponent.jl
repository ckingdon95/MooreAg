using Mimi

# Moore et al Agricutlure component (with linear interpolation between gtap temperature points)
@defcomp MooreAgComponent begin
    regions = Index()

    gdp90 = Parameter(index=[regions])
    income = Parameter(index=[time,regions])
    pop90 = Parameter(index=[regions])
    population = Parameter(index=[time,regions])

    agrish = Variable(index=[time,regions])
    agrish0 = Parameter(index=[regions])
    agel = Parameter(default = 0.31)

    agcost = Variable(index=[time,regions])     # This is the main damage variable (positive means benefits)
    AgLossGTAP = Variable(index=[time,regions]) # added; Moore's fractional loss (intermediate variable for calculating agcost)

    temp = Parameter(index=[time])              # Moore et al uses global temperature (original FUND ImpactAgriculture component uses regional temperature)

    # MOORE addition
    gtap_df = Parameter(index=[regions,3])  # three temperature data points per region

    function run_timestep(p, v, d, t)
                
        for r in d.regions
            ypc = p.income[t, r] / p.population[t, r] * 1000.0
            ypc90 = p.gdp90[r] / p.pop90[r] * 1000.0

            v.agrish[t, r] = p.agrish0[r] * (ypc / ypc90)^(-p.agel)
        end

        for r in d.regions
            # Interpolate for p.temp, using the three gtap welfare points with the additional origin (0,0) point
            extrapolated_loss = linear_interpolate([0 p.gtap_df[r, :]...][:], collect(0:3), p.temp[t])

            v.AgLossGTAP[t, r] = max(-100, extrapolated_loss) / 100     # floor on damages
            # v.AgLossGTAP[t, r] = min(100, extrapolated_loss) / 100    # ceiling on benefits
            # v.AgLossGTAP[t, r] = max(-100, min(100, extrapolated_loss)) / 100 # floor on damages and ceiling on benefits

            v.agcost[t, r] = p.income[t, r] * v.agrish[t, r] * v.AgLossGTAP[t, r]  # take out the -1 from original fund component here because damages are the other sign in moore data
        end
    end
end


# Moore et al Agricutlure component with quadratic interpolation
# TODO: need to confirm how quadratic interpolation was performed
# @defcomp MooreAgComponent_quadratic begin
#     regions = Index()

#     gdp90 = Parameter(index=[regions])
#     income = Parameter(index=[time,regions])
#     pop90 = Parameter(index=[regions])
#     population = Parameter(index=[time,regions])

#     agrish = Variable(index=[time,regions])
#     agrish0 = Parameter(index=[regions])
#     agel = Parameter(default = 0.31)

#     agcost = Variable(index=[time,regions])     # This is the main damage variable (positive means benefits)
#     AgLossGTAP = Variable(index=[time,regions]) # added; Moore's fractional loss

#     temp = Parameter(index=[time])              # Moore et al uses global temperature (original FUND ImpactAgriculture component uses regional temperature)

#     # MOORE addition
#     gtap_df = Parameter(index=[regions,3])  # three temperature data points per region
#     a = Variable(index=[regions])  # Quadratic coefficient derived from data in the GTAP DF
#     b = Variable(index=[regions])  # Quadratic linear coefficient
#     c = Variable(index=[regions])  # Quadratic constant

#     function run_timestep(p, v, d, t)

#         if is_first(t)
#             # Derive the quadratic coefficents from the provided gtap_df
#             # all of the provided data are for temperatures (x values) 1, 2, and 3
#             # we want to fit a quadratic, so we need a matrix of x^2, x^1, and x^0 for each data point of 1, 2, and 3
#             A = [1.^2 1. 1.; 
#                  2.^2 2. 1.; 
#                  3.^2 3. 1.]    
#             for r in d.regions
#                 y = p.gtap_df[r, :][:]
#                 v.a[r], v.b[r], v.c[r] = A\y    # solve the system of linear equations; save the coefficents to use in the damage function below
#             end
#         end
        
#         for r in d.regions
#             ypc = p.income[t, r] / p.population[t, r] * 1000.0
#             ypc90 = p.gdp90[r] / p.pop90[r] * 1000.0

#             v.agrish[t, r] = p.agrish0[r] * (ypc / ypc90)^(-p.agel)
#         end

#         for r in d.regions
#             extrapolated_loss = v.a[r] * p.temp[t] ^ 2 + v.b[r] * p.temp[t] + v.c[r]

#             v.AgLossGTAP[t, r] = max(-100, extrapolated_loss) / 100
#             # v.AgLossGTAP[t, r] = min(100, extrapolated_loss) / 100
#             # v.AgLossGTAP[t, r] = max(-100, min(100, extrapolated_loss)) / 100

#             v.agcost[t, r] = p.income[t, r] * v.agrish[t, r] * v.AgLossGTAP[t, r]  # take out the -1 that moore used because we want damages as the other sign here
#         end
        
#     end
# end

