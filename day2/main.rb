require 'byebug'

ROCK = :rock
PAPER = :paper
SCISSORS = :scissors

MOVES = [ROCK, PAPER, SCISSORS]

LOSE = 'X'
DRAW = 'Y'
WIN = 'Z'

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

def part_1(input)
  total = input
    .map do |line|
      move1, move2 = line.split(' ').map { |move| normalize(move) }
      move_score(move2) + round_score(move1, move2)
    end
    .sum

  puts "Part 1: #{total}"
end

def part_2(input)
  total = input
    .map do |line|
      move, expected = line.split(' ')
      move1 = normalize(move)
      move2 = counter_move(move1, expected)
      move_score(move2) + round_score(move1, move2)
    end
    .sum

  puts "Part 2: #{total}"
end

input = File.readlines('day2/input', chomp: true)
part_1(input)
part_2(input)
