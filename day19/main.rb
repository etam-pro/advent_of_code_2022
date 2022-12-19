require 'byebug'

class Simulation
  attr_reader :max_geodes

  def initialize(blueprint)
    @blueprint = blueprint
    @processed = 0
    @max_geodes = 0
    @earliest_geode_robot_time = 0
  end

  def calc(time_left, ore_robots, clay_robots, obsidian_robots, geode_robots, ore, clay, obsidians, geodes) 
    @processed += 1

    # Record earliest geode robot create time
    if geode_robots == 1
      @earliest_geode_robot_time = time_left if time_left > @earliest_geode_robot_time
    end

    if geodes > @max_geodes
      @max_geodes = geodes
    end

    # Time is up
    return if time_left == 0

    # Can't catch up when it is already behind. Terminate
    return if time_left < @earliest_geode_robot_time && geode_robots == 0
    
    # Build an geode robot if you can
    if obsidian_robots > 0
      build_geode_robot(
        time_left,
        ore_robots,
        clay_robots,
        obsidian_robots,
        geode_robots,
        ore,
        clay,
        obsidians,
        geodes
      )
    end

    if clay_robots > 0 && obsidians < @blueprint[:geode][:obsidian] * 2 # limit creating unecessary resources
      build_obsidian_robot(
        time_left,
        ore_robots,
        clay_robots,
        obsidian_robots,
        geode_robots,
        ore,
        clay,
        obsidians,
        geodes
      )
    end

    # Build a ore robot next
    if clay < @blueprint[:obsidian][:clay] * 2 # limit creating unecessary resources
      build_clay_robot(
        time_left,
        ore_robots,
        clay_robots,
        obsidian_robots,
        geode_robots,
        ore,
        clay,
        obsidians,
        geodes
      )
    end

    # Build a ore robot next
    if ore < @blueprint[:geode][:ore] * 2 # limit creating unecessary resources
      build_ore_robot(
        time_left,
        ore_robots,
        clay_robots,
        obsidian_robots,
        geode_robots,
        ore,
        clay,
        obsidians,
        geodes
      )
    end
  end

  def build_ore_robot(time_left, ore_robots, clay_robots, obsidian_robots, geode_robots, ore, clay, obsidians, geodes)
    ore_cost = @blueprint[:ore][:ore]
    time_to_collect_ore = 
      ore >= ore_cost ? 0 : ((ore_cost - ore)/ore_robots.to_f).ceil
    time_spent = time_to_collect_ore + 1

    gained_ore = ore_robots * time_spent
    gained_clay = clay_robots * time_spent
    gained_obsidians = obsidian_robots * time_spent
    gained_geodes = geode_robots * time_spent

    if time_left < time_spent
      consume_remaining_time(
        time_left, ore_robots, clay_robots, obsidian_robots, geode_robots, ore, clay, obsidians, geodes)
    else
      calc(
        time_left - time_spent,
        ore_robots + 1,
        clay_robots,
        obsidian_robots,
        geode_robots,
        ore + gained_ore - ore_cost,
        clay + gained_clay,
        obsidians + gained_obsidians,
        geodes + gained_geodes
      )
    end
  end

  def build_clay_robot(time_left, ore_robots, clay_robots, obsidian_robots, geode_robots, ore, clay, obsidians, geodes)

    ore_cost = @blueprint[:clay][:ore]

    time_to_collect_ore = 
      ore >= ore_cost ? 0 : ((ore_cost - ore)/ore_robots.to_f).ceil
    time_spent = time_to_collect_ore + 1

    gained_ore = ore_robots * time_spent
    gained_clay = clay_robots * time_spent
    gained_obsidians = obsidian_robots * time_spent
    gained_geodes = geode_robots * time_spent

    if time_left < time_spent
      consume_remaining_time(
        time_left, ore_robots, clay_robots, obsidian_robots, geode_robots, ore, clay, obsidians, geodes)
    else
      calc(
        time_left - time_spent,
        ore_robots,
        clay_robots + 1,
        obsidian_robots,
        geode_robots,
        ore + gained_ore - ore_cost,
        clay + gained_clay,
        obsidians + gained_obsidians,
        geodes + gained_geodes
      )
    end
  end

  def build_obsidian_robot(time_left, ore_robots, clay_robots, obsidian_robots, geode_robots, ore, clay, obsidians, geodes)

    ore_cost = @blueprint[:obsidian][:ore]
    clay_cost = @blueprint[:obsidian][:clay]

    time_to_collect_ore = ore >= ore_cost ? 
      0 : ((ore_cost - ore)/ore_robots.to_f).ceil
    time_to_collect_clay = clay >= clay_cost ?
      0 : ((clay_cost - clay)/clay_robots.to_f).ceil
    time_spent = [time_to_collect_ore, time_to_collect_clay].max + 1

    gained_ore = ore_robots * time_spent
    gained_clay = clay_robots * time_spent
    gained_obsidians = obsidian_robots * time_spent
    gained_geodes = geode_robots * time_spent

    if time_left < time_spent
      consume_remaining_time(
        time_left, ore_robots, clay_robots, obsidian_robots, geode_robots, ore, clay, obsidians, geodes)
    else
      calc(
        time_left - time_spent,
        ore_robots,
        clay_robots,
        obsidian_robots + 1,
        geode_robots,
        ore + gained_ore - ore_cost,
        clay + gained_clay - clay_cost,
        obsidians + gained_obsidians,
        geodes + gained_geodes
      )
    end
  end

  def build_geode_robot(time_left, ore_robots, clay_robots, obsidian_robots, geode_robots, ore, clay, obsidians, geodes)

    ore_cost = @blueprint[:geode][:ore]
    obsidian_cost = @blueprint[:geode][:obsidian]

    time_to_collect_ore =  ore >= ore_cost ?
      0 : ((ore_cost - ore)/ore_robots.to_f).ceil
    time_to_collect_obsidian = obsidians >= obsidian_cost ?
      0 : ((obsidian_cost - obsidians)/obsidian_robots.to_f).ceil
    time_spent = [time_to_collect_ore, time_to_collect_obsidian].max + 1

    gained_ore = ore_robots * time_spent
    gained_clay = clay_robots * time_spent
    gained_obsidians = obsidian_robots * time_spent
    gained_geodes = geode_robots * time_spent

    if time_left < time_spent
      consume_remaining_time(
        time_left, ore_robots, clay_robots, obsidian_robots, geode_robots, ore, clay, obsidians, geodes)
    else
      calc(
        time_left - time_spent,
        ore_robots,
        clay_robots,
        obsidian_robots,
        geode_robots + 1,
        ore + gained_ore - ore_cost,
        clay + gained_clay,
        obsidians + gained_obsidians - obsidian_cost,
        geodes + gained_geodes
      )
    end
  end

  def consume_remaining_time(time_left, ore_robots, clay_robots, obsidian_robots, geode_robots, ore, clay, obsidians, geodes)
    calc(
      0,
      ore_robots,
      clay_robots,
      obsidian_robots,
      geode_robots,
      ore + ore_robots * time_left,
      clay + clay_robots * time_left,
      obsidians + obsidian_robots * time_left,
      geodes + geode_robots * time_left
    )
  end

  def wait(time_left, ore_robots, clay_robots, obsidian_robots, geode_robots, ore, clay, obsidians, geodes)
    calc(
      time_left - 1,
      ore_robots,
      clay_robots,
      obsidian_robots,
      geode_robots,
      ore + ore_robots,
      clay + clay_robots,
      obsidians + obsidian_robots,
      geodes + geode_robots
    )
  end
