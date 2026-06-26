"""
    FuelCellGen(design::FuelCellDesignStruct, operation::FuelCellOperationStruct)

Run a static fuel cell calculation. The operation must have `static=true`.
"""
function FuelCellGen(design::FuelCellDesignStruct, operation::FuelCellOperationStruct)
    operation.static || throw(ArgumentError("static FuelCellGen expects operation.static = true"))
    T = promote_type(typeof(design.capacity_mw), typeof(operation.power_output_mw), typeof(operation.duration_hours))
    power_requested = convert(T, operation.power_output_mw)
    power_generated = _power_generated(design, power_requested)
    h2_input = power_generated > zero(T) ? power_generated / design.efficiency : zero(T)
    effective_eff = h2_input > zero(T) ? power_generated / h2_input : zero(T)
    utilization = _utilization(design, power_generated)
    power_generated_mwh = power_generated * operation.duration_hours
    h2_input_mwh = h2_input * operation.duration_hours
    return FuelCellStaticOutputs(
        power_requested,
        power_generated,
        h2_input,
        effective_eff,
        utilization,
        power_generated_mwh,
        h2_input_mwh,
    )
end

"""
    FuelCellGen(time_hours, design::FuelCellDesignStruct, operation::FuelCellOperationStruct)

Run a dynamic fuel cell calculation. The operation must have `static=false`.
`time_hours` is a vector of durations for each step.
"""
function FuelCellGen(
    time_hours::AbstractVector{<:Real},
    design::FuelCellDesignStruct,
    operation::FuelCellOperationStruct,
)
    operation.static && throw(ArgumentError("dynamic FuelCellGen expects operation.static = false"))
    power_req = operation.power_output_mw
    power_req isa AbstractVector{<:Real} ||
        throw(ArgumentError("dynamic FuelCellGen expects power_output_mw to be a vector"))
    length(time_hours) == length(power_req) ||
        throw(ArgumentError("time_hours and power_output_mw must have the same length"))

    T = promote_type(typeof(design.capacity_mw), eltype(time_hours), eltype(power_req))
    time = collect(T.(time_hours))
    any(t -> t <= zero(T), time) && throw(ArgumentError("time_hours must be positive"))

    power_requested = collect(T.(power_req))
    n = length(power_requested)

    power_generated = Vector{T}(undef, n)
    h2_input = Vector{T}(undef, n)
    eff = Vector{T}(undef, n)
    util = Vector{T}(undef, n)

    for i in 1:n
        generated = _power_generated(design, power_requested[i])
        power_generated[i] = generated
        h2_input[i] = generated > zero(T) ? generated / design.efficiency : zero(T)
        eff[i] = h2_input[i] > zero(T) ? generated / h2_input[i] : zero(T)
        util[i] = _utilization(design, generated)
    end

    total_power_generated = _time_weighted_sum(power_generated, time)
    total_h2_input = _time_weighted_sum(h2_input, time)
    aggregate_eff = total_h2_input > zero(T) ? total_power_generated / total_h2_input : zero(T)
    average_util = _time_weighted_average(util, time)

    return FuelCellDynamicOutputs(
        time,
        power_requested,
        power_generated,
        h2_input,
        util,
        eff,
        total_power_generated,
        total_h2_input,
        aggregate_eff,
        average_util,
    )
end

function _power_generated(design::FuelCellDesignStruct, power_requested::T) where {T<:Real}
    power_requested <= zero(T) && return zero(T)
    cap_max = design.capacity_mw * design.max_load
    cap_min = design.capacity_mw * design.min_load
    generated = min(power_requested, cap_max)
    if generated < cap_min
        return zero(T)
    end
    return generated
end

function _utilization(design::FuelCellDesignStruct, power_generated::T) where {T<:Real}
    design.capacity_mw <= zero(design.capacity_mw) && return zero(T)
    return power_generated / design.capacity_mw
end
