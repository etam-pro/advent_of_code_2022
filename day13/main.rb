require 'byebug'

def compare_int(left, right)
  return nil if left == right
  return left < right
end

def compare_array(left, right)
  valid = nil

  left.each_with_index do |lv, idx|
    if right[idx].nil?
      valid = false
      break
    end

    valid = right_order?(lv, right[idx])
    break if valid != nil
  end

  valid = true if valid.nil? && left.length < right.length
  valid
end

def compare_mix(left, right)
  left = [left] unless left.is_a?(Array)
  right = [right] unless right.is_a?(Array)

  compare_array(left, right)
end

def right_order?(left, right)
  if left.is_a?(Integer) && right.is_a?(Integer)
    return compare_int(left, right)
  end

  if left.is_a?(Array) && right.is_a?(Array)
    return compare_array(left, right)
  end

  compare_mix(left, right)
end  

def part_1(input)
  idxs = []

  input.split("\n\n").each_with_index do |pair, idx|
    puts "Processing Pair #{idx + 1}"

    left, right = pair
      .chomp
      .split("\n")
      .map { |line| eval line }

    
    # 1 indexed
    idxs << idx + 1 if right_order?(left, right)
  end

  puts "Part 1: #{idxs.sum}"
end

def part_2(input)
  divider_1 = [[2]]
  divider_2 = [[6]]

  packets = input
    .split("\n")
    .map(&:chomp)
    .map { |line| eval line }
    .compact

  packets += [divider_1, divider_2]
  packets
    .sort! { |a, b| right_order?(a, b) ? -1 : 1 }

  puts "Part 2: #{(packets.index(divider_1) + 1) * (packets.index(divider_2) + 1)}"
end

input = File.read('day13/input')
part_1(input)
part_2(input)