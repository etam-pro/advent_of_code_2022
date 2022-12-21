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

Actor = Struct.new(:current_valve, :target, :time_remaining)

class Cave
  attr_reader :max_pressure
  attr_reader :valves
  attr_reader :opened

  def initialize(valves)
    @valves = valves
    @max_pressure = 0
    @distance_map = distance_map
    @processed = 0
  end

  def effective_valves
    @valves.select { |v| v.rate > 0 }
  end

  def combo_edges(combo)
    combo.map { |v| v.edges.count }.sum
  end

  def start!(time, from, actors = 1)
    effective_valves
      .permutation(actors)
      .to_a
      .map do |combo|
        combo.sort { |a, b| a.name <=> b.name }
      end
      .uniq
      .sort do |a, b|
        combo_edges(b)  <=> combo_edges(a)
      end
      .each do |combo|
        _actors = []
        actors.times do |idx|
          target = combo[idx]
          _actors << Actor.new(
            from,
            target,
            @distance_map[from.name][target.name]
          ).freeze
        end

        calc(time, [], _actors, 0)
      end
  end

  def calc(time, opened, actors, acc = 0)
    @processed += 1
    print "Processing #{@processed} \r"

    # Exiting if remaining valves all open at once still can't beat the highest
    return if (@valves
      .select { |v| !opened.include?(v) }
      .map { |v| v.rate * time }
      .sum + acc) <= @max_pressure

    valves_to_open = effective_valves
      .select { |v| !opened.include?(v) }
      .select { |v| !actors.map(&:target).include?(v) }

    # Pick the actor closes to finish, process it
    current_actor = actors.min { |a,b| a.time_remaining <=> b.time_remaining }
    other_actors = actors.select { |a| a != current_actor }
    current_valve = current_actor.target

    time_spent = current_actor.time_remaining + 1
    acc += (time - time_spent) * current_valve.rate # -1 since it starts to gain pressure a cycle after open

    _opened = opened + [current_actor.target]
    if acc > @max_pressure
      @max_pressure = acc
      puts "------------------------------"
      puts "New Record: #{@max_pressure}"
      puts "Processed: #{@processed}"
      puts "Path: #{_opened.map { |v| v.name }}"
      puts "------------------------------\n"
    end

    if valves_to_open.empty?
      return if actors.all? { |a| a.current_valve == a.target } # all actors reached destination. exit
      return calc(time, _opened, other_actors, acc) # let the unfinished actors finish
    end
    
    # Find next destination for the actor
    valves_to_open
      .select do |v|
        dist = @distance_map[current_valve.name][v.name]
        dist && dist <= time - 1
      end
      .sort do |a, b|
        time_left = time - time_spent
        effectiveness(current_valve, b, time_left, 5) <=> effectiveness(current_valve, a, time_left, 5)
      end
      .first(4) # Really trying my luck here ...
      .each do |v|
        dist = @distance_map[current_valve.name][v.name]
        _actors = other_actors.map { |a| Actor.new(a.current_valve, a.target, a.time_remaining - time_spent).freeze }
        _actors << Actor.new(current_valve, v, dist).freeze
        calc(time - time_spent, _opened, _actors, acc)
      end
  end

  def effectiveness(from, target, time_remaining, depth = 1)
    dist = @distance_map[from.name][target.name]
    _effectiveness = (time_remaining - dist) * target.rate
    return _effectiveness if depth == 1
    _effectiveness += target.edges.map { |edge| effectiveness(target, edge, time_remaining - dist, depth - 1) }.max
    _effectiveness
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

def part_1(cave)
  start = cave.valves.find { |v| v.name == 'AA' }
  cave.start!(30, start, 1)

  puts "\n\nPart 1: #{cave.max_pressure}"
end

def part_2(cave)
  start = cave.valves.find { |v| v.name == 'AA' }
  cave.start!(26, start, 2)

  puts "\n\nPart 2: #{cave.max_pressure}"
end


input = File.readlines('day16/input', chomp: true)
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

# part_1(cave)
part_2(cave)
