using Test
using H2Gen
using ForwardDiff
using FiniteDiff

@testset "Static outputs" begin
    design = DesignStruct(
        name = "PEM",
        capacity_mw = 100.0,
        efficiency = 0.7,
        min_load = 0.2,
        max_load = 1.0,
    )

    op = OperationStruct(static = true, power_input_mw = 50.0, duration_hours = 2.0)
    out = H2Gen(design, op)

    @test out.power_requested_mw == 50.0
    @test out.power_used_mw == 50.0
    @test isapprox(out.h2_output_mw, 35.0)
    @test isapprox(out.effective_efficiency, 0.7)
    @test isapprox(out.capacity_utilization, 0.5)
    @test out.power_used_mwh == 100.0
    @test isapprox(out.h2_output_mwh, 70.0)

    op_low = OperationStruct(static = true, power_input_mw = 10.0, duration_hours = 1.0)
    out_low = H2Gen(design, op_low)
    @test out_low.power_used_mw == 0.0
    @test out_low.h2_output_mw == 0.0
end

@testset "Dynamic outputs" begin
    design = DesignStruct(
        name = "PEM",
        capacity_mw = 100.0,
        efficiency = 0.7,
        min_load = 0.2,
        max_load = 1.0,
    )

    time_hours = [1.0, 2.0, 1.0]
    op = OperationStruct(static = false, power_input_mw = [10.0, 50.0, 120.0])
    out = H2Gen(time_hours, design, op)

    @test out.power_used_mw == [0.0, 50.0, 100.0]
    @test all(isapprox.(out.h2_output_mw, [0.0, 35.0, 70.0]))
    @test all(isapprox.(out.capacity_utilization, [0.0, 0.5, 1.0]))
    @test out.total_power_used_mwh == 200.0
    @test isapprox(out.total_h2_output_mwh, 140.0)
    @test isapprox(out.aggregate_efficiency, 0.7)
    @test isapprox(out.average_utilization, 0.5)
end

@testset "Electrolyzer AD vs FD" begin
    design = DesignStruct(
        name = "PEM",
        capacity_mw = 100.0,
        efficiency = 0.7,
        min_load = 0.2,
        max_load = 1.0,
    )

    h2_output(power_input_mw) = H2Gen(design, OperationStruct(static = true, power_input_mw = power_input_mw, duration_hours = 1.0)).h2_output_mw

    d_ad = ForwardDiff.derivative(h2_output, 50.0)
    d_fd = FiniteDiff.finite_difference_derivative(h2_output, 50.0, Val(:central))
    @test isfinite(d_ad)
    @test isfinite(d_fd)
    @test isapprox(d_ad, d_fd; rtol = 1e-8, atol = 1e-10)
end

@testset "Argument validation" begin
    design = DesignStruct(
        name = "PEM",
        capacity_mw = 100.0,
        efficiency = 0.7,
        min_load = 0.2,
        max_load = 1.0,
    )

    op_static = OperationStruct(static = true, power_input_mw = 50.0, duration_hours = 1.0)
    @test_throws ArgumentError H2Gen([1.0, 1.0], design, op_static)

    op_dynamic = OperationStruct(static = false, power_input_mw = [50.0, 60.0])
    @test_throws ArgumentError H2Gen([1.0], design, op_dynamic)
end
