# MooreAg

The `MooreAg` package defines an `Agriculture` component to be used in Integrated Assessment Models within the [Mimi Framework](https://github.com/mimiframework/Mimi.jl). In addition to the component definition, this package also provides helper functions for using and running the component. Code is based on the agricultural damage functions from a [2017 paper in Nature Communications](https://www.nature.com/articles/s41467-017-01792-x) by Moore et al.

## Installation

If you are new to the Julia language or to the Mimi software package, please see the [Mimi documentation](https://www.mimiframework.org/Mimi.jl/stable/installation/) for installation of Julia and Mimi.

`MooreAg` is a Julia package registered on the [MimiRegistry](https://github.com/mimiframework/MimiRegistry). To add the `MooreAg` package, you must already have the MimiRegistry added to your system. From a Julia package REPL, run the following. You only need to run the first line once on your system. In the second line, we recommend that you also add the Mimi package, so that you can use additional Mimi functionality.
```
pkg> registry add https://github.com/mimiframework/MimiRegistry.git
pkg> add MooreAg, Mimi
```

## Example use
See docstrings for a full description of the available functionality.
```julia
using MooreAg, Mimi

m = MooreAg.get_model("midDF")  # specify which of the 5 available GTAP dataframes of temperature-welfare results to use for the damage function
run(m)
explore(m)

update_param!(m, :gtap_spec, "AgMIP_NoNDF")   # update the specification for which GTAP dataframe to use
run(m)
explore(m)

# Compare the values of the agricultural SCC with and without limiting how big damages can be 
ag_scc1 = MooreAg.get_ag_scc("lowDF", prtp=0.03, floor_on_damages=true)
ag_scc2 = MooreAg.get_ag_scc("lowDF", prtp=0.03, floor_on_damages=false)
```

## Component description

Input parameters:
- `income`
- `population`
- `temp`: global temperature series
- `gtap_spec`: A `String` specifying which GTAP temperature-welfare results dataframe from Moore et al to use for the damage function. Must be one of `"AgMIP_AllDF"`, `"AgMIP_NoNDF"`, `"highDF"`, `"lowDF"`, or `"midDF"`. See documentation for a description of these choices.
- `gtap_df_all`: Holds temperature-welfare data for all five `gtap_spec` choices. Only the one specified by `gtap_spec` will be used when the component is run
- `floor_on_damages`: A `Bool` specifying whether or not to limit damages to 100% of the size of the agricultural sector. Default value is `true`.
- `ceiling_on_benefits`: A `Bool` specifying whether or not to limit benefits to 100% of the size of the agricultural sector. Default value is `false`.
- `agrish0`: Initial agricultural share of GDP
- `agel`: elasticity
- `gdp90`
- `pop90`

Calculated variables:
- `AgLossGTAP`: Percent loss on the agricultural sector in each year
- `agcost`: Total cost on the agricultural sector in each year.
- `gtap_df`: The selected temperature-welfare data used for the damage function, specified by the `gtap_spec` parameter, selected from all the data held in `gtap_df_all`

## Docstrings of available functions

**MooreAg.get_model**
```
MooreAg.get_model(gtap::String; 
    pulse::Bool=false,
    floor_on_damages::Bool = true,
    ceiling_on_benefits::Bool = false)
```
Return a Mimi model with one component, the Moore `Agriculture` component. The user must 
specify the `gtap` input parameter as one of `["AgMIP_AllDF", "AgMIP_NoNDF", "highDF", 
"lowDF", "midDF"]`, indicating which gtap damage function the component should use. 

The model has a time dimension of 2000:10:2300, and the fund_regions are the same as the FUND model. 

Population and income levels are set to values from the USG2 MERGE Optimistic scenario. 
Temperature is set to output from the DICE model. If the user specifies `pulse=true`, then 
temperature is set to output from the DICE model with a 1 GtC pulse of CO2 emissions in 2020.

If `floor_on_damages` = true, then the agricultural damages in each timestep will not be allowed to exceed 100% of the size of the 
agricultural sector in each region.
If `ceiling_on_benefits` = true, then the agricultural benefits in each timestep will not be allowed to exceed 100% of the size of the 
agricultural sector in each region.

**MooreAg.get_ag_scc**
```
MooreAg.get_ag_scc(gtap::String; 
    prtp::Float64 = 0.03, 
    horizon::Int = _default_horizon,
    floor_on_damages::Bool = true,
    ceiling_on_benefits::Bool = false)
```
Return the Agricultural SCC for a pulse in 2020 DICE temperature series and constant 
pure rate of time preference discounting with the specified keyword argument `prtp`. 
Optional keyword argument `horizon` can specify the final year of marginal damages to be 
included in the SCC calculation, with a default year of 2300.

If `floor_on_damages` = true, then the agricultural damages in each timestep will not be allowed to exceed 100% of the size of the 
agricultural sector in each region.
If `ceiling_on_benefits` = true, then the agricultural benefits in each timestep will not be allowed to exceed 100% of the size of the 
agricultural sector in each region.