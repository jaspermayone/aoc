# frozen_string_literal: true

def parse_points(path)
  File.readlines(path, chomp: true)
      .map { |line| line.scan(/-?\d+/).map(&:to_i) }
      .reject(&:empty?)
end

def largest_area(points)
  max_area = 0
  best_pair = nil

  points.each_with_index do |(x1, y1), i|
    points[(i + 1)..].each do |(x2, y2)|
      width  = (x1 - x2).abs + 1
      height = (y1 - y2).abs + 1
      area = width * height
      if area > max_area
        max_area = area
        best_pair = [[x1, y1], [x2, y2]]
      end
    end
  end

  [max_area, best_pair]
end

def render(points, rect_pair: nil)
  xs = points.map(&:first)
  ys = points.map(&:last)
  min_x, max_x = xs.min, xs.max
  min_y, max_y = ys.min, ys.max

  width  = max_x - min_x + 1
  height = max_y - min_y + 1

  grid = Array.new(height) { Array.new(width, '.') }

  points.each do |x, y|
    gx = x - min_x
    gy = y - min_y
    grid[gy][gx] = '#'
  end

  if rect_pair
    (x1, y1), (x2, y2) = rect_pair
    lx, rx = [x1, x2].minmax
    ty, by = [y1, y2].minmax
    (ty..by).each do |y|
      (lx..rx).each do |x|
        gy = y - min_y
        gx = x - min_x
        grid[gy][gx] = 'O'
      end
    end
    [[x1,y1],[x2,y2]].each do |x,y|
      grid[y - min_y][x - min_x] = '#'
    end
  end

  grid.each { |row| puts row.join }
end

if __FILE__ == $0
  points = parse_points('input.txt')
  area, pair = largest_area(points)
  puts "Largest inclusive area: #{area}"
  puts "Corners: #{pair[0].join(',')} and #{pair[1].join(',')}"
  # render(points, rect_pair: pair)
end
