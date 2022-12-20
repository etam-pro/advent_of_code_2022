require 'byebug'

Value = Struct.new(:value)

def perform_mix(input, times)
  values = input.dup
  mix = input.dup

  times.times do
    input.each do |n|
      next if n.value == 0

      idx = mix.index { |v| v.object_id == n.object_id }
      new_idx = (idx + n.value) % (mix.length - 1)

      mix = mix.select { |v| v.object_id != n.object_id }.insert(new_idx, n)
    end
  end
  mix
end

def part_1(input)
  input = input.map { |v| Value.new(v) }

  mix = perform_mix(input, 1)
  zero = mix.find { |v| v.value == 0 }

  results = []
  results << mix[(mix.index(zero) + 1000) % mix.length].value
  results << mix[(mix.index(zero) + 2000) % mix.length].value
  results << mix[(mix.index(zero) + 3000) % mix.length].value

  puts "Part 1: #{results.sum}"
end

def part_2(input)
  input = input.map { |v| Value.new(v * 811589153) }

  mix = perform_mix(input, 10)
  zero = mix.find { |v| v.value == 0 }

  results = []
  results << mix[(mix.index(zero) + 1000) % mix.length].value
  results << mix[(mix.index(zero) + 2000) % mix.length].value
  results << mix[(mix.index(zero) + 3000) % mix.length].value

  puts "Part 2: #{results.sum}"
end

input = File.readlines('day20/input', chomp: true)
  .map(&:to_i)

part_1(input)
part_2(input)
