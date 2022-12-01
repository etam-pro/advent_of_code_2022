require 'byebug'

max = 0
acc = 0

# NOTE: remove \n
def trim(line)
  line[0..-2]
end

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