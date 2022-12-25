require 'byebug'

def normalize(digit)
  case digit
  when '2', '1' ,'0'
    digit.to_i
  when '-'
    -1
  when '='
    -2
  end
end

def denormalize(digit)
  case digit
  when 2, 1, 0
    digit.to_s
  when -1
    '-'
  when -2
    '='
  end
end

def snafu(num)
  power = -1
  max = 0
  while max < num
    power += 1
    max = (0..power).map { |p| 2 * 5**p }.sum
  end

  _snafu = ('2' * (power + 1)).split('').map(&:to_i)

  while true
    val = _snafu.reverse.map.with_index { |digit, power| digit * 5**power }.sum
    print "Current: #{val} \r"
    break if val == num

    _snafu.each_index do |idx|
      _s = _snafu.dup
      decrement(_s, idx)
      if _s.reverse.map.with_index { |digit, power| digit * 5**power }.sum >= num
        decrement(_snafu, idx)
      end
    end
  end

  _snafu.map { |digit| denormalize(digit) }.join
end

def decrement(snafu, i)
  _i = i
  while i >= 0
    snafu[i] = snafu[i] == -2 ? 2 : snafu[i] - 1
    break if snafu[i] != 2
    i -= 1
  end
end

def calc(snafu)
  snafu.split('')
    .reverse
    .map
    .with_index { |digit, idx| normalize(digit) * (5 ** (idx)) }
    .sum
end

map = {}
input = File.readlines('day25/input', chomp: true)
input.each { |line| map[line] = calc(line) }
total = map.values.sum

puts "\n\n#{snafu(total)}"
