require 'byebug'

Item = Struct.new(:worry, :anxiety_factor) do
  OP_ADD = '+'
  OP_MULTIPLY = '*'

  VAL_OLD = 'old'

  def inspected!(op)
    _op, val = op 

    _val =
      case val
      when VAL_OLD
        self.worry
      else
        val.to_i
      end

    temp =
      case _op
      when OP_ADD
        self.worry + _val
      when OP_MULTIPLY
        self.worry * _val
      end
    
    self.worry = temp % anxiety_factor
  end
end

class Monkey
  attr_reader :business

  def initialize(list:, op:, divisor:, left:, right:, throw_item:)
    @op = op
    @divisor = divisor
    @left = left
    @right = right
    @throw_item = throw_item

    @list = list

    @business = 0
  end

  def inspect!
    while !@list.empty? do
      item = @list.shift
      return if item.nil?

      item.inspected!(@op)
      
      throw_to = item.worry % @divisor == 0 ? @left : @right
      @throw_item.call(item, throw_to)
      @business += 1
    end
  end

  def catch!(item)
    @list << item
  end
end

class KeepAway

  attr_reader :monkeys
  
  def initialize(input, anxiety_factor = nil)
    @input = input
    @monkeys = []
    @anxiety_factor = anxiety_factor || default_anxiety_factor
  end

  def parse!
    @input
      .split("\n\n")
      .each do |info|
        _, worries, op, divisor, left, right = info.split("\n")

        items = worries
          .split(':')
          .last
          .gsub(' ', '')
          .split(',')
          .map(&:to_i)
          .map { |w| Item.new(w, @anxiety_factor) }

        op = op
          .split('=')
          .last
          .split(' ')
          .last(2)
      
        divisor = divisor
          .split('by')
          .last
          .gsub(' ', '')
          .to_i

        left = left
          .split('monkey')
          .last
          .gsub(' ', '')
          .to_i
        
        right = right
          .split('monkey')
          .last
          .gsub(' ', '')
          .to_i

        monkey = Monkey.new(
          op: op,
          divisor: divisor,
          left: left,
          right: right,
          list: items,
          throw_item: ->(item, to) { throw_item(item, to) }
        )

        @monkeys << monkey
      end
  end

  def throw_item(item, to)
    @monkeys[to].catch!(item)
  end

  def process!
    @monkeys.each_with_index do |monkey, idx|
      monkey.inspect!
    end
  end

  def default_anxiety_factor
    @input
      .split("\n\n")
      .map do |info|
        _, _, _, divisor, _, _ = info.split("\n")
        divisor
        .split('by')
        .last
        .gsub(' ', '')
        .to_i
      end
      .reduce(&:*)
  end

end

def run(input)
  keep_away = KeepAway.new(input)
  keep_away.parse!
  
  10000.times do |idx|
    keep_away.process!
  end

  busy_level =  keep_away.monkeys.map { |m| m.business }.sort.reverse.first(2).reduce(&:*)
  puts "Part 2: #{busy_level}"
end

input = File.read('day11/input')
run