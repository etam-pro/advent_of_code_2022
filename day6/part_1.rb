require 'byebug'

START_MARKER_SIZE = 4
MESSAGE_MARKER_SIZE = 14

def marker?(token)
  token.split('').length == token.split('').uniq.length
end

def run
  # PART 1
  input = File.read('day6/input')

  pointer = 0

  while pointer <= input.length - START_MARKER_SIZE do
    token = input[pointer..pointer+START_MARKER_SIZE-1]
    break if marker?(token)
    pointer += 1
  end

  start_of_marker_idx = pointer + START_MARKER_SIZE 

  puts "start-of-packet detected at: #{start_of_marker_idx}"

  # PART 2
  remaining = input[start_of_marker_idx..-1]
  
  pointer = 0

  while pointer <= input.length - MESSAGE_MARKER_SIZE do
    token = input[pointer..pointer+MESSAGE_MARKER_SIZE-1]
    break if marker?(token)
    pointer += 1
  end

  message_marker_idx = pointer + MESSAGE_MARKER_SIZE

  puts "message marker detected at: #{message_marker_idx}"
end

run