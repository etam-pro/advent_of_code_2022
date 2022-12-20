require 'byebug'
require_relative 'util'

class Valve
  attr_reader :name, :rate, :edges
  attr_writer :edges

  attr_accessor :visited
  attr_accessor :parent

  def initialize(name, rate)
    @name = name
    @rate = rate
    @visited = false
    @parent = nil
  end
end

class Cave
  attr_reader :max_pressure
  attr_reader :valves
  attr_reader :opened

  def initialize(valves)
    @valves = valves
    @max_pressure = 0
    @distance_map = distance_map
  end

  def calc(time, opened, current_valve = @valves.find { |v| v.name == 'AA' }, acc = 0)
    @max_pressure = acc if acc > @max_pressure

    # Exiting if remaining valves all open at once still can't beat the highest
    return if (@valves
      .select { |v| !opened.include?(v) }
      .map { |v| v.rate * time }
      .sum + acc) <= @max_pressure

    valves_to_open = @valves
      .select { |v| v.rate > 0}
      .select { |v| !opened.include?(v) }
      .select { |v| @distance_map[current_valve.name][v.name] <= time - 1 } 

    return if valves_to_open.empty?

    valves_to_open.each do |v|
        dist = @distance_map[current_valve.name][v.name]

        calc(time - dist - 1, opened + [v], v, acc + (time - dist - 1) * v.rate)
      end
  end

private

  def distance_map
    distance_map = {}

    @valves.each do |from|
      @valves.each do |to|
        next if from == to

        distance_map[from.name] ||= {}
        distance_map[from.name][to.name] = calc_dist(from, to)
      end
    end

    distance_map
  end

  def calc_dist(from, to)
    node = bfs(from, to)

    return nil if node.nil?

    dist = 0
    while !node.parent.nil? do
      byebug if node.parent == false
      node = node.parent 
      dist += 1
    end

    reset!

    dist
  end

  def reset!
    @valves.each do |v|
      v.visited = false
      v.parent = nil
    end
  end

  
end

def part_1(input)
  valves_map = {}

  input.each do |line|
    _, valve, _, _, rate, _, _, _, _, *tunnels = line.split(' ')

    rate = rate.split('=').last[0..-2].to_i

    tunnels = tunnels.join('').split(',')

    valves_map[valve] = { 
      rate: rate,
      tunnels: tunnels,
      open: false
    }
  end

  _nodes = {}.tap do |hash|
    valves_map.each do |k, v|
      hash[k] = Valve.new(k, v[:rate])
    end
  end

  valves_map.each do |k, v|
    _nodes[k].edges = _nodes.select { |k, _| v[:tunnels].include?(k) }.values
  end

  cave = Cave.new(_nodes.values)

  cave.calc(30, [])

  puts "Part 1: #{cave.max_pressure}"
end

def part_2(input)
end

input = File.readlines('day16/input', chomp: true)

part_1(input)
part_2(input)
