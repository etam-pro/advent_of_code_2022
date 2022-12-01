require 'byebug'

# NOTE: remove \n
def trim(line)
  line[0..-2]
end

def part_1
  max = 0
  acc = 0

  File.open('day1/input').each do |line|
    cal = trim(line)

    if cal == ''
      max = [max, acc].max
      acc = 0
      next
    end

    acc += cal.to_i
  end

  puts "How much time does it take to burn #{max} Calories?"
end

def part_2
  acc = 0
  cals = []

  File.open('day1/input').each do |line|
    cal = trim(line)

    if cal == ''
      cals << acc
      acc = 0
      next
    end

    acc += cal.to_i
  end

  total = cals.sort.reverse.first(3).reduce(:+)

  puts "How much time does it take to burn #{total} Calories?"
end

part_1
part_2