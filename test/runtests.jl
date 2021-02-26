using Test
using Printf
using Vizinanigans

function run_script(filepath)
    try
        include(filepath)
    catch err
        @warn "Error while testing script: " * sprint(showerror, err)

        # Print the content of the file to the test log, with line numbers, for debugging
        file_content = read(filepath, String)
        delineated_file_content = split(file_content, '\n')
        for (number, line) in enumerate(delineated_file_content)
            @printf("% 3d %s\n", number, line)
        end

        return false
    end
    return true
end

@testset "Vizinanigans" begin
    @testset "2D" begin
        @test run_script(joinpath(@__DIR__, "..", "examples", "visualize_2D.jl"))
    end

    @testset "3D" begin
        @test run_script(joinpath(@__DIR__, "..", "examples", "visualize_3D.jl"))
    end

    @testset "Volume slices" begin
        @test run_script(joinpath(@__DIR__, "..", "examples", "volumeslice.jl"))
    end
end
