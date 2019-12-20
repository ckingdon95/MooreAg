# Returns a copy of the MooreAg model with the AgricultureMC component
# instead of the Agriculture component. To be used in Monte Carlo simulations
function get_mcs_model(; pulse::Bool=false,
    floor_on_damages::Bool = true,
    ceiling_on_benefits::Bool = false)

    m = get_model("midDF"; pulse=pulse)
    disconnect_param!(m, :Agriculture, :gtap_df_all)
    replace_comp!(m, AgricultureMC, :Agriculture)
    set_param!(m, :Agriculture, :gtap_df_all_mcs, gtap_df_all_mcs)

    # for some reason have to reset these parameters because the defaults get reset by the replace_comp!
    set_param!(m, :Agriculture, :floor_on_damages, floor_on_damages)    
    set_param!(m, :Agriculture, :ceiling_on_benefits, ceiling_on_benefits)
    return m
end

# Post trial function for calculating the SCC during Monte Carlo simulations
function post_trial_scc(mcs::SimulationInstance, trialnum::Int, ntimesteps::Int, tup::Nothing)
    base_m, pulse_m = mcs.models
    prtp, SCC = Mimi.payload(mcs)
    ag_scc = _calculate_ag_scc(base_m, pulse_m, prtp)
    SCC[trialnum] = ag_scc
end

function run_mcs(variant, N; prtp, floor_on_damages=true, ceiling_on_benefits=false)

    # Get the base and marginal models
    base_m = MooreAg.get_mcs_model(floor_on_damages=floor_on_damages, ceiling_on_benefits=ceiling_on_benefits) 
    pulse_m = MooreAg.get_mcs_model(pulse=true, floor_on_damages=floor_on_damages, ceiling_on_benefits=ceiling_on_benefits)

    # Get the simulation definition
    simdef = MooreAg.get_simdef(variant)
    Mimi.set_payload!(simdef, (prtp, zeros(N)))

    # Run and return output
    sim = run(simdef, [base_m, pulse_m], N; post_trial_func = MooreAg.post_trial_scc)
    SCC = Mimi.payload(sim)[2]
    return (sim, SCC)
end