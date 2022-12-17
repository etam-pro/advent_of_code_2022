require 'byebug'

BLOCK_BAR_1 = [[2, 3, 4 , 5]]
BLOCK_CROSS = [[3], [2,3,4], [3]]
BLOCK_L = [[4], [4], [2, 3, 4]]
BLOCK_BAR_2 = [[2], [2], [2], [2]]
BLOCK_SQR = [[2, 3], [2, 3]]

WALL_LEFT = 0
WALL_RIGHT = 6

LEFT = '<'
RIGHT = '>'

def print_chamber(chamber)
  chamber.reverse.each do |row|
    puts (0..6).to_a.map { |grid| row[grid] ? '#' : '.' }.join
  end
end

def move(chamber, y, block, direction)
  case direction
  when LEFT
    movable = true
    block.reverse.each_with_index do |row, i|
      if (chamber[y+i] && chamber[y+i][row.min - 1] == '#') || (row.min == WALL_LEFT)
        movable = false
        break
      end
    end

    movable ? block.map do |row|
      row.map { |grid| grid - 1 }
    end : block
  when RIGHT
    movable = true
    block.reverse.each_with_index do |row, i|
      if (chamber[y+i] && chamber[y+i][row.max + 1] == '#') || (row.max == WALL_RIGHT)
        movable = false
        break
      end
    end

    movable ? block.map do |row|
      row.map { |grid| grid + 1 }
    end : block
  end
end

def mark_position(chamber, block, offset)
  # reverse - chart from bottom to top
  block.reverse.each_with_index do |row, block_y|
    y = offset + block_y
    chamber[y] ||= []
    row.each do |grid|
      chamber[y][grid] = '#'
    end
  end
end

def contact?(chamber, block, y)
  return false if y > chamber.length

  # Ground case
  return true if y < 0 && chamber.length == 0

  contact = false

  block.reverse.each_with_index do |row, idx|

    row.each do |grid|
      # found contact point
      if chamber[y+idx-1] && chamber[y+idx-1][grid]
        contact = true
        break
      end
    end
  end
  
  contact
end

def part_1(jets, num)
  blocks = [BLOCK_BAR_1, BLOCK_CROSS, BLOCK_L, BLOCK_BAR_2, BLOCK_SQR]

  chamber = []

  num.times do |idx|
    # Starting Position Xs
    block = blocks.first

    # Starting Position Y 
    block_bottom_y = chamber.length + 3

    while true
      # idx == 4 && block_bottom_y == 1 && byebug
      jet = jets.first
      jets = jets.rotate
      block = move(chamber, block_bottom_y, block, jet)
      break if contact?(chamber, block, block_bottom_y)
      # ground case
      break if block_bottom_y == 0
      block_bottom_y -= 1
    end

    mark_position(chamber, block, block_bottom_y)
    # print_chamber(chamber)
    blocks = blocks.rotate
  end

  puts "Part 1: #{chamber.length}"
end

input = File.read('day17/input', chomp: true).split('')
part_1(input, 2022)
