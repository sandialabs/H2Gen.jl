"""
Design parameters for a fuel cell.
`efficiency` is the net electrical efficiency (electric output / hydrogen energy input).
"""
struct FuelCellDesignStruct{T<:Real}
    name::String
    capacity_mw::T
    efficiency::T
    min_load::T
    max_load::T

    function FuelCellDesignStruct(
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
        _validate_fuelcell_design(cap, eff, minl, maxl)
        return new{T}(name, cap, eff, minl, maxl)
    end
end

FuelCellDesignStruct(; name="fuel_cell", capacity_mw, efficiency, min_load=0.0, max_load=1.0) =
    FuelCellDesignStruct(String(name), capacity_mw, efficiency, min_load, max_load)

"""
Operational inputs for a fuel cell run.
"""
struct FuelCellOperationStruct{T,U<:Real}
    static::Bool
    power_output_mw::T
    duration_hours::U

    function FuelCellOperationStruct(
        static::Bool,
        power_output_mw::T,
        duration_hours::Real,
    ) where {T}
        U = typeof(duration_hours)
        dur = convert(U, duration_hours)
        _validate_fuelcell_operation(static, power_output_mw, dur)
        return new{T,U}(static, power_output_mw, dur)
    end
end

FuelCellOperationStruct(; static::Bool, power_output_mw, duration_hours=1.0) =
    FuelCellOperationStruct(static, power_output_mw, duration_hours)

"""
Outputs for a static fuel cell run.
"""
struct FuelCellStaticOutputs{T<:Real}
    power_requested_mw::T
    power_generated_mw::T
    h2_input_mw::T
    effective_efficiency::T
    capacity_utilization::T
    power_generated_mwh::T
    h2_input_mwh::T
end

"""
Outputs for a dynamic fuel cell run.
"""
struct FuelCellDynamicOutputs{T<:Real}
    time_hours::Vector{T}
    power_requested_mw::Vector{T}
    power_generated_mw::Vector{T}
    h2_input_mw::Vector{T}
    capacity_utilization::Vector{T}
    effective_efficiency::Vector{T}
    total_power_generated_mwh::T
    total_h2_input_mwh::T
    aggregate_efficiency::T
    average_utilization::T
end

function _validate_fuelcell_design(
    capacity_mw::T,
    efficiency::T,
    min_load::T,
    max_load::T,
) where {T<:Real}
    capacity_mw < zero(T) && throw(ArgumentError("capacity_mw must be non-negative"))
    (efficiency <= zero(T) || efficiency > one(T)) &&
        throw(ArgumentError("fuel cell efficiency must be within (0, 1]"))
    min_load < zero(T) && throw(ArgumentError("min_load must be non-negative"))
    max_load < min_load && throw(ArgumentError("max_load must be >= min_load"))
    max_load > one(T) && throw(ArgumentError("max_load must be <= 1"))
    return nothing
end

function _validate_fuelcell_operation(static::Bool, power_output_mw, duration_hours::T) where {T<:Real}
    duration_hours <= zero(T) && throw(ArgumentError("duration_hours must be positive"))
    if static
        power_output_mw isa Real ||
            throw(ArgumentError("static FuelCellOperationStruct expects power_output_mw::Real"))
    else
        power_output_mw isa AbstractVector{<:Real} ||
            throw(
                ArgumentError(
                    "dynamic FuelCellOperationStruct expects power_output_mw::AbstractVector{<:Real}",
                ),
            )
    end
    return nothing
end
