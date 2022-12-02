require 'byebug'

ROCK = :rock
PAPER = :paper
SCISSORS = :scissors

MOVES = [ROCK, PAPER, SCISSORS]

LOSE = 'X'
DRAW = 'Y'
WIN = 'Z'

def trim(line)
  return line if line[-1] != "\n"
  return line[0..-2]
end

def normalize(move)
  case move
  when 'A'
    return ROCK
  when 'B'
    return PAPER
  when 'C'
    return SCISSORS
  end
end

def counter_move(move, expected)
  move_idx = 
    case expected
    when LOSE
      (MOVES.index(move) + 2) % 3
    when DRAW
      MOVES.index(move)
    when WIN
      (MOVES.index(move) + 1) % 3
    end

  return MOVES[move_idx]
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
      move, expected = trim(line).split(' ')
      move1 = normalize(move)
      move2 = counter_move(move1, expected)
      move_score(move2) + round_score(move1, move2)
    end
    .sum

  puts "Advancing cheating: #{total}"
end

run