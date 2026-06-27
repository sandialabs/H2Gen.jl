# H2Gen

[![DOI](https://joss.theoj.org/papers/10.21105/joss.06619/status.svg)](https://doi.org/10.21105/joss.06619)

`H2Gen` is a lightweight hydrogen conversion toolkit with a clean, struct-based API.
It provides static and dynamic calculations for:

- Electrolyzer mode (`H2Gen`): electricity to hydrogen.
- Fuel cell mode (`FuelCellGen`): hydrogen to electricity.

No JuMP or optimization dependencies are required.

## Installation

`H2Gen` is distributed as an unregistered Julia package:

```julia
using Pkg
Pkg.add(url = "https://github.com/sandialabs/H2Gen.jl")
```

For local development from a checkout:

```julia
using Pkg
Pkg.develop(path = "/path/to/H2gen.jl")
```

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

Dynamic mode is available for both devices by passing `static = false` operations with vectors and a matching `time_hours` vector.

## Theory and fidelity

At the current package fidelity, both devices are represented as algebraic conversion models with:

- Constant conversion efficiency.
- Minimum and maximum load fractions.
- Optional time-step weighting for dynamic runs.

Electrolyzer equations:

- `P_used = clamp(P_req, 0, capacity_mw * max_load)` with shutdown if `P_used < capacity_mw * min_load`.
- `H2_out = P_used * efficiency`.

Fuel cell equations (LHV-basis efficiency):

- `P_gen = clamp(P_req, 0, capacity_mw * max_load)` with shutdown if `P_gen < capacity_mw * min_load`.
- `H2_in = P_gen / efficiency`.

This fuel-cell formulation follows the standard net electrical efficiency definition (`eta = P_elec / E_H2,in`) used in fuel-cell literature and in reduced-order energy system models.

## Literature basis for the fuel-cell model

- EG&G Technical Services, *Fuel Cell Handbook* (7th ed., DOE/NETL-2004/1206): efficiency definition and thermodynamic basis for fuel-cell conversion.
  Link: https://www.netl.doe.gov/projects/files/FuelCellHandbook7.pdf
- U.S. DOE HFTO, *Comparison of Fuel Cell Technologies*: representative electric efficiencies for major fuel-cell classes.
  Link: https://www.energy.gov/eere/fuelcells/comparison-fuel-cell-technologies
- E. Rousis et al., *Design and operation optimization of integrated PEM and SOFC systems...*, *Energy Conversion and Management: X* 24 (2024): example reduced-order fuel-cell operation model linking hydrogen consumption to electrical output and fixed/stepwise efficiency assumptions.
  Link: https://doi.org/10.1016/j.ecmx.2024.100561

## Cite

If you find `H2Gen` useful in your work, please cite:

```bibtex
@article{hellemo2024energymodelsx,
  title = {EnergyModelsX: Flexible Energy Systems Modelling with Multiple Dispatch},
  author = {Hellemo, Lars and B{\o}dal, Espen Flo and Holm, Sigmund Eggen and Pinel, Dimitri and Straus, Julian},
  journal = {Journal of Open Source Software},
  volume = {9},
  number = {97},
  pages = {6619},
  year = {2024},
  doi = {https://doi.org/10.21105/joss.06619},
}
```
