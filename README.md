# MooreAg

The `MooreAg` package defines an `Agriculture` component to be used in Integrated Assessment Models within the [Mimi Framework](https://github.com/mimiframework/Mimi.jl). In addition to the component definition, this package also provides helper functions for using and running the component. Code is based on the agricultural damage functions from a [2017 paper in Nature Communications](https://www.nature.com/articles/s41467-017-01792-x) by Moore et al.

Please see the [documentation]("github.com/ckingdon95/MooreAg.jl.git") for a full description of the component.

## Installation

If you are new to the Julia language or to the Mimi software package, please see the [Mimi documentation](https://www.mimiframework.org/Mimi.jl/stable/installation/) for installation of Julia and Mimi.

`MooreAg` is a Julia package registered on the [MimiRegistry](https://github.com/mimiframework/MimiRegistry). To add the `MooreAg` package, you must already have the MimiRegistry added to your system. From a Julia package REPL, run the following. You only need to run the first line once on your system. In the second line, we recommend that you also add the Mimi package, so that you can use additional Mimi functionality.
```
pkg> registry add https://github.com/mimiframework/MimiRegistry.git
pkg> add MooreAg, Mimi
```

## Example use
See documentation for a full description of the available functionality.
```
using MooreAg, Mimi

m = MooreAg.get_model("midDF")  # specify which of the 5 available GTAP dataframes of temperature-welfare results to use for the damage function
run(m)
explore(m)

update_param!(m, :gtap_spec, "lowDF")   # update the specification for which GTAP dataframe to use
run(m)
explore(m)

ag_scc = MooreAg.get_ag_scc("midDF", prtp=0.03)
```

## Component description

Input parameters:
- `income`
- `population`
- `temp`: global temperature series
- `gtap_spec`: A `String` specifying which GTAP temperature-welfare results dataframe from Moore et al to use for the damage function. Must be one of `"AgMIP_AllDF"`, `"AgMIP_NoNDF"`, `"highDF"`, `"lowDF"`, or `"midDF"`. See documentation for a description of these choices.
- `gtap_df_all`: Holds temperature-welfare data for all five `gtap_spec` choices. Only the one specified by `gtap_spec` will be used when the component is run
- `floor_on_damages`: A `Bool` specifying whether or not to limit damages (the `agcost` variable) to 100% of the size of the agricultural sector. Default value is `true`.
- `ceiling_on_benefits`: A `Bool` specifying whether or not to limit benefits (the `agcost` variable) to 100% of the size of the agricultural sector. Default value is `false`.
- `agrish0`: Initial agricultural share of GDP
- `agel`: elasticity
- `gdp90`
- `pop90`

Calculated variables:
- `AgLossGTAP`: Percent impact on the agricultural sector in each year
- `agcost`: Total impact on the agricultural sector in each year. (A negative value means damages, positive values mean benefits.)
- `gtap_df`: The selected temperature-welfare data used for the damage function, specified by the `gtap_spec` parameter, selected from all the data held in `gtap_df_all`
