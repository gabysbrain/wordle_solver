
using Test

include("Solver.jl")

@testset "Solver" begin
  @testset "updateStatus" begin
  end
end

@testset "Game" begin
  @testset "guessMask" begin
    @test guessMask(collect("plays"), collect("plays")) == [Exact, Exact, Exact, Exact, Exact]
    @test guessMask(collect("playd"), collect("plays")) == [Exact, Exact, Exact, Exact, Fail]
    @test guessMask(collect("playa"), collect("plays")) == [Exact, Exact, Exact, Exact, Fail]
    @test guessMask(collect("ginks"), collect("pings")) == [Exists, Exact, Exact, Fail, Exact]
  end
end

