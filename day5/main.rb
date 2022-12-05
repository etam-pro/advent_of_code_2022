require 'byebug'

def parse_crates(input)
  crates = []

  input.each do |line|
    break if line[0] != '['

    line
      .split('')
      .each_slice(4)
      .with_index do |(_, crate, _, _), i|
        next if crate == ' '
        crates[i] ||= []
        crates[i] << crate
      end
  end

  crates.map { |v| v.reverse }
end

def instructions(input)
  input.select { |line| line[0..3] == 'move' }
end

def operation(line) 
  tokens = line.split(' ')
  [tokens[1].to_i, tokens[3].to_i, tokens[5].to_i]
end

def operate
  input = File.readlines('day5/input')
  crates = parse_crates(input)

  instructions(input).each do |line|
    move, from, to = operation(line)
    yield(move, from, to, crates)
  end

  top_crates = crates
    .map { |stack| stack.last }
    .join('')

  puts "Top crates are: #{top_crates}"
end

def part_1
  operate do |move, from, to, crates|
    crates[to-1] += crates[from-1].pop(move).reverse
  end
end

def part_2
  operate do |move, from, to, crates|
    crates[to-1] += crates[from-1].pop(move)
  end
end

part_1
part_2
