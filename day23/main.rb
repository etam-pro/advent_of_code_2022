require 'byebug'

def has_any_elves?(map, x, y, dir = nil)
  e = [x+1, y]
  w = [x-1, y]
  ne = [x+1, y-1]
  nw = [x-1, y-1]
  se = [x+1, y+1]
  sw = [x-1, y+1]
  n = [x, y-1]
  s = [x, y+1]
  
  to_look =
    case dir
    when 'N'
      [n, ne, nw]
    when 'S'
      [s, se, sw]
    when 'W'
      [w, nw, sw]
    when 'E'
      [e, ne, se]
    else
      [e, w, ne, nw, se, sw, n, s]
    end

  return to_look.any? { |(x,y)| map[y] && map[y][x] == '#' } 
end

def print_map(map)
  max_y = map.keys.max
  min_y = map.keys.min

  max_x = map.values.flat_map(&:keys).max
  min_x = map.values.flat_map(&:keys).min

  (min_y..max_y).each do |y|
    puts('.' * max_x) && next if map[y].nil?
    puts (min_x..max_x).map { |x| map[y][x] || '.' }.join
  end
end


def perform!(elves_map, dirs)
  proposed_moves = []

  # First Half
  elves_map
    .each do |y, xs|
      xs.each do |(x, pos)|
        next if pos != '#'

        dirs.each do |dir|
          next if !has_any_elves?(elves_map, x, y)
          next if has_any_elves?(elves_map, x, y, dir)

          proposed_move = case dir
            when 'N'
              [x, y-1]
            when 'S' 
              [x, y+1]
            when 'W'
              [x-1, y]
            when 'E'
              [x+1, y]
            end

          proposed_moves << [
            [x, y],
            proposed_move
          ]
          
          break
        end
      end
    end

  dist_by_counts = proposed_moves
    .map { |(_, dist)| dist }
    .map { |dist| [dist, proposed_moves.count { |(_, _dist)| dist == _dist }] }

  uniq_dist = dist_by_counts
    .select { |(_, count)| count == 1 }
    .map { |(dist, _)| dist }

  # Second Half
  # filter out points targeted by 2 or more elves
  proposed_moves = proposed_moves.select do |(_, target)|
    uniq_dist.include?(target)
  end

  return false if proposed_moves.empty?

  # execute
  proposed_moves
    .each do |(elf, target)|
      x, y = elf
      elves_map[y][x] = '.'

      target_x, target_y = target
      elves_map[target_y] ||= {}
      elves_map[target_y][target_x] = '#'
    end

  dirs.rotate!

  true
end

def part_1(elves_map, dirs)
  10.times do
    perform!(elves_map, dirs)
  end

  max_y = elves_map.keys.max
  min_y = elves_map.keys.min
  
  max_x = elves_map.values.flat_map(&:keys).max
  min_x = elves_map.values.flat_map(&:keys).min
  
  width = max_x - min_x + 1
  
  acc = 0
  (min_y..max_y).each do |y|
    if elves_map[y].nil?
      acc += width 
      next
    end
    acc += (width - elves_map[y].keys.count { |x| elves_map[y][x] == '#' })
  end


  print_map(elves_map)
  puts '------------------'
  puts "Part 1: #{acc}\n\n\n"
end

def part_2(elves_map, dirs)
  round = 1
  while perform!(elves_map, dirs)
    chars = 'o0Q@#D'.split('')
    token = (0..rand(50..100)).to_a.map { |_| chars.sample }.join
    print "#{token}\r"
    round += 1
  end

  puts "\r\n"
  print_map(elves_map)
  puts '------------------'
  puts "Part 2: #{round}"
end

def elves_map
  elves_map = {}

  File.readlines('day23/input', chomp: true).each_with_index do |line, y|
    elves_map[y] ||= {}
  
    line.split('').each_with_index do |pos, x|
      elves_map[y][x] = pos
    end
  end

  elves_map
end

def dirs
  ['N', 'S', 'W', 'E']
end

part_1(elves_map, dirs)
part_2(elves_map, dirs)

