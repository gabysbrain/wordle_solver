
include("Solver.jl")

function emptyStatus(n::Int64) :: Status
  Status(fill(missing, n), Dict(), Set())
end

function mergeStatus(s1::Status, s2::Status) :: Status
  # there will be some descruction here
  s1El = copy(s1.extraLetters)
  s2El = copy(s2.extraLetters)

  w = map(zip(s1.word, s2.word)) do (l1, l2)
    if l1 === missing && l2 === missing
      missing
    elseif l1 !== missing
      l1
      # maybe delete this letter from s2 extra letters
      delete!(s1El, l1)
    elseif l2 !== missing
      l2
      delete!(s2El, l2)
    end
  end

  unknownMask = [l===missing for l in w]
  ls = union(s1El, s2El)
  # fix the possible positions
  ls = Dict(map(ls) do (k,v)
    k => v .& unknownMask
  end)

  bls = union(s1.invalidLetters, s2.invalidLetters)

  Status(w, ls, bls)
end

# get the status from the user input
function parseMask(maskStr::String) :: GuessResponse
  map(collect(maskStr)) do l
    if l == 'y'
      Exact
    elseif l == 'n'
      Fail
    elseif l == 'm'
      Exists
    else
      println("invalid letter: $l")
      exit(1)
    end
  end
end

function prompt(cands::WordBank) :: Status
  println("$(length(cands)) words in bank")

  println("top 10")
  for (w, s) in rankedCandidates(cands)[1:min(end,10)]
    println("$w: $s")
  end

  println("use lowercase for yellow, uppercase for green, and prefix with underscore for bad letters")
  println("enter masked word from wordle")
  print("word? ")
  inputWord = readline()

  print("mask (y/n/m)? ")
  inputMask = readline()

  status(collect(inputWord), parseMask(inputMask))
end

# start with all words possible
wordLength = 5 # FIXME: figure this out from word bank
cands = wordBank
stat = emptyStatus(wordLength)

while length(cands) > 1
  println(stat)
  s = prompt(cands)

  global stat = mergeStatus(s, stat)
  global cands = candidates(stat, cands)
end

if length(cands) == 1
  println("the word is $(cands[1])")
else
  println("no solution ")
end