end

class Factory
  attr_reader :blueprint_scores

  def initialize(blueprints)
    @blueprints = blueprints
    @blueprint_scores = {}
  end

  def perform(time)
    @blueprints.each do |id, bp|
      s = Simulation.new(bp)
      s.calc(time, 1, 0, 0, 0, 0, 0, 0, 0)
      @blueprint_scores[id] = s.max_geodes
    end
  end

  def quality_level
    @blueprint_scores.reduce(0) { |total, (k,v)| total += k*v }
  end

  def largest_geode_values
    @blueprint_scores.values.reduce(&:*)
  end
end

def part_1(blueprints)
  time = 24
  f = Factory.new(blueprints)
  f.perform(time)
  puts "Part 1: #{f.quality_level}"
end

def part_2(blueprints)
  time = 32
  f = Factory.new(blueprints)
  f.perform(time)
  puts "Part 2: #{f.largest_geode_values}"
end

blueprints = {}

input = File.readlines('day19/input', chomp: true)
input.each do |line|
  id = line.split(':').first.split(' ').last.to_i

  ore_robot_ore =
    line
      .split('Each ore robot costs ')
      .last
      .split(' ')
      .first
      .to_i

  clay_robot_ore =
    line
      .split('Each clay robot costs ')
      .last
      .split(' ')
      .first
      .to_i

  obsidian_robot_ore, obsidian_robot_clay = line
    .split('Each obsidian robot costs ')
    .last
    .split('.')
    .first
    .split(' ')
    .select { |token| token.to_i.to_s == token }
    .map(&:to_i)

  geode_robot_ore, geode_robot_obsidian = line
    .split('Each geode robot costs ')
    .last
    .split('.')
    .first
    .split(' ')
    .select { |token| token.to_i.to_s == token }
    .map(&:to_i)

  blueprints[id] = {
    ore: {
      ore: ore_robot_ore,
      clay: 0,
      obsidian: 0
    },
    clay: { 
      ore: clay_robot_ore,
      clay: 0,
      obsidian: 0
    },
    obsidian: { 
      ore: obsidian_robot_ore,
      clay: obsidian_robot_clay,
      obsidian: 0
    },
    geode: { 
      ore: geode_robot_ore,
      clay: 0,
      obsidian: geode_robot_obsidian
    }
  }
end

part_1(blueprints)
part_2(blueprints.first(3))
