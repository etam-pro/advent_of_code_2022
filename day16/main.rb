require 'byebug'
require_relative 'util'

class Valve
  attr_reader :name, :rate, :edges
  attr_writer :edges

  def initialize(name, rate)
    @name = name
    @rate = rate
  end
end

class Cave
  attr_reader :max_pressure
  attr_reader :valves
  attr_reader :opened

  def initialize(valves)
    @valves = valves
    @max_pressure = 0
  end

  def calc(time, opened, current_valve, acc = 0)
    # Even when you can open a valve, won't have time to release any pressure
    if time == 0
      @max_pressure = acc if acc > @max_pressure
      @opened = opened
      return
    end

    # Exiting if remaining valves all open at once still can't beat the highest
    return if (@valves
      .select { |v| !opened.include?(v) }
      .map { |v| v.rate * time }
      .sum + acc) <= @max_pressure

    if !opened.include?(current_valve) && current_valve.rate > 0
      # Try opening it as well

      current_valve
        .edges
        .sort { |a, b| b.rate <=> a.rate }
        .each do |v|
          calc(
            time - 1,
            opened + [current_valve],
            current_valve,
            acc + (current_valve.rate * (time - 1))) # -1 for opening
        end
    end

    # Not opening current valve, move
    current_valve
      .edges
      .sort { |a, b| b.rate <=> a.rate }
      .each do |v|
        calc(time - 1, opened, v, acc)
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

  cave.calc(30, [], cave.valves.first)

  puts "Part 1: #{cave.max_pressure}"
end

def part_2(input)
end

input = File.readlines('day16/input', chomp: true)

part_1(input)
part_2(input)
