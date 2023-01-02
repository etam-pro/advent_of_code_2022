require 'byebug'

BLOCK_BAR_1 = [[2, 3, 4 , 5]]
BLOCK_CROSS = [[3], [2,3,4], [3]]
BLOCK_L = [[2, 3, 4], [4], [4]]
BLOCK_BAR_2 = [[2], [2], [2], [2]]
BLOCK_SQR = [[2, 3], [2, 3]]

WALL_LEFT = 0
WALL_RIGHT = 6

LEFT = '<'
RIGHT = '>'

State = Struct.new(:block_idx, :jet_idx, :block, :ground)

class Chamber

  def initialize(jets)
    @blocks = [BLOCK_BAR_1, BLOCK_CROSS, BLOCK_L, BLOCK_BAR_2, BLOCK_SQR]
    @jets = jets
    @block_index = 0
    @jet_index = 0
    @chamber = []
  end

  def reset!
    @block_index = 0
    @jet_index = 0
    @chamber = []
  end

  def detect_cycle
    states = []

    heights = []

    cycle_start = nil
    cycle_end = nil
    cycle_height = nil

    idx = 0

    while true
      block, y = spawn!
      landed_block, landed_y = drop(block, y)

      state = State.new(@block_index, @jet_index, landed_block, @chamber.last(5))

      unless states.include?(state)
        mark_position(landed_block, landed_y)
        heights << height
        states << state
        idx += 1
        next
      end

      cycle_start = states.index(state)
      cycle_end = idx

      puts "Cycle Detected: #{idx}"

      break
    end

    [cycle_start, cycle_end, heights]
  end

  def run(num_of_times)
    num_of_times.times do
      block, y = spawn!
      landed_block, landed_y = drop(block, y)
      mark_position(landed_block, landed_y)
    end
  end

  def spawn!
    block = @blocks[@block_index]
    y = @chamber.length + 3
    @block_index = (@block_index + 1) % @blocks.length
    [block, y]
  end

  def drop(block, y)
    while true
      jet = @jets[@jet_index]
      @jet_index = (@jet_index + 1) % @jets.length

      block = move(y, block, jet)

      break if contact?(block, y)

      y -= 1

    end

    [block, y]
  end

  def height
    @chamber.length
  end

  def print_chamber
    @chamber.reverse.each do |row|
      puts (0..6).to_a.map { |grid| row[grid] ? '#' : '.' }.join
    end
  end

  private

  def move(y, block, direction)
    case direction
    when LEFT
      movable = true
      block.each_with_index do |row, i|
        if (@chamber[y+i] && @chamber[y+i][row.min - 1] == '#') || (row.min == WALL_LEFT)
          movable = false
          break
        end
      end

      movable ? block.map do |row|
        row.map { |grid| grid - 1 }
      end : block
    when RIGHT
      movable = true
      block.each_with_index do |row, i|
        if (@chamber[y+i] && @chamber[y+i][row.max + 1] == '#') || (row.max == WALL_RIGHT)
          movable = false
          break
        end
      end

      movable ? block.map do |row|
        row.map { |grid| grid + 1 }
      end : block
    end
  end

  def mark_position(block, y)
    # reverse - chart from bottom to top
    block.each_with_index do |row, block_y|
      _y = y + block_y
      @chamber[_y] ||= []
      row.each do |grid|
        @chamber[_y][grid] = '#'
      end
    end
  end

  def contact?(block, y)
    return false if y > @chamber.length

    # Ground case
    return true if y.zero? && @chamber.length.zero?

    contact = false

    block.each_with_index do |row, idx|

      row.each do |grid|
        # found contact point
        if @chamber[y + idx - 1] && @chamber[y + idx - 1][grid]
          contact = true
          break
        end
      end
    end

    contact
  end
end

def part_1(jets, num)
  chamber = Chamber.new(jets)
  chamber.run(num)

  puts "Part 1: #{chamber.height}"
end

def part_2(jets, num)
  chamber = Chamber.new(jets)
  cs, ce, heights = chamber.detect_cycle

  ch = heights[ce - 1] - heights[cs - 1]
  cl = ce - cs

  remaining = (num - cs) % cl

  h_remaining = heights[cs + remaining - 1]
  h_cycles = ((num - cs) / cl) * ch

  puts h_cycles + h_remaining
end

input = File.read('day17/input', chomp: true).split('')
part_1(input, 2022)
part_2(input, 1000000000000)
