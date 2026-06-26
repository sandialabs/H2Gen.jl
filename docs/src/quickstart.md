# Quick Start

`H2Gen` contains matching first-order models for electrolyzers and fuel cells.
The public interface is struct-based and keeps power, duration, efficiency, and
minimum/maximum loading explicit.

```julia
using H2Gen

el_design = DesignStruct(
    name = "PEM electrolyzer",
    capacity_mw = 100.0,
    efficiency = 0.69,
    min_load = 0.2,
    max_load = 1.0,
)
el_op = OperationStruct(static = true, power_input_mw = 50.0, duration_hours = 1.0)
el_out = H2Gen(el_design, el_op)

fc_design = FuelCellDesignStruct(
    name = "PEM fuel cell",
    capacity_mw = 50.0,
    efficiency = 0.5,
    min_load = 0.2,
    max_load = 1.0,
)
fc_op = FuelCellOperationStruct(static = true, power_output_mw = 20.0, duration_hours = 1.0)
fc_out = FuelCellGen(fc_design, fc_op)
```

For SIRENOpt integration, the electrolyzer consumes electrical power and produces
hydrogen inventory, while the fuel cell consumes hydrogen and produces electrical
power. Storage is intentionally separate so tank, battery, and dispatch logic can
be optimized independently.
