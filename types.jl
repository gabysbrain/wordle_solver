
StatusLetter = Union{Char,Missing}
Status = Vector{Set{Char}}

Word = Vector{Char} # words in the word bank
WordBank = Set{Word}

Guess = Vector{Char}

@enum Response Fail Exists Exact
GuessResponse = Vector{Response}

struct GameState
  goal :: Word
  guesses :: Vector{Tuple{Guess, GuessResponse}}
end

