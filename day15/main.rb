require 'byebug'

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

def find_distress_signal()
end

def part_1(input)
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

  size = get_cover_size(covered_areas, sensors, beacons, 2000000)
  puts "#{size}"
end

input = File.readlines('day15/input', chomp: true)
part_1(input)