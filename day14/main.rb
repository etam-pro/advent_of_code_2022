require 'byebug'

SOURCE = [500, 0]

def draw_terrain!(cave, from, to)
  from_x, from_y = from.split(',').map(&:to_i)
  to_x, to_y = to.split(',').map(&:to_i)

  dist_x = (to_x - from_x).abs
  dist_y = (to_y - from_y).abs

  if dist_x != 0
    ([to_x, from_x].min..[to_x, from_x].max).each do |x|
      cave[x] ||= []
      cave[x][from_y] = true
    end
  else
    ([to_y, from_y].min..[to_y, from_y].max).each do |y|
      cave[from_x] ||= []
      cave[from_x][y] = true
    end
  end
end

def get_next_point(cave, point, floor = nil)
  x, y = point

  return nil if floor && y + 1 == floor
  
  return [x, y+1] if cave[x].nil? || cave[x][y+1].nil?
  return [x-1, y+1] if cave[x-1].nil? || cave[x-1][y+1].nil?
  return [x+1, y+1] if cave[x+1].nil? || cave[x+1][y+1].nil?
  
  nil
end

def drop_sand!(cave, start, floor = nil)
  cur_point = start

  abyss = false  

  while true
    next_point = get_next_point(cave, cur_point, floor) 

    if !next_point.nil?
      cur_point = next_point

      x, _ = cur_point

      # out of bound, no horizontal terrain
      if cave[x].nil?
        if floor.nil?
          # part 1 - no floor
          abyss = true
          break
        else
          # part 2 - with floor
          cur_point = [x, floor - 1]
        end
      end
      
      next
    end

    x, y = cur_point
    cave[x] ||= []
    cave[x][y] = true

    break
  end

  abyss
end

def part_1(input)
  cave = []

  input.each do |line|
    points = line.split(' -> ')

    terrains = points.each_with_index do |pt, idx|
      next_pt = points[idx+1]
      next if next_pt.nil?
      draw_terrain!(cave, pt, next_pt)
    end
  end

  sand_count = 0

  while true
    abyss = drop_sand!(cave, SOURCE)
    break if abyss
    sand_count += 1
  end

  puts "Part 1: #{sand_count}"
end

def part_2(input)
  cave = []

  max_y = 0

  input.each do |line|
    points = line.split(' -> ')

    terrains = points.each_with_index do |pt, idx|
      x, y = pt.split(',').map(&:to_i)
      max_y = [max_y, y].max

      next_pt = points[idx+1]
      next if next_pt.nil?
      draw_terrain!(cave, pt, next_pt)
    end
  end

  floor = max_y + 2
  sand_count = 0

  while true
    break if get_next_point(cave, SOURCE).nil?
    drop_sand!(cave, SOURCE, floor)
    sand_count += 1
  end

  # NOTE: +1 for the last drop of the sand at the source
  puts "Part 2: #{sand_count + 1}"
end

input = File.readlines('day14/input', chomp: true)
part_1(input)
part_2(input)