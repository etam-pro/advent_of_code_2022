require 'byebug'

UP = 'U'
DOWN = 'D'
LEFT = 'L'
RIGHT = 'R'

def attached?(head, tail)
  head_x, head_y = head
  tail_x, tail_y = tail

  (head_x - tail_x).abs < 2 && (head_y - tail_y).abs < 2
end

def move(head, direction)
  head_x, head_y = head

  case direction
  when UP
    [head_x, head_y + 1]
  when DOWN
    [head_x, head_y - 1]
  when LEFT
    [head_x - 1, head_y]
  when RIGHT
    [head_x + 1, head_y]
  else
    raise "should not reach here!"
  end
end

def follow(head, tail)
  return tail if attached?(head, tail)

  head_x, head_y = head
  tail_x, tail_y = tail

  dist_x = head_x - tail_x
  dist_y = head_y - tail_y

  new_x = tail_x
  new_x = tail_x + (dist_x/dist_x.abs) if dist_x.abs > 0

  new_y = tail_y
  new_y = tail_y + (dist_y/dist_y.abs) if dist_y.abs > 0

  [new_x, new_y]
end

def part_1(input)
  visited = []

  head = [0, 0]
  tail = [0, 0]

  input.each do |line|
    direction, moves = line.split(' ')
    
    moves.to_i.times do
      head = move(head, direction)
      tail = follow(head, tail)

      visited << tail
    end
  end

  puts "Part 1: total visited #{ visited.uniq.count} location(s)"
end

def part_2(input)
  # The start
  visited = []

  # Initial position of all knots
  knots = (0..9).map { |_| [0, 0] }

  input.each_with_index do |line, num_move|
    direction, moves = line.split(' ')

    moves.to_i.times do
      knots.each_with_index do |knot, idx|
        # Handle head
        if idx == 0 
          knots[idx] = move(knot, direction)
        # Handle tails
        else
          prev = knots[idx-1]
          cur = knots[idx]

          knots[idx] = follow(prev, cur)
        end
      end

      visited << knots.last
    end
  end

  puts "Part 2: total visited #{visited.uniq.count} location(s)"
end

input = File.readlines('day9/input', chomp: true)
part_1(input)
part_2(input)
  