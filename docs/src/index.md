# H2Gen

`H2Gen` is a lightweight hydrogen conversion toolkit with a clean, struct-based API.
It supports two first-order device models:

- Electrolyzer mode (`H2Gen`): electricity to hydrogen.
- Fuel cell mode (`FuelCellGen`): hydrogen to electricity.

## Quick start

```julia
using H2Gen

# Electrolyzer
el_design = DesignStruct(
    name = "PEM electrolyzer",
    capacity_mw = 100.0,
    efficiency = 0.69,
    min_load = 0.2,
    max_load = 1.0,
)
el_op = OperationStruct(static = true, power_input_mw = 50.0, duration_hours = 1.0)
el_out = H2Gen(el_design, el_op)

# Fuel cell
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

For dynamic mode, pass `static = false`, a vector input in the operation struct, and a same-length `time_hours` vector.

## API

Electrolyzer API:

- `DesignStruct`
- `OperationStruct`
- `H2Gen`
- `StaticOutputs`
- `DynamicOutputs`

Fuel cell API:

- `FuelCellDesignStruct`
- `FuelCellOperationStruct`
- `FuelCellGen`
- `FuelCellStaticOutputs`
- `FuelCellDynamicOutputs`

## Model theory

- See [Theory](theory.md) for equations, assumptions, and literature basis.
