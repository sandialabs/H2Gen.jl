# Theory

## Scope

`H2Gen` models electrolyzers and fuel cells as first-order energy-conversion blocks.  
The intent is lightweight operational analysis (static or time series), not electrochemistry-level stack simulation.

## Electrolyzer model

Inputs:

- Rated power: `capacity_mw`
- Load limits: `min_load`, `max_load`
- Constant efficiency: `efficiency`
- Requested electric power: `power_input_mw`

Per time step:

- `P_used = min(max(power_input_mw, 0), capacity_mw * max_load)`
- If `P_used < capacity_mw * min_load`, then `P_used = 0`
- `H2_out = P_used * efficiency`

## Fuel cell model

Inputs:

- Rated electric output: `capacity_mw`
- Load limits: `min_load`, `max_load`
- Constant net electric efficiency (LHV basis): `efficiency`
- Requested electric output: `power_output_mw`

Per time step:

- `P_gen = min(max(power_output_mw, 0), capacity_mw * max_load)`
- If `P_gen < capacity_mw * min_load`, then `P_gen = 0`
- `H2_in = P_gen / efficiency`
- `eta_fc = P_gen / H2_in` (by construction, equals `efficiency` when on)

## Dynamic aggregation

Given `time_hours[i] = Delta t_i`:

- Energy totals: `E = sum(P_i * Delta t_i)`
- Electrolyzer aggregate efficiency: `sum(H2_out_i * Delta t_i) / sum(P_used_i * Delta t_i)`
- Fuel cell aggregate efficiency: `sum(P_gen_i * Delta t_i) / sum(H2_in_i * Delta t_i)`
- Average utilization: time-weighted mean of `P_i / capacity_mw`

## Assumptions and limitations

- Efficiency is constant, so voltage-current polarization effects are not resolved.
- Startup/shutdown transients and ramp rates are not modeled.
- Hydrogen quality, pressure, temperature, and degradation are not modeled.
- This fidelity is suitable for dispatch-scale studies where first-order conversion is sufficient.

## Literature basis

- EG&G Technical Services, *Fuel Cell Handbook* (7th ed., DOE/NETL-2004/1206): standard fuel-cell efficiency definition and thermodynamic basis (`eta = W_net / Delta H_dot`).
  Link: <https://www.netl.doe.gov/projects/files/FuelCellHandbook7.pdf>
- U.S. DOE HFTO, *Comparison of Fuel Cell Technologies*: representative electrical efficiency ranges that support selecting fixed-efficiency values for system studies.
  Link: <https://www.energy.gov/eere/fuelcells/comparison-fuel-cell-technologies>
- E. Rousis et al. (2024), *Energy Conversion and Management: X* 24, 100561: reduced-order design/operation optimization formulation that links hydrogen consumption and electrical output with fixed/stepwise efficiency assumptions.
  Link: <https://doi.org/10.1016/j.ecmx.2024.100561>
