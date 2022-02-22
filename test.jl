
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

  s0 = GameState(['o', 'u', 't', 'e', 'r'], [])
  s1 = GameState(['o', 'u', 't', 'e', 'r'], [(['t', 'a', 'r', 'e', 's'], [Exists, Fail, Exists, Exact, Fail]), (['o', 'u', 't', 'e', 'r'], [Exact, Exact, Exact, Exact, Exact]), (['o', 'u', 't', 'e', 'r'], [Exact, Exact, Exact, Exact, Exact]), (['o', 'u', 't', 'e', 'r'], [Exact, Exact, Exact, Exact, Exact]), (['o', 'u', 't', 'e', 'r'], [Exact, Exact, Exact, Exact, Exact]), (['o', 'u', 't', 'e', 'r'], [Exact, Exact, Exact, Exact, Exact])])
  s2 = GameState(['o', 'u', 't', 'e', 'r'], [(['t', 'a', 'r', 'e', 's'], [Exists, Fail, Exists, Exact, Fail]), (['o', 'u', 't', 'e', 'r'], [Exact, Exact, Exact, Exact, Exact])])
  @testset "inProgress" begin
    @test !success(s0)
    @test !fail(s0)
    @test inProgress(s0)

    @test success(s1)
    @test !fail(s1)
    @test !inProgress(s1)

    @test success(s2)
    @test !fail(s2)
    @test !inProgress(s2)
  end
end

