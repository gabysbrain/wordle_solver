#module Solver

using Folds

include("types.jl")
include("Wordle.jl")

function candidates(guess::Status, words::WordBank) :: Set{Word}
  filter(w->isCandidate(guess, w), words)
end

function isCandidate(guess::Status, word::Word) :: Bool
  isCand = [l∈g for (g, l) in zip(guess.word, word)]
  nonExactLetters = Set([l for (g, l) in zip(guess.word, word) if length(g) > 1])
  all(isCand) && issubset(guess.reqChars, nonExactLetters)
end

function updateStatus!(status::Status, guess::Guess, resp::GuessResponse)
  s = status.word
  for (i, (l, r)) in enumerate(zip(guess, resp))
    if     r == Exact
      # see if we've found the location of a yellow letter
      if length(s[i]) > 1 && l ∈ status.reqChars
        pop!(status.reqChars, l)
      end
      s[i] = Set([l]) # singleton candidate
    elseif r == Exists
      # The only thing we know now is that this letter is not here
      pop!(s[i], l)
      push!(status.reqChars, l)
    elseif l ∉ status.reqChars # if we need l elsewhere then just remove it from here
      # remove this letter from all places
      for cands in s
        # don't eliminate a single candidate
        if length(cands) == 1
          continue
        end
        pop!(cands, l, nothing)
      end
    else # Fail but we need the letter somewhere else
      pop!(s[i], l, nothing)
    end
  end
end

function emptyStatus(n::Int64) :: Status
  w = map(1:n) do _
    Set('a':'z') 
  end
  Status(w, Set())
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
