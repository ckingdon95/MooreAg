# Moore et al Agriculture Damages

This repository defines a Mimi component `Agriculture` as well as a wrapping module `MooreAg` with additional helping functionality. Code is based on Moore et al's agricultural damage functions from the associated paper included in the `papers` folder.

## The Agriculture Component

The `Agriculture` component is a Mimi component implementing Moore et al's agricultural damage function. The component is defined in "src/AgricultureComponent.jl". It has a parameter called `gtap` which is a 16 x 3 Array of percent welfare impact data (16 FUND regions x 3 temperature points). In the run_timestep function, this component takes temperature for that timestep and uses the gtap dataframe to linearly interpolate or extrapolate to get the percent impact for that timestep, saved in variable `AgLossGTAP`. 

## The MooreAg module

The `MooreAg` module is loaded from "src/MooreAg.jl" and has the following available functions:

- `MooreAg.get_model(gtap; pulse=false)` returns a Mimi model with one component, the `MooreAgComponent` named :agriculture in the model. The caller must specify which `gtap` dataframe they want to use for the damage function (must be one of five names associated with the five temperature/welfare dataframes from Fran Moore). The returned model has input parameters set to usg2 socioeconomics and a temperature pathway from DICE. If `pulse` is set to `true`, then the temperature parameter is set to a temperature path from DICE with an additional Gt of CO2 emissions in 2020. 
- `MooreAg.get_ag_scc(gtap; rate=0.03)` calculates the Agricultural SCC for the specified `gtap` and discount rate. It uses the DICE temperature pathway for the base run, and a pulsed temperature pathway from DICE with additional emissions in 2020 for the marginal run. So this function currently only calculates the SCC for 2020 because of the available pre-saved DICE pulsed temperature path.
- Not a function, but users can also access `MooreAg.Agriculture` which is the Mimi component id of the Mimi component defined in "src/MooreAgComponent.jl"

## Examples:

- `examples/main.jl`: runs the agriculture component for each of the five gtaps and saves the values for % ag damages (the `AgLossGTAP` variable)
- `examples/main_scc.jl`: runs the base and pulsed versions of the model for each of the five gtaps and calculates and saves the resulting SCC for the ag sector
