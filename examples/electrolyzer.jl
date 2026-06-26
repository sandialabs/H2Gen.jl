using H2Gen

# Design definition
design = DesignStruct(
    name = "PEM",
    capacity_mw = 100.0,
    efficiency = 0.69,
    min_load = 0.2,
    max_load = 1.0,
)

# Static operation (single operating point)
op_static = OperationStruct(static = true, power_input_mw = 50.0, duration_hours = 1.0)
static_out = H2Gen(design, op_static)
println("Static outputs:")
println(static_out)

# Dynamic operation (time series)
time_hours = [1.0, 2.0, 1.0]
op_dynamic = OperationStruct(static = false, power_input_mw = [10.0, 50.0, 120.0])
dynamic_out = H2Gen(time_hours, design, op_dynamic)
println("Dynamic outputs:")
println(dynamic_out)
