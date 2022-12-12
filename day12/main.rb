require 'byebug'

class Location 
  attr_accessor :parent, :visited, :elevation, :x, :y

  def initialize(elevation, x, y)
    @visited = false
    @parent = nil 
    @elevation = elevation
    @x = x
    @y = y
  end

  def destination?
    @elevation == 'E'
  end

  def elevation
    return 'a' if @elevation == 'S'
    return 'z' if @elevation == 'E'

    @elevation
  end
end

class HeightMap
  START = 'S'
  DEST = 'E'

  def initialize(input, start)
    @locations = input.each_with_index.map do |line, y|
      line.split('').each_with_index.map { |elevation, x| Location.new(elevation, x, y) }
    end

    @start = start

    @bfs_queue = []
  end

  def graph!
    node = start_node
    node.visited = true

    @bfs_queue << node
    while !@bfs_queue.empty? do
      node = @bfs_queue.shift

      break if node.destination?

      edges(node).each do |edge|
        next if edge.visited

        edge.visited = true
        edge.parent = node
        @bfs_queue << edge
      end
    end
    node
  end

  def calc_dist
    node = graph!

    return nil if !node.destination?

    dist = 0
    while !node.parent.nil? do
      node = node.parent 
      dist += 1
    end
    dist
  end

private

  def edges(node)
    x = node.x
    y = node.y

    up   = y == 0 ? nil : [x, y-1]
    down = y == @locations.length - 1 ? nil : [x, y+1]
    left = x == 0 ? nil : [x-1, y]
    right = x == @locations[y].length - 1 ? nil : [x+1, y]

    edges = [up, down, left, right]
      .compact
      .select do |(x, y)|
        valid_move?(
          normalize(node.elevation),
          normalize(@locations[y][x].elevation)
        )
      end
      .map { |(x, y)| @locations[y][x] }
  end

  def valid_move?(a, b)
    a.ord + 1 >= b.ord
  end

  def normalize(elev)
    case elev
    when START
      'a'
    when DEST
      'z'
    else
      elev
    end
  end

  def find_loc(char)
    node = nil

    @locations.each_with_index do |row, y|
      row.each_with_index do |loc, x|
        loc
      end
    end

    loc
  end

  def start_node
    return @start_node if @start_node

    x, y = @start
    @start_node = @locations[y][x]
  end

end

def part_1(input)
  start = [0, 0] 
  input.each_with_index do |row, y|
    row.split('').each_with_index do |marker, x|
      if marker == 'S'
        start = [x, y]
        break
      end
    end
  end
  height_map = HeightMap.new(input, start)
  dist = height_map.calc_dist
  puts "Shortest Distance: #{dist}"
end

def part_2(input)
  starts = []

  input.each_with_index do |row, y|
    row.split('').each_with_index do |marker, x|
      if marker == 'S' || marker == 'a'
        starts << [x, y]
      end
    end
  end

  dist = starts
    .map { |start| HeightMap.new(input, start).calc_dist }
    .compact
    .min

  puts "Shortest Distance: #{dist}"
end

input = File.readlines('day12/input', chomp: true)
part_1(input)
part_2(input)