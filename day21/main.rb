require 'byebug'

def value?(token)
  token.to_i.to_s == token.to_s
end

def calc(monkeys, monkey)
  return monkeys[monkey] if value?(monkeys[monkey]) 
    
  m1, op, m2 = monkeys[monkey].split(' ')

  val1 = calc(monkeys, m1)
  val2 = calc(monkeys, m2)

  eval "#{val1} #{op} #{val2}"
end

def calc2(monkeys, monkey)
  return monkeys[monkey] if value?(monkeys[monkey]) && monkey != 'humn'

  _monkey, token = monkeys.find { |k,v| v.include?(monkey) }

  m1, op, m2 = token.split(' ')

  if _monkey == 'root'
    return m1 == monkey ? calc(monkeys, m2) : calc(monkeys, m1)
  end

  if m1 == monkey
    new_m1 = calc2(monkeys, _monkey)
    new_m2 = calc(monkeys, m2)

    new_op =
      case op
      when '+'
        '-'
      when '-'
        '+'
      when '*'
        '/'
      when '/'
        '*'
      end

    return eval "#{new_m1} #{new_op} #{new_m2}"
  else
    new_m1 = calc2(monkeys, _monkey)
    new_m2 = calc(monkeys, m1)

    new_op
      case op
      when "-"
        return eval "#{new_m2} - #{new_m1}"
      when "+"
        return eval "#{new_m1} - #{new_m2}"
      when "*"
        return eval "#{new_m1} / #{new_m2}"
      when "/"
        return eval "#{new_m2} / #{new_m1}"
      end

    return eval "#{new_m1} #{new_op} #{new_m2}"
  end
end

def part_1(monkeys)
  puts "Part 1: #{calc(monkeys, "root")}"
end

def part_2(monkeys)
  puts "Part 2: #{ calc2(monkeys, 'humn')}"
end

input = File.readlines('day21/input', chomp: true)
monkeys = {}

input.each do |line|
  name, token = line.split(': ')
  monkeys[name] = token
end

part_1(monkeys)
part_2(monkeys)