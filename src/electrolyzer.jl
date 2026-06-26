"""
    H2Gen(design::DesignStruct, operation::OperationStruct)

Run a static electrolyzer calculation. The operation must have `static=true`.
"""
function _run_h2gen(design::DesignStruct, operation::OperationStruct)
    operation.static || throw(ArgumentError("static H2Gen expects operation.static = true"))
    T = promote_type(typeof(design.capacity_mw), typeof(operation.power_input_mw), typeof(operation.duration_hours))
    power_requested = convert(T, operation.power_input_mw)
    power_used = _power_used(design, power_requested)
    h2_output = power_used * design.efficiency
    effective_eff = power_used > zero(power_used) ? h2_output / power_used : zero(power_used)
    utilization = _utilization(design, power_used)
    power_used_mwh = power_used * operation.duration_hours
    h2_output_mwh = h2_output * operation.duration_hours
    return StaticOutputs(
        power_requested,
        power_used,
        h2_output,
        effective_eff,
        utilization,
        power_used_mwh,
        h2_output_mwh,
    )
end

"""
    H2Gen(time_hours, design::DesignStruct, operation::OperationStruct)

Run a dynamic electrolyzer calculation. The operation must have `static=false`.
`time_hours` is a vector of durations for each step.
"""
function _run_h2gen(time_hours::AbstractVector{<:Real}, design::DesignStruct, operation::OperationStruct)
    operation.static && throw(ArgumentError("dynamic H2Gen expects operation.static = false"))
    power_req = operation.power_input_mw
    power_req isa AbstractVector{<:Real} ||
        throw(ArgumentError("dynamic H2Gen expects power_input_mw to be a vector"))
    length(time_hours) == length(power_req) ||
        throw(ArgumentError("time_hours and power_input_mw must have the same length"))

    T = promote_type(typeof(design.capacity_mw), eltype(time_hours), eltype(power_req))
    time = collect(T.(time_hours))
    any(t -> t <= zero(T), time) && throw(ArgumentError("time_hours must be positive"))

    power_requested = collect(T.(power_req))
    n = length(power_requested)

    power_used = Vector{T}(undef, n)
    h2_output = Vector{T}(undef, n)
    eff = Vector{T}(undef, n)
    util = Vector{T}(undef, n)

    for i in 1:n
        used = _power_used(design, power_requested[i])
        power_used[i] = used
        h2_output[i] = used * design.efficiency
        eff[i] = used > zero(T) ? h2_output[i] / used : zero(T)
        util[i] = _utilization(design, used)
    end

    total_power_used = _time_weighted_sum(power_used, time)
    total_h2_output = _time_weighted_sum(h2_output, time)
    aggregate_eff = total_power_used > zero(T) ? total_h2_output / total_power_used : zero(T)
    average_util = _time_weighted_average(util, time)

    return DynamicOutputs(
        time,
        power_requested,
        power_used,
        h2_output,
        util,
        eff,
        total_power_used,
        total_h2_output,
        aggregate_eff,
        average_util,
    )
end

function _power_used(design::DesignStruct, power_requested::T) where {T<:Real}
    power_requested <= zero(T) && return zero(T)
    cap_max = design.capacity_mw * design.max_load
    cap_min = design.capacity_mw * design.min_load
    used = min(power_requested, cap_max)
    if used < cap_min
        return zero(T)
    end
    return used
end

function _utilization(design::DesignStruct, power_used::T) where {T<:Real}
    design.capacity_mw <= zero(design.capacity_mw) && return zero(T)
    return power_used / design.capacity_mw
end
