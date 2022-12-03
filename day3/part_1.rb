require 'byebug'

ITEM_TYPES = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')

def trim(line)
  return line if line[-1] != "\n"
  return line[0..-2]
end

def compartment_items(sack)
  pivot = sack.length/2 
  [sack[0..pivot-1], sack[pivot..-1]]
end

def errors(comp1, comp2)
  comp1.split('') & comp2.split('')
end

def prio(item)
  ITEM_TYPES.index(item) + 1
end

def run
  all_prios = []

  File.open('day3/input').map do |line|
    sack = trim(line)
    comp1, comp2 = compartment_items(sack)
    prios = errors(comp1, comp2).map { |item| prio(item) }
    all_prios += prios
  end

  puts "Total Priority: #{all_prios.flatten.sum}"
end

run