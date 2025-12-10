# frozen_string_literal: true

require 'set'

Point = Struct.new(:x, :y)

def parse_points(path)
  File.readlines(path, chomp: true)
      .map { |line| nums = line.scan(/-?\d+/); nums.empty? ? nil : Point.new(nums[0].to_i, nums[1].to_i) }
      .compact
end

def point_in_polygon?(x, y, polygon)
  crossings = 0
  n = polygon.size

  n.times do |i|
    x1, y1 = polygon[i]
    x2, y2 = polygon[(i + 1) % n]

    if (y1 <= y && y < y2) || (y2 <= y && y < y1)
      x_intersect = x1 + (y - y1).to_f / (y2 - y1) * (x2 - x1)
      crossings += 1 if x < x_intersect
    end
  end

  crossings.odd?
end

def point_on_boundary?(x, y, red_set, green_tiles)
  return true if red_set.include?([x, y])
  return true if green_tiles.include?("#{x},#{y}")

  false
end

def inside_or_on_boundary?(x, y, red_set, green_tiles, polygon)
  return true if point_on_boundary?(x, y, red_set, green_tiles)

  point_in_polygon?(x, y, polygon)
end

def valid_rectangle_sampled?(p1, p2, red_set, green_tiles, polygon)
  min_x = [p1.x, p2.x].min
  max_x = [p1.x, p2.x].max
  min_y = [p1.y, p2.y].min
  max_y = [p1.y, p2.y].max

  width = max_x - min_x + 1
  height = max_y - min_y + 1

  # Sample size based on rectangle size (like the Java version)
  samples = [100, [20, (Math.sqrt(width * height) / 100).to_i].max].min

  # Check top and bottom edges
  (0..samples).each do |i|
    x = min_x + (max_x - min_x) * i / samples
    return false unless inside_or_on_boundary?(x, min_y, red_set, green_tiles, polygon)
    return false unless inside_or_on_boundary?(x, max_y, red_set, green_tiles, polygon)

    # Check left and right edges
    y = min_y + (max_y - min_y) * i / samples
    return false unless inside_or_on_boundary?(min_x, y, red_set, green_tiles, polygon)
    return false unless inside_or_on_boundary?(max_x, y, red_set, green_tiles, polygon)
  end

  # Sample interior points
  (1...samples).each do |i|
    (1...samples).each do |j|
      x = min_x + (max_x - min_x) * i / samples
      y = min_y + (max_y - min_y) * j / samples
      return false unless inside_or_on_boundary?(x, y, red_set, green_tiles, polygon)
    end
  end

  true
end

def largest_area_red_green(points)
  polygon = points.map { |p| [p.x, p.y] }
  red_set = Set.new(polygon)

  # Build green tiles set (segments between consecutive red points)
  green_tiles = Set.new
  (0...points.size).each do |i|
    p1 = points[i]
    p2 = points[(i + 1) % points.size]

    if p1.x == p2.x
      ([p1.y, p2.y].min..[p1.y, p2.y].max).each do |y|
        green_tiles.add("#{p1.x},#{y}")
      end
    elsif p1.y == p2.y
      ([p1.x, p2.x].min..[p1.x, p2.x].max).each do |x|
        green_tiles.add("#{x},#{p1.y}")
      end
    end
  end

  puts "Checking #{points.size * (points.size - 1) / 2} rectangles with sampling..."

  max_area = 0
  best_pair = nil
  checked = 0

  points.each_with_index do |p1, i|
    if (i % 50).zero?
      puts "Progress: #{i}/#{points.size} (best: #{max_area})"
    end

    points[(i + 1)..].each do |p2|
      checked += 1

      width = (p1.x - p2.x).abs + 1
      height = (p1.y - p2.y).abs + 1
      area = width * height

      next if area <= max_area

      next unless valid_rectangle_sampled?(p1, p2, red_set, green_tiles, polygon)

      max_area = area
      best_pair = [p1, p2]
      puts "  New best: #{max_area} at #{p1.x},#{p1.y} to #{p2.x},#{p2.y}"
    end
  end

  puts "Checked #{checked} rectangles"
  [max_area, best_pair]
end

if __FILE__ == $0
  points = parse_points('input.txt')
  puts "Parsed #{points.size} points"

  area, pair = largest_area_red_green(points)
  puts "\nLargest red/green inclusive area: #{area}"
  if pair
    puts "Corners: #{pair[0].x},#{pair[0].y} and #{pair[1].x},#{pair[1].y}"
  end
end