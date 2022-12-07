require 'byebug'

LIMIT = 100_000
TOTAL_SPACE = 70_000_000
REQUIRED_SPACE = 30_000_000

class System
  attr_reader :root

  class Directory
    attr_accessor :name
    attr_accessor :children
    attr_accessor :parent

    def initialize(name:, children: [], parent: nil)
      @name = name
      @children = children
      @parent = parent
    end

    def size
      @children.map do |c|
        case c
        when Directory
          c.size
        when File
          c.size
        end
      end
      .sum
    end
  end

  class File
    attr_accessor :name
    attr_accessor :size
    attr_accessor :parent

    def initialize(name:, size:, parent:)
      @name = name
      @size = size.to_i
      @parent = parent
    end

    def chart(indent = 0)
      puts "#{" "*indent}#{name}"
    end
  end
  
  def initialize(input)
    @input = input
    @root = Directory.new(name: '/')
    @pwd = @root
  end

  def graph!
    @input.each do |line|
      case op_type(line)
      when :cd
        cd(line)
      when :ls
        no_op 
      when :dir
        no_op
      when :file
        size, name = line.split(' ')
        record_file!(size, name)
      end
    end
  end

  def calc_dir_sizes
    get_sub_dirs(@root).map do |dir|
      {
        name: dir.name,
        size: dir.size
      }
    end
  end

  def get_sub_dirs(dir)
    dirs = dir.children.select { |c| c.is_a?(Directory) }
    (dirs + dirs.map { |d| get_sub_dirs(d) }).flatten
  end

private

  # TODO: handle cd a file?
  def cd(input)
    _, _, dir = input.split(' ')
    
    case dir
    when '/'
      @pwd = @root
    when '..'
      @pwd = @pwd.parent
    else
      _dir = find_or_create(dir)
      @pwd.children << _dir
      @pwd = _dir
    end
  end

  def find_or_create(dir_name)
    dir = @pwd.children.find { |child| child.is_a?(Directory) && child.name == dir_name }
    return dir if dir

    Directory.new(name: dir_name, parent: @pwd)
  end

  def no_op
  end

  def op_type(line)
    t1, t2, t3 = line.split(' ')

    return :cd if t2 == 'cd'
    return :ls if t2 == 'ls'
    return :dir if t1 == 'dir'

    :file
  end

  def record_file!(size, name)
    file = @pwd.children.find { |c| c.is_a?(File) && c.name == name }
    return if file
    @pwd.children << File.new(name: name, size: size, parent: @pwd)
  end
end

def part_1(sys)
  size = sys
   .calc_dir_sizes
   .map { |o| o[:size] }
   .select { |size| size <= LIMIT }
   .sum
  
  puts "Part 1: #{size}"
end

def part_2(sys)
  unused = TOTAL_SPACE - sys.root.size
  to_free = REQUIRED_SPACE - unused
  size = sys
    .calc_dir_sizes
    .map { |o| o[:size] }
    .sort
    .find { |s| s >= to_free }

  puts "Part 2: #{size}"
end

sys = System.new(File.readlines('day7/input'))
sys.graph!

part_1(sys)
part_2(sys)