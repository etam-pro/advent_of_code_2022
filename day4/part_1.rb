require 'byebug'

total = File.readlines('day4/input').count do |line| 
  sec1, sec2 = line
    .split(',')
    .map { |sec| sec.split('-') }
    .map { |(head, tail)| head.to_i..tail.to_i }
    .map(&:to_a)

  (sec1 - sec2).empty? || (sec2 - sec1).empty?
end

puts "Total redudant paris: #{total}"