
include("Solver.jl")

word = first(wordBank)
initialCands = rankedCandidates(wordBank)

function logStatus(cands::Vector{Tuple{Word,Float64}}, game::GameState)
  # Start with a blank slate
  #Base.run(`clear`)

  # Print the status
  println("$(length(cands)) words in bank")

  println("top 10")
  for (w, s) in cands[1:min(end,10)]
    println("$w: $s")
  end
end

function solveGame(game::GameState) :: GameState
  s = emptyStatus(5)
  cands = copy(wordBank) # assume nothing, but things get destructive
  first = true

  while inProgress(game)
    if first
      rc = initialCands # cache expensive computation
      first = false
    else
      rc = rankedCandidates(cands)
    end
    logStatus(rc, game)
    if length(rc) == 0
      return game
    end

    # solve the game by picking the most informative (i.e. highest information word)
    g = rc[1][1]
    r, _ = guess!(g, game)
    updateStatus!(s, g, r)
    cands = candidates(s, cands)
  end

  game
end

# right now returns number of guesses
function gameStats(game::GameState) :: Int64
  length(game.guesses)
end

function solveAllGames() :: Vector{Int64}
  map(enumerate(wordBank)) do (i,w)
    println("game $i of $(length(wordBank)) - $w")
    g = newGame(join(w))
    gg = solveGame(g)
    gameStats(gg)
  end
end

stats = solveAllGames()
println("avg guesses: $(mean(stats))")

#println(solveGame(newGame("pings")))

