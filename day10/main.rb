require 'byebug'

SIGNAL_STRENGTH_CYCLES = [20, 60, 100, 140, 180, 220]

class Device
  NO_OP = 'noop'
  ADDX = 'addx'
  
  OPS = { 
    NO_OP => 1,
    ADDX => 2
  }

  CYCLES_NO_OP = 1
  CYCLES_ADD = 2

  CRT_SCREEN_WIDTH = 40

  attr_reader :signal_strength

  def initialize(input)
    @input = input
    @cycles = 0
    @x = 1
    @signal_strength = 0
    @crt_pixels = []
  end

  def process 
    @input.each do |line|
      op, val = line.split(' ')

      OPS[op].times do
        draw_pixel!

        @cycles += 1

        if SIGNAL_STRENGTH_CYCLES.include?(@cycles)
          @signal_strength += @cycles * @x 
        end
      end

      execute(op, val.to_i)      
    end
  end

  def print_crt_image
    @crt_pixels.each_slice(CRT_SCREEN_WIDTH) do |slice|
      puts "#{slice.join('')}"
    end
  end

private

  def execute(op, val)
    case op
    when ADDX
      @x += val
    else
      # noop
    end
  end

  def draw_pixel!
    pixel = (@x-1..@x+1).include?(@cycles % CRT_SCREEN_WIDTH) ? '#' : '.'
    @crt_pixels << pixel
  end

end

def part_1(input)
  device = Device.new(input)
  device.process
  
  puts "Part 1: #{device.signal_strength}"
end

def part_2(input)
  device = Device.new(input)
  device.process
  device.print_crt_image
end

input = File.readlines('day10/input', chomp: true)
part_1(input)
part_2(input)