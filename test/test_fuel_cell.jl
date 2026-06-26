using Test
using H2Gen
using ForwardDiff
using FiniteDiff

@testset "Fuel cell static outputs" begin
    design = FuelCellDesignStruct(
        name = "PEM fuel cell",
        capacity_mw = 50.0,
        efficiency = 0.5,
        min_load = 0.2,
        max_load = 1.0,
    )

    op = FuelCellOperationStruct(static = true, power_output_mw = 20.0, duration_hours = 2.0)
    out = FuelCellGen(design, op)

    @test out.power_requested_mw == 20.0
    @test out.power_generated_mw == 20.0
    @test isapprox(out.h2_input_mw, 40.0)
    @test isapprox(out.effective_efficiency, 0.5)
    @test isapprox(out.capacity_utilization, 0.4)
    @test out.power_generated_mwh == 40.0
    @test isapprox(out.h2_input_mwh, 80.0)

    op_low = FuelCellOperationStruct(static = true, power_output_mw = 5.0, duration_hours = 1.0)
    out_low = FuelCellGen(design, op_low)
    @test out_low.power_generated_mw == 0.0
    @test out_low.h2_input_mw == 0.0
end

@testset "Fuel cell dynamic outputs" begin
    design = FuelCellDesignStruct(
        name = "PEM fuel cell",
        capacity_mw = 50.0,
        efficiency = 0.5,
        min_load = 0.2,
        max_load = 1.0,
    )

    time_hours = [1.0, 2.0, 1.0]
    op = FuelCellOperationStruct(static = false, power_output_mw = [5.0, 30.0, 60.0])
    out = FuelCellGen(time_hours, design, op)

    @test out.power_generated_mw == [0.0, 30.0, 50.0]
    @test all(isapprox.(out.h2_input_mw, [0.0, 60.0, 100.0]))
    @test all(isapprox.(out.capacity_utilization, [0.0, 0.6, 1.0]))
    @test isapprox(out.total_power_generated_mwh, 110.0)
    @test isapprox(out.total_h2_input_mwh, 220.0)
    @test isapprox(out.aggregate_efficiency, 0.5)
    @test isapprox(out.average_utilization, 0.55)
end

@testset "Fuel cell AD vs FD" begin
    design = FuelCellDesignStruct(
        name = "PEM fuel cell",
        capacity_mw = 50.0,
        efficiency = 0.5,
        min_load = 0.2,
        max_load = 1.0,
    )

    h2_input(power_output_mw) = FuelCellGen(design, FuelCellOperationStruct(static = true, power_output_mw = power_output_mw, duration_hours = 1.0)).h2_input_mw

    d_ad = ForwardDiff.derivative(h2_input, 20.0)
    d_fd = FiniteDiff.finite_difference_derivative(h2_input, 20.0, Val(:central))
    @test isfinite(d_ad)
    @test isfinite(d_fd)
    @test isapprox(d_ad, d_fd; rtol = 1e-8, atol = 1e-10)
end

@testset "Fuel cell argument validation" begin
    design = FuelCellDesignStruct(
        name = "PEM fuel cell",
        capacity_mw = 50.0,
        efficiency = 0.5,
        min_load = 0.2,
        max_load = 1.0,
    )

    op_static = FuelCellOperationStruct(static = true, power_output_mw = 20.0, duration_hours = 1.0)
    @test_throws ArgumentError FuelCellGen([1.0, 1.0], design, op_static)

    op_dynamic = FuelCellOperationStruct(static = false, power_output_mw = [20.0, 30.0])
    @test_throws ArgumentError FuelCellGen([1.0], design, op_dynamic)

    @test_throws ArgumentError FuelCellDesignStruct(
        name = "invalid fuel cell",
        capacity_mw = 50.0,
        efficiency = 0.0,
        min_load = 0.2,
        max_load = 1.0,
    )
end
