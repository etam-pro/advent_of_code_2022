require 'byebug'

ITEM_TYPES = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')

GROUP_SIZE = 3

def trim(line)
  return line if line[-1] != "\n"
  return line[0..-2]
end

def prio(item)
  ITEM_TYPES.index(item) + 1
end

def find_badge(sacks)
  sacks
    .map { |sack| trim(sack) }
    .map { |sack| sack.split('') }
    .reduce(:&)
end

def run
  badges = []
  File.open('day3/input') do |file|
    file.each_slice(GROUP_SIZE) do |sacks|
      badges << find_badge(sacks)
    end
  end
  total_prios = badges.flatten.map { |badge| prio(badge) }.sum
  puts "Total Priority: #{total_prios}"
end

run

