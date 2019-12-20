# MC simulation with only yield uncertainty
simdef1 = @defsim begin
    yield_scale = Uniform(0., 1.)

    save(
        Agriculture.agcost, 
        Agriculture.agcost_global, 
        Agriculture.AgLossGTAP,
        Agriculture.temp,
        Agriculture.agel,
        Agriculture.yield_scale
    )
end

# MC simulation with yield uncertainty and the FUND distribution on the 
# elasticity parameter `agel`
simdef2 = @defsim begin
    yield_scale = Uniform(0., 1.)
    agel = Truncated(Normal(0.31,0.15), 0.0, 1.0)

    save(
        Agriculture.agcost, 
        Agriculture.agcost_global, 
        Agriculture.AgLossGTAP,
        Agriculture.temp,
        Agriculture.agel,
        Agriculture.yield_scale
    )
end

function get_simdef(variant = :yield_only)
    if variant == :yield_only
        return deepcopy(simdef1)
    elseif variant == :full
        return deepcopy(simdef2)
    else
        error("Unknown simdef variant $variant")
    end
end
