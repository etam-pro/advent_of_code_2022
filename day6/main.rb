require 'byebug'

START_MARKER_SIZE = 4
MESSAGE_MARKER_SIZE = 14

def marker?(token)
  token.split('').length == token.split('').uniq.length
end

def detect(input, marker_size)
  pointer = 0

  while pointer <= input.length - marker_size do
    token = input[pointer..pointer+marker_size-1]
    break if marker?(token)
    pointer += 1
  end

  pointer + marker_size
end

def part_1(input)
  idx = detect(input, START_MARKER_SIZE)
  puts "start-of-packet detected at: #{idx}"
end

def part_2(input)
  idx = detect(input, MESSAGE_MARKER_SIZE)
  puts "message marker detected at: #{idx}"
end

input = File.read('day6/input')
part_1(input)
part_2(input)
