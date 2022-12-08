require 'byebug'

def visible_from?(height, trees)
  trees.all? { |tree| tree < height }
end

# NOTE: remove \n
def trim(line)
  return line if line[-1] != "\n"
  return line[0..-2]
end

def left(x, row)
  row[0..x-1]
end

def right(x, row)
  row[x+1..-1]
end

def top(y, col)
  col[0..y-1]
end

def bottom(y, col)
  col[y+1..-1]
end

def view_distance(height, trees)
  dist = 0
  trees.each do |tree|
    dist += 1
    break if tree >= height
  end
  dist
end

def scenic_score(height, top, bot, left, right)
  top_score = view_distance(height, top.reverse)
  bot_score = view_distance(height, bot)
  left_score = view_distance(height, left.reverse)
  right_score = view_distance(height, right)

  top_score * bot_score * left_score * right_score
end

def part_1(trees)
  visible_count = 0

  trees.each_with_index do |row, y|
    if y == 0 || y == trees.length - 1
      visible_count += row.length
      next
    end
    
    row.each_with_index do |height, x|
      if x == 0 || x == row.length - 1
        visible_count += 1
        next
      end

      col = trees.map { |row| row[x] }

      visible = visible_from?(height, top(y, col)) ||
        visible_from?(height, bottom(y, col)) ||
        visible_from?(height, left(x, row)) ||
        visible_from?(height, right(x, row))

      visible_count += 1 if visible
    end
  end

  puts "Part 1: #{visible_count}"
end

def part_2(trees)
  scores = []

  trees.each_with_index do |row, y|
    next if y == 0 || y == trees.length - 1

    row.each_with_index do |height, x|
      next if x == 0 || x == row.length - 1

      col = trees.map { |row| row[x] }

      scores << scenic_score(
        height,
        top(y, col),
        bottom(y, col),
        left(x, row),
        right(x, row)
      )
    end
  end

  puts "Part 2: #{scores.max}"
end

trees = File
  .readlines('day8/input')
  .map { |line| trim(line).split('').map(&:to_i) }

part_1(trees)
part_2(trees)