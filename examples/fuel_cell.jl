using H2Gen

# Design definition
design = FuelCellDesignStruct(
    name = "PEM fuel cell",
    capacity_mw = 50.0,
    efficiency = 0.5,
    min_load = 0.2,
    max_load = 1.0,
)

# Static operation (single operating point)
op_static = FuelCellOperationStruct(static = true, power_output_mw = 20.0, duration_hours = 1.5)
static_out = FuelCellGen(design, op_static)
println("Fuel cell static outputs:")
println(static_out)

# Dynamic operation (time series)
time_hours = [1.0, 2.0, 1.0]
op_dynamic = FuelCellOperationStruct(static = false, power_output_mw = [5.0, 30.0, 60.0])
dynamic_out = FuelCellGen(time_hours, design, op_dynamic)
println("Fuel cell dynamic outputs:")
println(dynamic_out)
