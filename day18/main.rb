require 'byebug'

require_relative 'utils'

class Node
  attr_reader :x, :y, :z
  attr_accessor :edges, :visited, :parent, :lava, :air_bubble

  def initialize(x, y, z)
    @x, @y, @z = x, y, z

    @lava = false
    @air_bubble = false

    @edges = []

    reset_bfs!
  end

  def reset_bfs!
    @visited = false
    @parent = nil
  end

  def xyz
    [x, y, z]
  end
end

class Nodes

  attr_reader :nodes

  def initialize(nodes)
    @nodes = nodes
    set_edges!
  end

  def detect_boundary!(start)
    @nodes.each do |n|
      next if n.lava
      next if reachable?(start, n)

      n.air_bubble = true
    end
  end

private

  def set_edges!
    @nodes.each do |n|
      @nodes.each do |n2|
        next if n == n2
        n.edges << n2 if connected?(n.xyz, n2.xyz) && !n2.lava
      end
    end
  end

  def reachable?(water, target_node)
    node = bfs(water, target_node)
    reachable = target_node.xyz == node.xyz
    reset_bfs!
    reachable
  end

  def reset_bfs!
    @nodes.each(&:reset_bfs!)
  end
end

def connected?(cube1, cube2)
  cube1
    .zip(cube2)
    .map { |vals| (vals.first - vals.last).abs }
    .sort == [0,0,1]
end

def part_1(cubes)
  total_surface_areas = cubes.length * 6

  cubes.each do |c1|
    cubes.each do |c2|
      total_surface_areas -= 1 if connected?(c1, c2)
    end
  end

  puts "Part 1: #{total_surface_areas}"
end

def part_2(cubes, max_x, max_y, max_z)
  # Figuring out where the air bubbles are using BFS
  nodes = []
  (0..max_x+1).each do |x|
    (0..max_y+1).each do |y|
      (0..max_z+1).each do |z|
        node = Node.new(x, y, z)
        node.lava = true if cubes.include?(node.xyz)
        nodes << node
      end
    end
  end
  v = Nodes.new(nodes)

  # Find one reference node that is OUTSIDE the lava
  water_contact = v.nodes.find { |node| node.xyz == [0, 0, 0] }
  v.detect_boundary!(water_contact)
  air_bubbles = v.nodes.select { |n| n.air_bubble }.map(&:xyz)

  # Fill the air bubbles
  cubes += air_bubbles

  # Go through the same surface area detection
  total_surface_areas = cubes.length * 6
  cubes.each do |c1|
    cubes.each do |c2|
      total_surface_areas -= 1 if connected?(c1, c2)
    end
  end

  puts "Part 2: #{total_surface_areas}"
end

input = File.readlines('day18/input', chomp: true)

cubes = []

max_x = 0
max_y = 0
max_z = 0

input.each do |line|
  cube = line.split(',').map(&:to_i)

  x,y,z = cube

  max_x = x if x > max_x
  max_y = y if y > max_y
  max_z = z if z > max_z

  cubes << cube
end

part_1(cubes)
part_2(cubes, max_x, max_y, max_z)