# Welcome

The `MimiMooreEtAlAgricultureImpacts` package defines an `Agriculture` component to be used in Integrated Assessment Models within the [Mimi Framework](https://github.com/mimiframework/Mimi.jl). In addition to the component definition, this package also provides helper functions for using and running the component. Code is based on the agricultural damage functions from a [2017 paper in Nature Communications](https://www.nature.com/articles/s41467-017-01792-x) by Moore et al.

## The Agriculture Component

The `Agriculture` component is a Mimi component implementing Moore et al's agricultural damage function. The component is defined in "src/AgricultureComponent.jl". It has a variable called `gtap_df` which is a 16 x 3 Array of percent welfare impact data (16 FUND regions x 3 temperature points). In the run_timestep function, this component takes temperature for that timestep and uses the gtap dataframe to linearly interpolate or extrapolate to get the percent loss for that timestep, saved in variable `AgLossGTAP`. 

There are 5 choices of temperature-welfare dataframes that can be used to form the basis of the damage function. They are:
- "midDF" - the median result from Moore et al's meta analysis of yield responses
- "lowDF" and "highDF" are the 95% confidence interval around the median estimate
- "AgMIP_AllDF" - results from all AgMIP studies
- "AgMIP_NoNDF - results from AgMIP studies that explicitly model nitrogen stress

The `gtap_spec` parameter in the `MimiMooreEtAlAgricultureImpacts.Agriculture` must be set to one of those five choices (as a string), which determines which damage function the component uses.


## The MimiMooreEtAlAgricultureImpacts package

The `MimiMooreEtAlAgricultureImpacts` package provides the following user-facing functions:

- `MimiMooreEtAlAgricultureImpacts.get_model(gtap; pulse=false)` returns a Mimi model with one component, the `MimiMooreEtAlAgricultureImpactsComponent` named :Agriculture in the model. The caller must specify which `gtap` dataframe they want to use for the damage function (must be one of five names associated with the five temperature/welfare dataframes from Fran Moore). The returned model has input parameters set to usg2 socioeconomics and a temperature pathway from DICE. If `pulse` is set to `true`, then the temperature parameter is set to a temperature path from DICE with an additional Gt of CO2 emissions in 2020. 
- `MimiMooreEtAlAgricultureImpacts.get_ag_scc(gtap; prtp=0.03)` calculates the Agricultural SCC for the specified `gtap` and pure rate of time preference discount rate `prtp`. It uses the DICE temperature pathway for the base run, and a pulsed temperature pathway from DICE with additional emissions in 2020 for the marginal run. So this function currently only calculates the SCC for 2020 because of the available pre-saved DICE pulsed temperature path.
- Not a function, but users can also access `MimiMooreEtAlAgricultureImpacts.Agriculture` which is the Mimi component id of the Mimi component defined in "src/MimiMooreEtAlAgricultureImpactsComponent.jl"

## Examples

- `examples/main.jl`: runs the agriculture component for each of the five gtaps and saves the values for % ag damages (the `AgLossGTAP` variable)
- `examples/main_scc.jl`: runs the base and pulsed versions of the model for each of the five gtaps and calculates and saves the resulting SCC for the ag sector
