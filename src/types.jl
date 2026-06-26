"""
Design parameters for an electrolyzer.
"""
struct DesignStruct{T<:Real}
    name::String
    capacity_mw::T
    efficiency::T
    min_load::T
    max_load::T

    function DesignStruct(
        name::String,
        capacity_mw::Real,
        efficiency::Real,
        min_load::Real,
        max_load::Real,
    )
        T = promote_type(typeof(capacity_mw), typeof(efficiency), typeof(min_load), typeof(max_load))
        cap = convert(T, capacity_mw)
        eff = convert(T, efficiency)
        minl = convert(T, min_load)
        maxl = convert(T, max_load)
        _validate_design(cap, eff, minl, maxl)
        return new{T}(name, cap, eff, minl, maxl)
    end
end

DesignStruct(; name="electrolyzer", capacity_mw, efficiency, min_load=0.0, max_load=1.0) =
    DesignStruct(String(name), capacity_mw, efficiency, min_load, max_load)

"""
Operational inputs for an electrolyzer run.
"""
struct OperationStruct{T,U<:Real}
    static::Bool
    power_input_mw::T
    duration_hours::U

    function OperationStruct(
        static::Bool,
        power_input_mw::T,
        duration_hours::Real,
    ) where {T}
        U = typeof(duration_hours)
        dur = convert(U, duration_hours)
        _validate_operation(static, power_input_mw, dur)
        return new{T,U}(static, power_input_mw, dur)
    end
end

OperationStruct(; static::Bool, power_input_mw, duration_hours=1.0) =
    OperationStruct(static, power_input_mw, duration_hours)

"""
Outputs for a static electrolyzer run.
"""
struct StaticOutputs{T<:Real}
    power_requested_mw::T
    power_used_mw::T
    h2_output_mw::T
    effective_efficiency::T
    capacity_utilization::T
    power_used_mwh::T
    h2_output_mwh::T
end

"""
Outputs for a dynamic electrolyzer run.
"""
struct DynamicOutputs{T<:Real}
    time_hours::Vector{T}
    power_requested_mw::Vector{T}
    power_used_mw::Vector{T}
    h2_output_mw::Vector{T}
    capacity_utilization::Vector{T}
    effective_efficiency::Vector{T}
    total_power_used_mwh::T
    total_h2_output_mwh::T
    aggregate_efficiency::T
    average_utilization::T
end

function _validate_design(capacity_mw::T, efficiency::T, min_load::T, max_load::T) where {T<:Real}
    capacity_mw < zero(T) && throw(ArgumentError("capacity_mw must be non-negative"))
    (efficiency < zero(T) || efficiency > one(T)) && throw(ArgumentError("efficiency must be within [0, 1]"))
    min_load < zero(T) && throw(ArgumentError("min_load must be non-negative"))
    max_load < min_load && throw(ArgumentError("max_load must be >= min_load"))
    max_load > one(T) && throw(ArgumentError("max_load must be <= 1"))
    return nothing
end

function _validate_operation(static::Bool, power_input_mw, duration_hours::T) where {T<:Real}
    duration_hours <= zero(T) && throw(ArgumentError("duration_hours must be positive"))
    if static
        power_input_mw isa Real || throw(ArgumentError("static OperationStruct expects power_input_mw::Real"))
    else
        power_input_mw isa AbstractVector{<:Real} ||
            throw(ArgumentError("dynamic OperationStruct expects power_input_mw::AbstractVector{<:Real}"))
    end
    return nothing
end
