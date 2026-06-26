# Running the examples

You can run the electrolyzer example from the Julia REPL with:

```julia
using H2Gen

exdir = joinpath(pkgdir(H2Gen), "examples")
include(joinpath(exdir, "electrolyzer.jl"))
```

You can run the fuel cell example with:

```julia
using H2Gen

exdir = joinpath(pkgdir(H2Gen), "examples")
include(joinpath(exdir, "fuel_cell.jl"))
```
