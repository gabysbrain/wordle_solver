#module Solver

using Folds

include("types.jl")
include("Wordle.jl")

function candidates(guess::Status, words::WordBank) :: Set{Word}
  filter(w->isCandidate(guess, w), words)
end

# FIXME: this doesn't correctly account for must include letters
function isCandidate(guess::Status, word::Word) :: Bool
  isCand = [l∈g for (g, l) in zip(guess, word)]
  all(isCand)
end

function status(guess::Guess, resp::GuessResponse) :: Status
  N = length(guess)

  s = emptyStatus(N)

  for (i, (l, r)) in enumerate(zip(guess, resp))
    # See what responses we have left
    if     r == Exact
      s[i] = Set([l]) # singleton candidate
    elseif r == Exists
      # The only thing we know now is that this letter is not here
      pop!(s[i], l)
    else   # Fail
      # remove this letter from all places
      for cands in s
        # don't eliminate a single candidate
        if length(cands) == 1
          continue
        end
        pop!(cands, l)
      end
    end
  end

  s
end

function emptyStatus(n::Int64) :: Status
  map(1:n) do _
    Set('a':'z') 
  end
end

function mergeStatus(s1::Status, s2::Status) :: Status
  [intersect(c1, c2) for (c1,c2) in zip(s1, s2)]
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
