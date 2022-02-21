
include("Solver.jl")

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

function prompt(cands::WordBank) :: Tuple{Word, GuessResponse}
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

  (collect(inputWord), parseMask(inputMask))
end

# start with all words possible
wordLength = 5 # FIXME: figure this out from word bank
cands = wordBank
stat = emptyStatus(wordLength)

# s1 = status(collect("tares"), parseMask("nnnnm"))
# s2 = status(collect("downs"), parseMask("nnmnm"))
# s3 = status(collect("slimy"), parseMask("ymynn"))

# println(s1)
# sNext = mergeStatus(s1, s2)
# println(sNext)
# sNext = mergeStatus(sNext, s3)
# println(sNext)

while length(cands) > 1
  w, r = prompt(cands)

  updateStatus!(stat, w, r)
  global cands = candidates(stat, cands)

  println(stat)
end

if length(cands) == 1
  println("the word is $(first(cands))")
else
  println("no solution ")
end

