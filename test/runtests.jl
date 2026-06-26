using Test
using H2Gen

@testset "H2Gen" begin
    include("test_electrolyzer.jl")
    include("test_fuel_cell.jl")
end
