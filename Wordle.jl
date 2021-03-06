
#module Wordle

include("types.jl")

wordleWords = collect(readlines("wordbank.txt"))
wordBank = Set(collect.(wordleWords))
#wordBank = Set(collect.(wordleWords[1:100]))

function newGame() :: GameState
  i = rand(1:length(wordleWords))
  myWord = wordleWords[i] # my word indeed!
  newGame(myWord)
end

function newGame(word::String) :: GameState
  # FIXME: check that word is in word bank
  GameState(collect(word), [])
end

function success(game :: GameState) :: Bool
  length(game.guesses) > 0 && all([x==Exact for x in last(game.guesses)[2]])
end

function fail(game :: GameState) :: Bool
  length(game.guesses) >= 6 && !success(game) 
end

# if the game is not over
function inProgress(game :: GameState) :: Bool
  !success(game) && !fail(game)
end

function guessMask(guess::Word, solution::Word) :: GuessResponse
  map(enumerate(zip(guess, solution))) do (i, (gl, sl))
    if sl == gl
      Exact
           # don't return exists if there's an exact match somewhere else
    elseif gl in solution[guess .!= solution] # so not here but somewhere else
      Exists
    else
      Fail
    end
  end
end

function guess!(guess::Word, game::GameState) :: Tuple{GuessResponse, GameState}
  # construct a guess response according to the word
  resp = guessMask(guess, game.goal)
  push!(game.guesses, (guess, resp))

  (resp, game)
end

#end
