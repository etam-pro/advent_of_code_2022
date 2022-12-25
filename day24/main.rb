require 'byebug'
require 'set'



UP = '^'
RIGHT = '>'
DOWN = 'v'
LEFT = '<'

Node = Struct.new(:x, :y, :time) do
  attr_accessor :parent
  
  def xy
    [x, y]
  end
end

Blizzard = Struct.new(:direction)

class Valley
  attr_reader :map, :min_time

  def initialize(map, start, finish)
    @map = map
    @processed = 0
    @max_x = map.first.length
    @max_y = map.length
    @start = start
    @finish = finish

    @blizzard_cache = {}
  end

  def start!(blizzards, time = 0)
    warm_blizzard_cache!(blizzards)

    start = Node.new(*@start, time)
    finish = Node.new(*@finish, time)

    node = find_path(start, finish)
    node
  end

  def roundtrip!(blizzards, time = 0)
    warm_blizzard_cache!(blizzards)

    start = Node.new(*@start, time)
    finish = Node.new(*@finish, time)

    
    node = find_path(start, finish)
    node = find_path(node, start)
    node = find_path(node, finish)
    node
  end

  def warm_blizzard_cache!(blizzards)
    1000.times do |idx|
      @blizzard_cache[idx] = blizzards
      blizzards = move_blizzards(blizzards)
    end
  end

  def dist(pos)
    x, y = pos
    _x, _y = @finish

    (x - _x).abs + (y - _y).abs
  end

  def fold(node, acc = [])
    return acc if node.parent.nil?
    acc << node
    fold(node.parent, acc)
  end

  def find_path(start, finish)
    node = start
    queue = []
    queue << node

    visited = Set.new
    visited << node

    while !queue.empty? do
      @processed += 1
      print "Processing #{@processed}\r"

      node = queue.shift
      break if node.xy == finish.xy

      edges = get_edges(node)
      edges.each do |edge|
        next if visited.include?(edge)
        edge.parent = node
        visited << edge
        queue << edge
      end
    end

    node
  end

private

  def get_edges(node)
    time = node.time
    x, y = node.xy

    blizzards = @blizzard_cache[node.time + 1] || move_blizzards(@blizzard_cache.values.last)
    @blizzard_cache[node.time + 1] = blizzards

    _edges = [
      [x - 1, y],
      [x + 1, y],
      [x, y - 1],
      [x, y + 1],
      [x, y]
    ].select do |pos|
      valid?(pos) &&
      no_blizzard?(pos, blizzards)
    end 

    edges = _edges.map do |pos|
      _x, _y = pos
      Node.new(_x, _y, time + 1)
    end

    edges
  end

  def print_score!
    puts "----------------------"
    puts "New Record: #{@min_time}"
    puts "Processed: #{@processed}"
    puts "----------------------"
  end

  def print_blizzards(b, cur_pos)
    _x, _y = cur_pos
    map.each_with_index do |row, y|
      _row = row.map.with_index do |space, x|
        case space
        when '#'
          space
        else
          if x == _x && y == _y
            'E'
          elsif b[y].nil? || b[y][x].nil?
            '.'
          else
            b[y][x].count > 1 ? b[y][x].count : b[y][x].first.direction
          end
        end
      end

      puts _row.join
    end
  end

  def valid?(pos)
    x, y = pos
    map[y] && map[y][x] == '.'
  end

  def no_blizzard?(pos, blizzards)
    x, y = pos
    blizzards.dig(y, x).nil?
  end

  def next_pos(blizzard, cur_pos)
    x, y = cur_pos
    case blizzard.direction
    when UP
      _new_x, _new_y = [x, y-1]
      _new_y = @max_y - 2 if _new_y == 0
      [_new_x, _new_y] 
    when RIGHT 
      _new_x, _new_y = [x+1, y]
      _new_x = 1 if _new_x == @max_x - 1
      [_new_x, _new_y] 
    when DOWN
      _new_x, _new_y = [x, y+1]
      _new_y = 1 if _new_y == @max_y - 1
      [_new_x, _new_y] 
    when LEFT
      _new_x, _new_y = [x-1, y]
      _new_x = @max_x - 2 if _new_x == 0
      [_new_x, _new_y] 
    end
  end

  def move_blizzards(blizzards)
    _blizzards = {}
  
    blizzards.each do |y, xs|
      xs.each do |x, blizzards|
        blizzards.each do |blizzard|
          new_x, new_y = next_pos(blizzard, [x, y])
          _blizzards[new_y] ||= {}
          _blizzards[new_y][new_x] ||= []
          _blizzards[new_y][new_x] << blizzard
        end
      end
    end
  
    _blizzards
  end
end

input = File.readlines('day24/input', chomp: true)

blizzards = {}
map = []

input.each_with_index do |line, y|
  spaces = line.split('')

  spaces.each_with_index do |space, x|
    if [UP, RIGHT, DOWN, LEFT].include?(space)
      blizzards[y] ||= {}
      blizzards[y][x] ||= []
      blizzards[y][x] << Blizzard.new(space)
    end
     
    map[y] ||= []
    map[y][x] = space == '#' ? space : '.'
  end
end


def part_1(map, blizzards)
  start = [1, 0]
  finish = [map.first.length - 2, map.length - 1]

  node = Valley.new(map, start, finish).start!(blizzards)

  puts "\n\nPart 1: #{node.time}"
end

def part_2(map, blizzards)
  start = [1, 0]
  finish = [map.first.length - 2, map.length - 1]
  
  node = Valley.new(map, start, finish).roundtrip!(blizzards)
  
  puts "\n\nPart 2: #{node.time}"
end

part_1(map, blizzards)
part_2(map, blizzards)

