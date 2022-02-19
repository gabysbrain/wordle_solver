#module Solver

using Folds

include("types.jl")
include("Wordle.jl")

function candidates(guess::Status, words::WordBank) :: Set{Word}
  filter(w->isCandidate(guess, w), words)
end

function isCandidate(guess::Status, word::Word) :: Bool
  extras = guess.extraLetters
  for i in 1:length(word)
    # shortcut for the invalid letters
    if word[i] in guess.invalidLetters
      return false
    end
    if guess.word[i] === missing
      # see if we can remove one of the known letters without a place
      # see if this is a valid place for that letter
      if haskey(extras, word[i]) 
        if !extras[word[i]][i]
          return false
        end
      end
    else
      # this needs to match the word letter exactly
      if guess.word[i] ≠ word[i]
        return false
      end
    end
  end
  
  # we made it through the failure conditions!
  true
end

function status(guess::Guess, resp::GuessResponse) :: Status
  # set up the default mask for any extra letters
  extraLetterMask = fill(true, 5)
  extraLetterMask[findall(==(Exact), resp)] .= false

  # elements of the status
  extraLetters = Dict()
  badLetters = Set()
  statusWord :: Vector{StatusLetter} = fill(missing, length(guess))

  # go through the guess and response one by one to see how to adjust status
  for (i, (l, r)) in enumerate(zip(guess, resp))
    if r == Exact
      statusWord[i] = l
    elseif r == Exists
      # The only thing we know about the location is that the letter is not here
      if haskey(extraLetters, l)
        extraLetters[l][i] = false
      else
        m = copy(extraLetterMask)
        m[i] = false
        extraLetters[l] = m
      end
    else
      push!(badLetters, l)
    end
  end

  Status(statusWord, extraLetters, badLetters)
end

function countMasks(word::Word, possibilities::WordBank) :: Dict{GuessResponse,Int64}
  # count up the masks as we try word against the mask for each potential solution
  masks = Dict()
  for solution in possibilities
    m = guessMask(word, solution)
    ct = get!(masks, m, 0)
    masks[m] = ct + 1
  end
  masks
end

# figure out the information from each possible word
function scoreCandidates(possibilities::WordBank) :: Vector{Tuple{Word,Float64}}
  Folds.map(collect(possibilities)) do word
    (word, score(word, possibilities))
  end
end

function rankedCandidates(possiblities::WordBank) :: Vector{Tuple{Word,Float64}}
  cands = scoreCandidates(possiblities)
  sort(cands, by=x->x[2], rev=true)
end

function score(word::Word, possibilities::WordBank) :: Float64
  N = length(possibilities) # the overall possible guesses
  
  # figure out how potential solutions relate to solution masks
  masks = countMasks(word, possibilities)

  # probability is a simple frequency for now
  # TODO: try other probabilities
  probs = Dict([m => c / N for (m, c) in pairs(masks)])

  entropy(collect(values(probs)))
end

function entropy(probs::Vector{Float64}) :: Float64
  -sum([p * log(2,p) for p in probs])
end

#end
