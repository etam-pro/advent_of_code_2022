require 'byebug'

DISTRESS_SIGNAL_MULTIPLIER = 4_000_000

def draw_covered_areas!(acc, sensor, beacon)
  sensor_x, sensor_y = sensor
  beacon_x, beacon_y = beacon

  dist = (sensor_x - beacon_x).abs + (sensor_y - beacon_y).abs

  (sensor_y-dist..sensor_y+dist).each do |y|
    expand = dist - (sensor_y - y).abs

    acc[y] ||= []
    acc[y] << (sensor_x-expand..sensor_x+expand)
  end
end

def get_cover_size(covers, sensors, beacons, y)
  xs = covers[y]
    .map(&:to_a)
    .reduce([]) { |all, list| all |= list }
    .uniq

  y_sensors = sensors.uniq.count { |s| s.last == y  && xs.include?(s.first) }
  y_beacons = beacons.uniq.count { |b| b.last == y  && xs.include?(b.first) }

  xs.count - y_sensors - y_beacons
end

def find_distress_signal(covered_areas)
  slot = nil

  candidate_ys = covered_areas
    .each do |y, covered|
      next if y < 0
      
      # Finds a slot right between 2 ranges
      begins = covered.map { |range| range.begin }
      ends = covered.map { |range| range.end }
      possible_slot_anchors = begins.select { |b| ends.any? { |e| b - e == 2 } }.uniq

      # Exclude if there is more than 1 possiblity (requirement)
      next if possible_slot_anchors.count != 1

      # x position of the candidate slot right before the 
      x = possible_slot_anchors.first - 1

      if !covered.any? { |c| c.cover?(x) }
        slot = [x, y]
        break
      end
    end

  raise "Signal not found!" if slot.nil?

  x, y = slot
  x * DISTRESS_SIGNAL_MULTIPLIER + y
end

input = File.readlines('day15/input', chomp: true)
covered_areas = {}

sensors = []
beacons = []

input.each do |line|
  sensor, beacon = line
    .split(':')
    .map { |token| token.split('at').last }
    .map do |xy|
      xy
        .gsub(' ', '')
        .split(',')
        .map { |val| val.split('=').last.to_i }
    end
  
  sensors << sensor
  beacons << beacon

  draw_covered_areas!(covered_areas, sensor, beacon)
end

puts "Part 1: #{get_cover_size(covered_areas, sensors, beacons, 2_000_000)}"
puts "Part 2: #{find_distress_signal(covered_areas)}"