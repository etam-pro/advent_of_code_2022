require 'byebug'

ROCK = :rock
PAPER = :paper
SCISSORS = :scissors

def trim(line)
  return line if line[-1] != "\n"
  return line[0..-2]
end

def normalize(move)
  case move
  when 'A', 'X'
    return ROCK
  when 'B', 'Y'
    return PAPER
  when 'C', 'Z'
    return SCISSORS
  end
end

def move_score(move)
  return 1 if move == ROCK
  return 2 if move == PAPER
  return 3 if move == SCISSORS
end

def round_score(move1, move2)
  return 3 if move1 == move2
  return 6 if (move2 == ROCK && move1 == SCISSORS) ||
     (move2 == PAPER && move1 == ROCK) ||
     (move2 == SCISSORS && move1 == PAPER)
  return 0
end

def run
  total = File.open('day2/input')
    .map do |line|
      move1, move2 = trim(line).split(' ').map { |move| normalize(move) }
      move_score(move2) + round_score(move1, move2)
    end
    .sum

  puts "In-your-face cheating: #{total}"
end

run