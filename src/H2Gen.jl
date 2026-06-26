"""
H2Gen

Hydrogen conversion toolkit with a clean, struct-based API.
"""
module H2Gen

include("types.jl")
include("fuelcell_types.jl")
include("common.jl")
include("electrolyzer.jl")
include("fuelcell.jl")

# Preserve the historical H2Gen(...) API despite sharing the package/module name.
"""
    H2Gen(design::DesignStruct, operation::OperationStruct)

Run a static electrolyzer calculation. The operation must have `static=true`.
"""
function (m::Module)(design::DesignStruct, operation::OperationStruct)
    m === H2Gen || throw(MethodError(m, (design, operation)))
    return _run_h2gen(design, operation)
end

"""
    H2Gen(time_hours, design::DesignStruct, operation::OperationStruct)

Run a dynamic electrolyzer calculation. The operation must have `static=false`.
`time_hours` is a vector of durations for each step.
"""
function (m::Module)(
    time_hours::AbstractVector{<:Real},
    design::DesignStruct,
    operation::OperationStruct,
)
    m === H2Gen || throw(MethodError(m, (time_hours, design, operation)))
    return _run_h2gen(time_hours, design, operation)
end

export DesignStruct, OperationStruct
export StaticOutputs, DynamicOutputs
export FuelCellDesignStruct, FuelCellOperationStruct
export FuelCellStaticOutputs, FuelCellDynamicOutputs
export H2Gen
export FuelCellGen

end
